# Loaded into Ruby (ruby.wasm) inside the browser by the Ruby Quest web page.
# It only uses core Ruby, because the browser build ships without the stdlib.
#
# Results go back to JavaScript as one String with fields separated by \u0001.

# Captures everything printed with puts/print/p while learner code runs.
class QuestOut
  def initialize = @buf = +""
  def string = @buf
  def flush = self
  def sync = true
  def sync=(_); end
  def tty? = false

  def write(*args)
    args.sum do |arg|
      text = arg.to_s
      @buf << text
      text.bytesize
    end
  end

  def <<(arg)
    write(arg)
    self
  end

  def print(*args)
    write(*args)
    nil
  end

  def puts(*args)
    write("\n") if args.empty?
    args.each do |arg|
      if arg.is_a?(Array)
        arg.empty? ? write("\n") : arg.flatten.each { |item| puts(item) }
      else
        text = arg.nil? ? "" : arg.to_s
        write(text)
        write("\n") unless text.end_with?("\n")
      end
    end
    nil
  end
end

module Quest
  SEP = "\u0001"

  module_function

  # Runs code in a fresh scope; returns [value, printed output, error or nil].
  def run(code)
    constants_before = Object.constants
    out = QuestOut.new
    real_stdout = $stdout
    $stdout = out
    scope = TOPLEVEL_BINDING.eval("Object.new.instance_eval { binding }") # top-level, so classes land on Object
    [scope.eval(code, "(your code)"), out.string, nil]
  rescue Exception => e # rubocop:disable Lint/RescueException -- learner code may call exit, overflow the stack, etc.
    [nil, out&.string.to_s, "#{e.class}: #{e.message.lines.first&.strip}"]
  ensure
    $stdout = real_stdout
    (Object.constants - constants_before).each { |c| Object.send(:remove_const, c) }
  end

  def safe_inspect(value)
    value.inspect
  rescue Exception # rubocop:disable Lint/RescueException
    "#<#{value.class}>"
  end

  # Playground: "output SEP error SEP inspected value"
  def snippet(code)
    value, out, error = run(code)
    [out, error.to_s, error ? "" : safe_inspect(value)].join(SEP)
  end

  # Value questions: compares the learner's answer with the expected literal.
  # "1" same value, "type SEP Expected SEP Given" equal number but different class,
  # "0" different, "err SEP message" the answer isn't valid Ruby.
  def same(answer, expected_source)
    expected, = run(expected_source)
    value, _, error = run(answer)
    return ["err", error].join(SEP) if error
    return "1" if value.eql?(expected)
    return ["type", expected.class, value.class].join(SEP) if value == expected

    "0"
  end

  # Write-the-code questions. Each test is [before, after, out, value_source];
  # nil fields are skipped. Returns "1" or "0 SEP note".
  def check(code, tests)
    last = nil
    passed = tests.all? do |before, after, out, value_source|
      last = run([before, code, after].compact.join("\n"))
      printed = last[1].lines.map(&:strip).reject(&:empty?).join("\n")
      last[2].nil? &&
        (out.nil? || printed == out) &&
        (value_source.nil? || last[0] == run(value_source)[0])
    end
    return "1" if passed

    value, out, error = last
    note = if error then "Ruby raised an error: #{error}"
           elsif !out.strip.empty? then "Your code printed: #{out.strip.lines.first.strip}"
           else "Your code returned: #{safe_inspect(value)}"
           end
    ["0", note].join(SEP)
  end
end
