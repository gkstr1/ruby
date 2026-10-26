# frozen_string_literal: true

# The curriculum for Ruby Quest. Each lesson opens with a short explanation,
# then asks questions of four kinds:
#
#   output  - "What does this print?"
#   value   - "What does this return?"
#   choice  - multiple choice
#   write   - the player writes Ruby; `check` decides whether it works
#
# Expected answers for output/value questions are computed by actually
# running the code, so they can never drift out of sync with Ruby itself.

module RubyQuest
  lesson "Hello, Ruby" do
    intro <<~'TEXT'
      Ruby is a programming language designed to be pleasant to read and write.
      A Ruby program is a list of instructions run from top to bottom.

      The first thing to learn is how to show text on the screen:

          puts "Hello!"      # prints Hello! and then moves to a new line
          print "Hi"         # prints Hi but stays on the same line

      Text in quotes is called a String. Anything after a # is a comment:
      Ruby ignores it, so it's a note for humans.
    TEXT

    choice "Which method prints text and then moves to a new line?",
           ["print", "puts", "echo", "console.log"], answer: 1,
           explain: "puts means \"put string\". It adds a newline at the end; print doesn't."

    output 'puts "Hello, Ruby!"',
           explain: "puts prints the text inside the quotes — the quotes themselves aren't printed."

    output %(# puts "secret"\nputs "visible"),
           hint: "What does Ruby do with a line that starts with #?",
           explain: "The first line is a comment, so Ruby skips it. Only \"visible\" is printed."

    output %(print "a"\nprint "b"\nputs "c"),
           hint: "print does not move to a new line.",
           explain: "print stays on the same line, so a, b and c end up together: abc."

    output 'puts "Ruby" + "ist"',
           hint: "+ joins two strings together.",
           explain: "Using + on two Strings glues them together: \"Ruby\" + \"ist\" is \"Rubyist\"."

    write "Write a line of Ruby that prints exactly: Hello, World!",
          solution: 'puts "Hello, World!"',
          check: ->(run) { run.().text == "Hello, World!" },
          hint: "Use puts followed by the text in double quotes.",
          explain: "puts \"Hello, World!\" — the traditional first program in every language."
  end

  lesson "Numbers and math" do
    intro <<~'TEXT'
      Ruby has two main kinds of numbers:

          42       # an Integer (whole number)
          3.14     # a Float (number with a decimal point)

      Math works like you'd expect: + - * /, and also:

          10 % 3   # => 1   (% is "remainder")
          2 ** 3   # => 8   (** is "to the power of")

      One surprise: dividing two Integers gives an Integer — the decimal part
      is dropped. 7 / 2 is 3, but 7.0 / 2 is 3.5.

      In these questions, "what does it return" means the value Ruby calculates.
      Type it the way Ruby would show it (e.g. 3.5, or "text" with quotes).
    TEXT

    value "7 + 3 * 2",
          hint: "Ruby follows the usual math order: * before +.",
          explain: "Multiplication first: 3 * 2 = 6, then 7 + 6 = 13."

    value "(7 + 3) * 2",
          explain: "Parentheses go first: 7 + 3 = 10, then 10 * 2 = 20."

    value "10 / 3",
          hint: "Both numbers are Integers...",
          explain: "Integer ÷ Integer gives an Integer; the .333 is thrown away, leaving 3."

    value "10.0 / 4",
          explain: "One of the numbers is a Float, so the result is a Float: 2.5."

    value "17 % 5",
          hint: "% gives what's left over after dividing.",
          explain: "17 ÷ 5 is 3 with 2 left over, so 17 % 5 is 2."

    value "2 ** 4",
          explain: "** is exponent: 2 × 2 × 2 × 2 = 16."

    choice "What kind of number is 3.14?",
           ["Integer", "Float", "String", "Decimal"], answer: 1,
           explain: "Numbers with a decimal point are Floats. Try 3.14.class in irb!"

    write "Write an expression that calculates how many seconds are in a day (24 hours × 60 minutes × 60 seconds).",
          solution: "24 * 60 * 60",
          check: ->(run) { run.().value == 86_400 },
          hint: "Multiply the three numbers with *.",
          explain: "24 * 60 * 60 is 86400. Ruby is a handy calculator!"
  end

  lesson "Variables" do
    intro <<~'TEXT'
      A variable is a name that holds a value, so you can use it later:

          name = "Ada"
          age = 36
          puts name          # prints Ada

      = means "store this value in this name" (not "is equal to").
      You can change a variable whenever you like:

          age = age + 1      # now 37
          age += 1           # shortcut for the same thing, now 38

      Variable names use lowercase letters and underscores: first_name, total_score.
    TEXT

    output %(name = "Ada"\nputs "Hi, " + name),
           explain: "name holds \"Ada\", so \"Hi, \" + name becomes \"Hi, Ada\"."

    output %(x = 5\nx = x + 1\nputs x),
           hint: "Work out the right side first, then store it.",
           explain: "x + 1 is 6, and that gets stored back into x."

    output %(score = 10\nscore += 5\nscore -= 3\nputs score),
           explain: "10, then += 5 makes 15, then -= 3 makes 12."

    choice "Which of these is a valid Ruby variable name?",
           ["2nd_place", "first-name", "first_name", "First Name"], answer: 2,
           explain: "Variable names can't start with a digit, contain dashes or spaces. snake_case like first_name is the Ruby style."

    output %(a = 1\nb = a\na = 99\nputs b),
           hint: "b got a copy of a's value at that moment.",
           explain: "b = a stores 1 in b. Changing a afterwards doesn't affect b, so b is still 1."

    write "Create a variable called price set to 25, then print price multiplied by 4.",
          solution: "price = 25; puts price * 4",
          check: ->(run) { run.().text == "100" && run.("", "price").value == 25 },
          hint: "Two statements: price = 25 ; puts price * 4",
          explain: "price = 25 stores the number; puts price * 4 prints 100."
  end

  lesson "Working with strings" do
    intro <<~'TEXT'
      Strings have lots of built-in methods. You call a method with a dot:

          "hello".upcase      # => "HELLO"
          "hello".length      # => 5

      You can put a value inside a string with #{...} — this is called
      interpolation, and it only works in "double quotes":

          name = "Matz"
          "Hi, #{name}!"      # => "Hi, Matz!"
          'Hi, #{name}!'      # stays exactly Hi, #{name}!  (single quotes: no magic)

      Strings and numbers don't mix with +. Convert with .to_s (to string)
      or .to_i (to integer):  "Age: " + 30.to_s
    TEXT

    output %(name = "Matz"\nputs "Hello, \#{name}!"),
           explain: "Inside double quotes, \#{name} is replaced with the variable's value."

    output %(puts 'Total: \#{1 + 1}'),
           hint: "Look closely at the kind of quotes.",
           explain: "Single-quoted strings don't interpolate, so the text is printed exactly as written."

    value '"ruby".upcase',
          explain: "upcase returns a new String in capital letters."

    value '"hello".length',
          explain: "\"hello\" has 5 characters."

    value '"stressed".reverse',
          explain: "reverse flips the characters: \"desserts\"."

    value '"ha" * 3',
          explain: "Multiplying a String repeats it."

    value '"5" + "5"',
          hint: "These are Strings, not numbers.",
          explain: "+ on Strings joins them, giving \"55\" — not 10!"

    value '"5".to_i + 5',
          explain: "to_i turns \"5\" into the Integer 5, so this really is 5 + 5 = 10."

    write 'Given name = "ruby", write ONE string using interpolation that evaluates to "I love ruby!"',
          solution: '"I love #{name}!"',
          check: ->(run) { run.('name = "ruby"').value == "I love ruby!" && run.('name = "cats"').value == "I love cats!" },
          hint: 'Use double quotes and put #{name} where the word goes.',
          explain: "\"I love \#{name}!\" works for any name — that's the power of interpolation."
  end

  lesson "True, false and if" do
    intro <<~'TEXT'
      Comparisons give true or false (called booleans):

          5 > 3      # => true
          5 == 3     # => false   (== compares; = assigns!)
          5 != 3     # => true    (!= means "not equal")

      Combine them with && (and), || (or), ! (not).

      Use if to run code only when something is true:

          if temperature > 25
            puts "Hot"
          elsif temperature > 15
            puts "Nice"
          else
            puts "Cold"
          end

      Short versions:  puts "Hot" if temperature > 25
                       puts "Brr" unless temperature > 15
    TEXT

    value "10 >= 10",
          explain: ">= means greater than OR equal to, and 10 equals 10."

    value "3 != 3",
          explain: "3 is equal to 3, so \"not equal\" is false."

    value "true && false",
          hint: "&& needs BOTH sides to be true.",
          explain: "&& (and) is only true when both sides are true."

    value "false || true",
          explain: "|| (or) is true when at least one side is true."

    output %(temp = 18\nif temp > 25\n  puts "Hot"\nelsif temp > 15\n  puts "Nice"\nelse\n  puts "Cold"\nend),
           hint: "Check each condition from the top; the first true one wins.",
           explain: "18 > 25 is false, 18 > 15 is true, so \"Nice\" is printed and the rest is skipped."

    output %(age = 12\nputs "Welcome" unless age < 18\nputs "Done"),
           hint: "unless is the opposite of if.",
           explain: "age < 18 is true, so unless skips \"Welcome\". Then \"Done\" prints."

    write "Given a number n, print \"even\" if it is even, otherwise print \"odd\". (Tip: n % 2 == 0 or n.even?)",
          solution: 'if n.even? then puts "even" else puts "odd" end',
          check: lambda { |run|
            run.("n = 4").text == "even" && run.("n = 7").text == "odd" && run.("n = 0").text == "even"
          },
          hint: 'One-line form: if n.even? then puts "even" else puts "odd" end',
          explain: "if/else picks one of two paths. A shorter style: puts(n.even? ? \"even\" : \"odd\")"
  end

  lesson "Arrays" do
    intro <<~'TEXT'
      An Array is an ordered list, written with square brackets:

          colors = ["red", "green", "blue"]

      Get items by position (index). Counting starts at 0!

          colors[0]     # => "red"
          colors[-1]    # => "blue"  (negative counts from the end)

      Useful methods: length, first, last, sort, include?, sum, max, join.
      Add an item with <<  :  colors << "pink"
    TEXT

    value '["red", "green", "blue"][1]',
          hint: "The first item is at index 0.",
          explain: "Index 0 is \"red\", index 1 is \"green\"."

    value "[10, 20, 30][-1]",
          explain: "-1 means the last item."

    value "[3, 1, 2].sort",
          explain: "sort returns a new Array in ascending order."

    output %(fruits = ["apple", "banana"]\nfruits << "cherry"\nputs fruits.length),
           explain: "<< adds \"cherry\" to the end, so there are now 3 fruits."

    value "[1, 2, 3].include?(5)",
          explain: "include? asks whether the item is in the Array — 5 isn't."

    value '["a", "b", "c"].join("-")',
          explain: "join glues the items into one String, with \"-\" between them."

    value "[4, 9, 2].max",
          explain: "max returns the largest item."

    write "Given an array nums, write an expression that returns the sum of all its numbers.",
          solution: "nums.sum",
          check: ->(run) { run.("nums = [4, 8, 15, 16, 23, 42]").value == 108 && run.("nums = [1, 2]").value == 3 },
          hint: "There's a method whose name is exactly what you want to do.",
          explain: "nums.sum adds everything up. Ruby methods often read like English."
  end

  lesson "Hashes and symbols" do
    intro <<~'TEXT'
      A Hash stores pairs: a key and its value. Think of a dictionary.

          person = { "name" => "Ada", "age" => 36 }
          person["name"]       # => "Ada"

      Keys are very often Symbols — names that start with a colon, like :name.
      There's a shorter way to write a Hash with Symbol keys:

          scores = { alice: 10, bob: 7 }     # same as { :alice => 10, :bob => 7 }
          scores[:bob]                       # => 7
          scores[:carol] = 5                 # add or change a pair

      Asking for a key that isn't there gives nil, which means "nothing".
    TEXT

    value %(person = { "name" => "Ada", "age" => 36 }\nperson["age"]),
          explain: "Looking up the key \"age\" gives its value, 36."

    value %(scores = { alice: 10, bob: 7 }\nscores[:bob]),
          explain: "bob: 7 creates the Symbol key :bob, so scores[:bob] is 7."

    value "{ a: 1 }[:z]",
          hint: "What's Ruby's word for \"nothing\"?",
          explain: "Missing keys return nil."

    choice "In { name: \"Ada\" }, what is the key?",
           ['The String "name"', "The Symbol :name", "A variable called name", "The String \"Ada\""], answer: 1,
           explain: "The name: shorthand creates a Symbol key, :name."

    value "{ a: 1, b: 2 }.keys",
          explain: "keys returns an Array of all the keys: [:a, :b]."

    output %(h = {}\nh[:color] = "red"\nh[:color] = "blue"\nputs h[:color]),
           explain: "Assigning to an existing key replaces its value, so it ends up \"blue\"."

    write "Given stock = { apples: 5 }, add bananas with a count of 3, and finish by returning stock.",
          solution: "stock[:bananas] = 3; stock",
          check: ->(run) { run.("stock = { apples: 5 }").value == { apples: 5, bananas: 3 } },
          hint: "stock[:bananas] = 3 ; stock",
          explain: "hash[key] = value adds a pair. Ending with just stock makes it the returned value."
  end

  lesson "Loops and ranges" do
    intro <<~'TEXT'
      Ruby rarely uses classic for-loops. Instead you call methods with a block
      — a chunk of code inside { } (or do ... end):

          3.times { puts "hi" }                 # prints hi 3 times
          [1, 2, 3].each { |n| puts n * 10 }    # n is each item in turn

      The |n| part names the current item. A Range is a sequence of values:

          (1..4)     # 1, 2, 3, 4      (two dots: includes the end)
          (1...4)    # 1, 2, 3         (three dots: excludes the end)

      A while loop repeats as long as a condition is true:

          i = 0
          while i < 3
            puts i
            i += 1
          end
    TEXT

    output '3.times { print "hi " }',
           explain: "The block runs 3 times, printing hi each time."

    output '[1, 2, 3].each { |n| print n * 10, " " }',
           explain: "each passes 1, 2 and 3 into n in turn, printing 10 20 30."

    value "(1..5).to_a",
          explain: "to_a turns the Range into an Array. Two dots include the 5."

    value "(1...5).to_a",
          hint: "Count the dots.",
          explain: "Three dots stop BEFORE the end, so 5 is left out."

    output %(i = 0\nwhile i < 3\n  print i\n  i += 1\nend),
           hint: "Track i: what is it each time the condition is checked?",
           explain: "It prints 0, 1, 2. When i becomes 3, i < 3 is false and the loop stops."

    output %(["a", "b"].each_with_index { |letter, i| print i, letter, " " }),
           explain: "each_with_index gives the item AND its index: 0a 1b."

    write "Print the numbers 1 to 5, each on its own line.",
          solution: "(1..5).each { |n| puts n }",
          check: ->(run) { run.().lines == %w[1 2 3 4 5] },
          hint: "(1..5).each { |n| puts n }   — or try 1.upto(5) { ... }",
          explain: "(1..5).each, 1.upto(5) and 5.times { |i| puts i + 1 } all work."
  end

  lesson "Methods" do
    intro <<~'TEXT'
      A method is a named, reusable piece of code. Define it with def ... end:

          def greet(name)
            "Hello, #{name}!"
          end

          greet("Bob")      # => "Hello, Bob!"

      A method automatically returns its LAST line — you rarely need `return`.
      Parameters can have defaults:  def greet(name = "friend")

      Naming conventions:
        ending in ?  → returns true/false        e.g. 5.even?
        ending in !  → changes the object itself  e.g. name.upcase!
    TEXT

    output %(def greet(name)\n  "Hello, \#{name}"\nend\nputs greet("Bob")),
           explain: "greet returns its last line, \"Hello, Bob\", which puts then prints."

    value %(def square(x)\n  x * x\nend\nsquare(4) + 1),
          explain: "square(4) returns 16, plus 1 is 17."

    output %(def greet(name = "friend")\n  puts "Hi, \#{name}"\nend\ngreet),
           hint: "No argument was passed...",
           explain: "When no argument is given, the default \"friend\" is used."

    output %(s = "hi"\ns.upcase\nputs s),
           hint: "Does upcase change s, or return a new string?",
           explain: "upcase returns a NEW string; s itself is unchanged, so it prints hi."

    output %(s = "hi".dup\ns.upcase!\nputs s),
           explain: "upcase! (with a bang) changes s itself, so it prints HI. (.dup just makes an editable copy.)"

    choice "A method named valid? most likely returns…",
           ["a String", "true or false", "nothing", "an Array"], answer: 1,
           explain: "By convention, methods ending in ? answer a yes/no question."

    write "Define a method called double that takes a number and returns it multiplied by 2.",
          solution: "def double(n) = n * 2",
          check: ->(run) { run.("", "double(21)").value == 42 && run.("", "double(-3)").value == -6 },
          hint: "def double(n); n * 2; end",
          explain: "def double(n); n * 2; end — or the newer one-liner style: def double(n) = n * 2"
  end

  lesson "Blocks: map, select, reduce" do
    intro <<~'TEXT'
      Ruby's superpower is transforming collections with blocks:

          [1, 2, 3].map { |n| n * 2 }           # => [2, 4, 6]   transform each
          [1, 2, 3, 4].select { |n| n.even? }   # => [2, 4]      keep matching
          [1, 2, 3, 4].reject { |n| n.even? }   # => [1, 3]      drop matching
          [5, 8, 12].find { |n| n > 6 }         # => 8           first match
          [1, 2, 3].reduce(0) { |sum, n| sum + n }  # => 6       combine all

      When the block just calls one method, there's a shortcut:
          ["a", "b"].map(&:upcase)              # => ["A", "B"]
    TEXT

    value "[1, 2, 3].map { |n| n * 10 }",
          explain: "map builds a new Array from what the block returns for each item."

    value "[1, 2, 3, 4, 5, 6].select { |n| n.even? }",
          explain: "select keeps items where the block is true."

    value "[1, 2, 3, 4].reject(&:even?)",
          hint: "&:even? is short for { |n| n.even? }",
          explain: "reject removes items where the block is true, leaving the odd ones."

    value '["cat", "elephant", "dog"].find { |w| w.length > 3 }',
          explain: "find returns the FIRST item that matches — just one item, not an Array."

    value "[1, 2, 3, 4].reduce(0) { |sum, n| sum + n }",
          hint: "sum starts at 0, then each n is added in.",
          explain: "0+1=1, 1+2=3, 3+3=6, 6+4=10."

    value '["apple", "kiwi"].map(&:length)',
          explain: "map(&:length) calls .length on each word: 5 and 4."

    write "Given words (an array of strings), return an array of just the words longer than 3 letters.",
          solution: "words.select { |w| w.length > 3 }",
          check: lambda { |run|
            run.('words = ["ruby", "is", "very", "fun"]').value == %w[ruby very] &&
              run.('words = ["a", "longer"]').value == %w[longer]
          },
          hint: "select with a block that checks w.length > 3",
          explain: "words.select { |w| w.length > 3 } keeps only the long words."
  end

  lesson "Classes and objects" do
    intro <<~'TEXT'
      Everything in Ruby is an object, and every object has a class:
          5.class         # => Integer
          "hi".class      # => String

      You can make your own classes — blueprints for objects:

          class Dog
            attr_reader :name           # creates a name method to read @name

            def initialize(name)        # runs when you call Dog.new
              @name = name              # @name is an instance variable:
            end                         # each dog remembers its own

            def bark
              "#{@name} says woof!"
            end
          end

          rex = Dog.new("Rex")
          rex.bark        # => "Rex says woof!"
    TEXT

    value '"hello".class',
          explain: "Text in quotes is an instance of the String class."

    output %(class Dog\n  def initialize(name)\n    @name = name\n  end\n\n  def bark\n    "\#{@name} says woof!"\n  end\nend\n\nputs Dog.new("Rex").bark),
           explain: "Dog.new(\"Rex\") calls initialize, storing \"Rex\" in @name; bark uses it."

    choice "What does attr_accessor :age give you?",
           ["Only a way to read age", "Only a way to set age", "Both a reader (age) and a writer (age=)", "A class method"],
           answer: 2,
           explain: "attr_reader = read only, attr_writer = write only, attr_accessor = both."

    output %(class Counter\n  def initialize\n    @count = 0\n  end\n\n  def tick\n    @count += 1\n  end\nend\n\nc = Counter.new\nc.tick\nc.tick\nputs c.tick),
           hint: "@count is remembered between calls.",
           explain: "Each tick adds 1 to the same @count: 1, 2, 3 — and the third call returns 3."

    output %(class Animal\n  def speak = "..."\nend\n\nclass Cat < Animal\n  def speak = "Meow"\nend\n\nputs Cat.new.speak),
           hint: "< means \"inherits from\".",
           explain: "Cat inherits from Animal but defines its own speak, which wins."

    write "Define a class Light whose objects start off. Give it a toggle method that flips it and an on? method " \
          "that returns true or false.",
          solution: "class Light; def initialize; @on = false; end; def toggle; @on = !@on; end; def on?; @on; end; end",
          check: lambda { |run|
            run.("", "l = Light.new; l.on?").value == false &&
              run.("", "l = Light.new; l.toggle; l.on?").value == true &&
              run.("", "l = Light.new; l.toggle; l.toggle; l.on?").value == false
          },
          hint: "In initialize set @on = false; toggle does @on = !@on; on? just returns @on.",
          explain: "Instance variables like @on let each object remember its own state."
  end

  lesson "nil, truthiness and errors" do
    intro <<~'TEXT'
      nil is Ruby's "nothing". In conditions, ONLY nil and false count as false.
      Everything else — including 0 and "" — is "truthy".

      || is handy for defaults:   name = nil;  name || "guest"   # => "guest"
      &. calls a method only if the object isn't nil:   nil&.upcase  # => nil

      When something goes wrong, Ruby raises an error. You can catch it:

          begin
            Integer("abc")
          rescue ArgumentError
            puts "That's not a number!"
          end
    TEXT

    value %(x = 0\nx ? "truthy" : "falsy"),
          hint: "Only two values in Ruby count as false.",
          explain: "0 is truthy in Ruby (unlike some other languages). Only nil and false are falsy."

    value "nil.to_a",
          explain: "nil can be converted: nil.to_a is [], nil.to_s is \"\"."

    value %(nickname = nil\nnickname || "guest"),
          explain: "nil is falsy, so || falls through to \"guest\"."

    value "nil&.upcase",
          explain: "&. (the safe navigation operator) skips the call when the object is nil."

    choice "Which of these values is falsy in Ruby?",
           ["0", '""', "[]", "nil"], answer: 3,
           explain: "Only nil and false are falsy. 0, \"\" and [] are all truthy."

    output %(begin\n  puts 10 / 0\nrescue ZeroDivisionError\n  puts "Can't divide by zero"\nend),
           explain: "10 / 0 raises ZeroDivisionError, so the rescue branch runs."

    write "Given input (a String that may or may not be a number), return its Integer value, or 0 if " \
          "Integer(input) raises an error.",
          solution: "begin; Integer(input); rescue ArgumentError; 0; end",
          check: ->(run) { run.('input = "42"').value == 42 && run.('input = "abc"').value.zero? },
          hint: "begin; Integer(input); rescue ArgumentError; 0; end",
          explain: "begin/rescue lets your program recover from errors instead of crashing."
  end
end
