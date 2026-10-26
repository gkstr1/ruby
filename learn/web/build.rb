#!/usr/bin/env ruby
# frozen_string_literal: true

# Builds the Ruby Quest web page from the same lessons the terminal game uses.
#
#   ruby learn/web/build.rb
#
# Writes learn/web/dist/index.html plus dist/ruby.wasm.gz, the in-browser Ruby
# (downloaded from npm on first build). Publish both files side by side.

require "json"
require "net/http"
require "rubygems/package"
require "zlib"
require_relative "../ruby_quest"

module RubyQuest
  module WebBuild
    WASM_PACKAGE = "https://registry.npmjs.org/@ruby/3.3-wasm-wasi/-/3.3-wasm-wasi-2.7.2.tgz"
    HERE = __dir__
    DIST = File.join(HERE, "dist")

    module_function

    def run
      Dir.mkdir(DIST) unless Dir.exist?(DIST)
      page = File.read(File.join(HERE, "template.html"), encoding: "UTF-8")
                 .sub("/*LESSONS*/null") { safe_json(lessons) }
                 .sub("/*HARNESS*/null") { safe_json(File.read(File.join(HERE, "harness.rb"), encoding: "UTF-8")) }
      File.write(File.join(DIST, "index.html"), page)
      fetch_wasm
      puts "Built #{File.join(DIST, 'index.html')} (#{LESSONS.size} lessons)"
    end

    def lessons
      LESSONS.map do |lesson|
        { title: lesson.title, intro: lesson.intro, try: lesson.try,
          questions: lesson.questions.map { |q| question(q) } }
      end
    end

    # Answers for print/return questions are computed here by running real Ruby.
    def question(q)
      data = { type: q.type, prompt: q.prompt, code: q.code, hint: q.hint, explain: q.explain }
      case q.type
      when :output then data[:expected] = Sandbox.run(q.code).out
      when :value then data[:expected] = Sandbox.run(q.code).value.inspect
      when :choice then data.merge!(choices: q.choices, answer: q.answer)
      when :write
        data[:solution] = q.solution
        data[:tests] = q.tests.map do |t|
          [t[:before], t[:after], t[:out], (t[:value].inspect if t.key?(:value))]
        end
      end
      data.compact
    end

    # JSON that can sit inside a <script> tag.
    def safe_json(data) = JSON.generate(data).gsub("</", "<\\/")

    def fetch_wasm
      target = File.join(DIST, "ruby.wasm.gz")
      return if File.exist?(target)

      puts "Downloading ruby.wasm from npm…"
      tarball = Net::HTTP.get(URI(WASM_PACKAGE))
      Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(tarball))) do |tar|
        entry = tar.find { |e| e.full_name == "package/dist/ruby.wasm" } or abort "ruby.wasm not in package"
        Zlib::GzipWriter.open(target, Zlib::BEST_COMPRESSION) { |gz| gz.write(entry.read) }
      end
    end
  end
end

RubyQuest::WebBuild.run if $PROGRAM_NAME == __FILE__
