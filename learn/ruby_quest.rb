#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby Quest: an interactive quiz that teaches Ruby from the very beginning.
#
#   ruby learn/ruby_quest.rb              # play
#   ruby learn/ruby_quest.rb --reset      # forget saved progress
#   ruby learn/ruby_quest.rb --self-test  # check every question's answer key

require "json"
require "stringio"
require "timeout"

module RubyQuest
  PROGRESS_FILE = File.join(Dir.home, ".ruby_quest_progress.json")
  TIME_LIMIT = 2 # seconds any snippet may run (guards against infinite loops)

  # Lessons are described with this small DSL; see lessons.rb.
  Lesson = Struct.new(:title, :intro, :questions)
  Question = Struct.new(:type, :prompt, :code, :choices, :answer, :check,
                        :solution, :hint, :explain, keyword_init: true)
  Result = Struct.new(:value, :out, :error) do
    def text = out.strip
    def lines = out.lines.map(&:strip).reject(&:empty?)
  end

  LESSONS = []

  class LessonBuilder
    def initialize(title) = @lesson = Lesson.new(title, "", [])
    def intro(text) = @lesson.intro = text
    def build = @lesson

    # "What does this print?"
    def output(code, hint: nil, explain:)
      add(type: :output, code: code, hint: hint, explain: explain)
    end

    # "What does this return?"
    def value(code, hint: nil, explain:)
      add(type: :value, code: code, hint: hint, explain: explain)
    end

    # Multiple choice; answer is the index of the correct choice.
    def choice(prompt, choices, answer:, hint: nil, explain:)
      add(type: :choice, prompt: prompt, choices: choices, answer: answer, hint: hint, explain: explain)
    end

    # The player writes code; check receives a runner `run.(before, after)`
    # that evaluates before + player's code + after and returns a Result.
    def write(prompt, solution:, check:, hint: nil, explain:)
      add(type: :write, prompt: prompt, solution: solution, check: check, hint: hint, explain: explain)
    end

    private

    def add(**attrs) = @lesson.questions << Question.new(**attrs)
  end

  def self.lesson(title, &block)
    builder = LessonBuilder.new(title)
    builder.instance_eval(&block)
    LESSONS << builder.build
  end

  # Runs Ruby code in a fresh, isolated scope and captures what it prints.
  module Sandbox
    module_function

    def run(code)
      constants_before = Object.constants
      scope = Object.new.instance_eval { binding }
      captured = StringIO.new
      real_stdout = $stdout
      $stdout = captured
      value = Timeout.timeout(TIME_LIMIT) { scope.eval(code, "(your code)") }
      Result.new(value, captured.string, nil)
    rescue Timeout::Error
      Result.new(nil, captured.string, "it ran for more than #{TIME_LIMIT} seconds (infinite loop?)")
    rescue StandardError, ScriptError => e
      Result.new(nil, captured.string, "#{e.class}: #{e.message.lines.first&.strip}")
    ensure
      $stdout = real_stdout
      (Object.constants - constants_before).each { |c| Object.send(:remove_const, c) }
    end
  end

  module Color
    ENABLED = $stdout.tty? && !ENV.key?("NO_COLOR")
    CODES = { bold: 1, dim: 2, red: 31, green: 32, yellow: 33, blue: 34, magenta: 35, cyan: 36 }.freeze

    CODES.each do |name, code|
      define_singleton_method(name) { |s| ENABLED ? "\e[#{code}m#{s}\e[0m" : s.to_s }
    end
  end

  class Game
    C = Color

    def initialize(input: $stdin, output: $stdout)
      @in = input
      @out = output
      @progress = load_progress
    end

    def play
      banner
      loop do
        index = pick_lesson or break
        play_lesson(index)
      end
      say "\nSee you next time! Keep practising with `irb`, Ruby's interactive console."
    end

    private

    # ---- menus -------------------------------------------------------------

    def banner
      say C.bold(C.red("\n  💎  RUBY QUEST  💎"))
      say C.dim("  Learn Ruby one question at a time.\n")
      say "  At any question you can type #{C.cyan('hint')}, #{C.cyan('skip')} or #{C.cyan('quit')}."
      say "  You get two tries per question: 2 points on the first, 1 on the second."
    end

    def pick_lesson
      next_up = LESSONS.each_index.find { |i| !@progress.key?(i.to_s) } || 0
      say C.bold("\nLessons:")
      LESSONS.each_with_index do |lesson, i|
        best = @progress[i.to_s]
        status = best ? C.green("✓ best #{best}/#{lesson.questions.size * 2}") : ""
        marker = i == next_up ? C.yellow(" ← next") : ""
        say format("  %2d. %-28s %s%s", i + 1, lesson.title, status, marker)
      end
      choice = ask("\nPick a lesson number (Enter for #{next_up + 1}, q to quit): ")
      return nil if choice.nil? || choice.match?(/\A(q|quit|exit)\z/i)
      return next_up if choice.empty?

      number = choice.to_i
      return number - 1 if number.between?(1, LESSONS.size)

      say C.red("There's no lesson #{choice}.")
      pick_lesson
    end

    # ---- a lesson -----------------------------------------------------------

    def play_lesson(index)
      lesson = LESSONS[index]
      say C.bold(C.magenta("\n━━━ Lesson #{index + 1}: #{lesson.title} ━━━\n"))
      say lesson.intro.strip
      ask(C.dim("\n(press Enter to start the questions)"))

      score = 0
      missed = []
      lesson.questions.each_with_index do |q, qi|
        say C.bold("\nQuestion #{qi + 1} of #{lesson.questions.size}")
        points = ask_question(q)
        return if points == :quit

        score += points
        missed << qi + 1 if points.zero?
      end

      max = lesson.questions.size * 2
      say C.bold("\nLesson complete! Score: #{score}/#{max}")
      if score == max then say C.green("Perfect run. 🎉")
      elsif missed.empty? then say "Every question answered — some on the second try. Nice!"
      else say "Worth another look: question #{missed.join(', ')}."
      end
      record(index, score)
    end

    def ask_question(q)
      show_question(q)
      2.downto(1) do |points|
        answer = ask(C.cyan(q.type == :write ? "ruby> " : "> "))
        case answer&.downcase
        when nil, "q", "quit", "exit" then return :quit
        when "skip" then break
        when "hint"
          say C.yellow("Hint: #{q.hint || 'Read the code line by line and say out loud what each part does.'}")
          redo
        when "" then redo
        end

        verdict, note = grade(q, answer)
        if verdict
          say C.green("✔ Correct!") + (note ? " #{note}" : "")
          say C.dim(q.explain)
          return points
        end

        say C.red("✘ Not quite.") + (note ? " #{note}" : "")
        say C.yellow("Hint: #{q.hint}") if q.hint && points == 2
        say "Try once more." if points == 2
      end

      say "The answer: #{C.bold(correct_answer(q))}"
      say C.dim(q.explain)
      0
    end

    def show_question(q)
      case q.type
      when :output then say "What does this code #{C.bold('print')}?"
      when :value then say "What does this code #{C.bold('return')} (evaluate to)?"
      else say q.prompt
      end
      say code_block(q.code) if q.code
      q.choices&.each_with_index { |c, i| say "  #{C.bold((97 + i).chr)}) #{c}" }
      say C.dim("(Several lines of output? Type them on one line separated by spaces.)") if q.type == :output
      say C.dim("(Write it on one line; use ; to separate statements.)") if q.type == :write
    end

    def code_block(code)
      code.lines.map { |l| "    " + C.cyan(l.chomp) }.join("\n")
    end

    # ---- grading ------------------------------------------------------------

    def grade(q, answer)
      case q.type
      when :choice then grade_choice(q, answer)
      when :output then grade_output(q, answer)
      when :value then grade_value(q, answer)
      when :write then grade_write(q, answer)
      end
    end

    def grade_choice(q, answer)
      picked = answer.strip.downcase
      index = picked.match?(/\A[a-z]\z/) ? picked.ord - 97 : q.choices.index { |c| c.downcase == picked }
      return [false, "Type the letter of your choice."] unless index&.between?(0, q.choices.size - 1)

      [index == q.answer, nil]
    end

    def grade_output(q, answer)
      expected = squish(Sandbox.run(q.code).out)
      given = squish(answer)
      return [true, nil] if given == expected

      unquoted = given.delete_prefix('"').delete_suffix('"')
      if unquoted == expected
        return [true, "(puts and print don't show the quotes — they print just the text.)"]
      end

      [false, nil]
    end

    def grade_value(q, answer)
      expected = Sandbox.run(q.code).value
      given = answer.strip
      return [true, nil] if given == expected.inspect

      attempt = Sandbox.run(given)
      if attempt.error.nil?
        return [true, nil] if attempt.value.eql?(expected)
        if attempt.value == expected
          return [false, "Right number, wrong type: Ruby gives #{expected.class}, you gave #{attempt.value.class}."]
        end
      end

      if expected.is_a?(String) && given == expected
        return [true, "Ruby would show it as #{expected.inspect} — the quotes mark it as a String."]
      end
      if expected.is_a?(Symbol) && given == expected.to_s
        return [false, "Close! Remember the colon that makes it a Symbol."]
      end

      [false, nil]
    end

    def grade_write(q, answer)
      last = nil
      runner = lambda do |before = "", after = ""|
        last = Sandbox.run([before, answer, after].reject(&:empty?).join("\n"))
      end
      passed = begin
        q.check.call(runner)
      rescue StandardError
        false
      end
      return [true, nil] if passed

      note = if last&.error then "Ruby raised an error: #{last.error}"
             elsif last && !last.text.empty? then "Your code printed: #{last.text.lines.first.strip}"
             elsif last then "Your code returned: #{last.value.inspect}"
             end
      [false, note]
    end

    def correct_answer(q)
      case q.type
      when :choice then "#{(97 + q.answer).chr}) #{q.choices[q.answer]}"
      when :output then squish(Sandbox.run(q.code).out)
      when :value then Sandbox.run(q.code).value.inspect
      when :write then q.solution
      end
    end

    def squish(text) = text.split.join(" ")

    # ---- I/O & progress -------------------------------------------------------

    def say(text) = @out.puts(text)

    def ask(prompt)
      @out.print prompt
      @in.gets&.strip
    end

    def load_progress
      File.exist?(PROGRESS_FILE) ? JSON.parse(File.read(PROGRESS_FILE)) : {}
    rescue JSON::ParserError
      {}
    end

    def record(index, score)
      key = index.to_s
      @progress[key] = [@progress[key].to_i, score].max
      File.write(PROGRESS_FILE, JSON.pretty_generate(@progress))
    rescue SystemCallError
      nil # progress is a nicety; never crash the game over it
    end
  end

  # Verifies every question runs cleanly and every model solution passes.
  def self.self_test
    failures = []
    LESSONS.each_with_index do |lesson, li|
      lesson.questions.each_with_index do |q, qi|
        where = "Lesson #{li + 1} (#{lesson.title}), question #{qi + 1}"
        case q.type
        when :output, :value
          result = Sandbox.run(q.code)
          failures << "#{where}: #{result.error}" if result.error
          failures << "#{where}: prints nothing" if q.type == :output && result.text.empty?
        when :choice
          failures << "#{where}: answer out of range" unless q.answer.between?(0, q.choices.size - 1)
        when :write
          ok, = Game.new.send(:grade_write, q, q.solution)
          failures << "#{where}: model solution fails its own check" unless ok
        end
      end
    end
    count = LESSONS.sum { |l| l.questions.size }
    if failures.empty?
      puts "All #{count} questions in #{LESSONS.size} lessons check out."
    else
      puts failures
      exit 1
    end
  end
end

require_relative "lessons"

if $PROGRAM_NAME == __FILE__
  case ARGV.first
  when "--self-test" then RubyQuest.self_test
  when "--reset"
    File.delete(RubyQuest::PROGRESS_FILE) if File.exist?(RubyQuest::PROGRESS_FILE)
    puts "Progress reset."
  else
    begin
      RubyQuest::Game.new.play
    rescue Interrupt
      puts "\nBye!"
    end
  end
end
