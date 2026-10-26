# Ruby Quest 💎

An interactive terminal game that teaches Ruby from the very beginning.
It explains a concept, asks you questions, checks your answers by actually
running Ruby, and corrects you with an explanation when you get one wrong.

There are two ways to play, built from the same lessons:

- **In a browser**: a web page with a scratchpad for each lesson. A real Ruby
  (ruby.wasm) runs in the page to check your code.
- **In a terminal**: the original text game.

```sh
ruby learn/web/build.rb               # build the web page into learn/web/dist/
ruby learn/ruby_quest.rb              # play in the terminal (needs Ruby 3.0+)
ruby learn/ruby_quest.rb --reset      # forget saved progress
ruby learn/ruby_quest.rb --self-test  # verify every question's answer key
```

## How it works

- 12 lessons, from `puts "Hello"` to classes and error handling.
- Four question types: *what does this print?*, *what does this return?*,
  multiple choice, and *write the code* (your code is run and tested).
- Two tries per question: 2 points first time, 1 point second time.
  Type `hint`, `skip` or `quit` at any question.
- Progress is saved in `~/.ruby_quest_progress.json`.

## Lessons

1. Hello, Ruby — `puts`, `print`, strings, comments
2. Numbers and math
3. Variables
4. Working with strings — interpolation, methods, conversion
5. True, false and `if`
6. Arrays
7. Hashes and symbols
8. Loops and ranges
9. Methods
10. Blocks: `map`, `select`, `reduce`
11. Classes and objects
12. `nil`, truthiness and errors

Add your own questions in `lessons.rb`, run `--self-test` to check them, then
rebuild the web page. `learn/web/dist/` holds `index.html` and `ruby.gz.wasm`
(downloaded from npm on the first build); serve or publish them side by side.
