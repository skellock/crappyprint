[![CircleCI](https://circleci.com/gh/skellock/crappyprint.svg?style=svg)](https://circleci.com/gh/skellock/crappyprint)

# What is `crappyprint`?

A [`nim`](https://nim-lang.org) library to build your own terminal printing DSLs.

# Basic Example

```nim
import terminal, crappyprint

newPrint()                            # spin it up & start chaining...
  .text("We're ")                     # normal text
  .text("no ", style={styleBright})   # different styles
  .text("strangers to ")
  .text("love", fg=fgWhite, bg=bgRed) # different colours
  .text(".")
  .enter()                            # next line
```

Nothing too exciting here, eh?

# Stateful Example

You can make changes to colors, styles, or indentation.

```nim
import terminal, crappyprint

newPrint(spacesPerIndent=4)
  .bright()              # any text will now be bold
  .fg(fgYellow)          # and yellow
  .text("Never gonna:")
  .enter()
  .bright(false)         # text will no longer be bold
  .fg(fgDefault)         # text will be the default terminal color

  .indent()  # <-- from now on, new lines will be indented by 4 spaces

  .text("give you up").enter()
  .text("let you down").enter()
  .text("run around and desert you").enter(2)

  .indent(0) # <-- restores original indentation
```

# Composition Example

The previous example is pretty messy right?

Let's clean that up by making 2 functions; `title()` and `bullet()`:

```nim
import terminal, crappyprint

proc title(print: Print, text: string): Print =
  ## Make the list title reusable.
  print
    .text(text, style={styleBright}, fg=fgYellow)
    .text(":", style={styleDim})
    .enter()
    .indent()

proc bullet(print: Print, text: string): Print =
  ## Make a bullet line reusable.
  print
    .text("* ", fg=fgGreen)
    .text(text)
    .enter()
```

With those 2 functions in play, here's what the previous example looks like now...

```nim
newPrint(spacesPerIndent=4)
  .title("Never gonna")
  .bullet("give you up")
  .bullet("let you down")
  .bullet("run around and desert you")
  .enter()
  .indent(0)
```

To introduce your own chainable functions, you create a function whose first parameter is `Print` and the return value is also `Print`. I recommend adding the `{.discardable.}` pragma too. For example:

```nim
proc hr*(print: Print): Print {.discardable.} =
  ## Prints a fancy line divider.
  print
    .text("-=-=-=-=-=-=-=-", style={styleBright}, fg=fgBlue)
    .enter()
```

See [this code](examples/rick.nim) for a larger example.

# Principles

- programs should make their own styling functions (like a style guide)
- don't reinvent colors and style from `terminal`
- terminal printing is already stateful; so embrace that

# API

### `newPrint(target=stdout, spacesPerIndent=2)`

Returns a `Print` object used to chain styling functions.

| argument       | type   | description                                                      | default  |
| -------------- | ------ | ---------------------------------------------------------------- | -------- |
| target         | `File` | optional: where to write to                                      | `stdout` |
| spacePerIndent | `int`  | optional: how many spaces are printed for each indentation level | `2`      |

```nim
let print = newPrint()
```

### `.text(value, fg=fgDefault, bg=bgDefault, style={}, indentBy=0)`

Prints text. You'll be using this one frequently.

| argument | type              | description                                                                  | default     |
| -------- | ----------------- | ---------------------------------------------------------------------------- | ----------- |
| value    | `string`          | the text to print                                                            | -           |
| fg       | `ForegroundColor` | optional: applies a foreground color to the text                             | `fgDefault` |
| bg       | `BackgroundColor` | optional: applies a background color to the text                             | `bgDefault` |
| style    | `set[Style]`      | optional: applies styling (`styleBright` for example) to the text            | `{}`        |
| indentBy | `int`             | optional: overrides the current indentation with a specific number of spaces | `0`         |

```nim
newPrint()
  .text("Say ")
  .text("hello ", style={styleBold})
  .text("to my", fg=bgGreen)
  .text(" little friend!", bg=bgBlue, fg=fgWhite)
```

### `.fg(color)`

Changes the foreground color.

| argument  | type              | description                                                  |
| --------- | ----------------- | ------------------------------------------------------------ |
| **color** | `ForegroundColor` | applies a foreground color to any text written in the future |

```nim
newPrint()
  .text("Days since last accident: ")
  .fg(fgRed)     # <-- red text
  .text("0")
  .fg(fgDefault) # <-- normal text
  .text(".")
```

### `.bg(color)`

Changes the background color.

| argument  | type              | description                                                  |
| --------- | ----------------- | ------------------------------------------------------------ |
| **color** | `BackgroundColor` | applies a background color to any text written in the future |

```nim
newPrint()
  .text("Don't cry for me, Argentina.").enter(2)
  .bg(bgCyan)  # <-- cyan
  .text("           ").enter()
  .bg(bgWhite) # <-- then white
  .fg(fgYellow)
  .bright()
  .text("     *     ").enter()
  .bg(bgCyan)  # <-- then back to cyan
  .text("           ").enter()
```

### `.indent(level)`

Changes the indentation level so text will be inset from the left on each line.

| argument  | type  | description                         | default |
| --------- | ----- | ----------------------------------- | ------- |
| **level** | `int` | how many levels we should move over | `1`     |

By default (see: `newPrint()`), there are `2` spacers for every `1` level of indenting.

```nim
newPrint()
  .text("Dear Diary,").enter(2)
  .indent() # <-- move future text to the right (2 spaces)
  .text("I love nim.").enter(2)
  .indent(-1) # <-- sets the indentation back
  .text("Love, ").enter(2)
  .text("Steve")
```

### `.space(count)`

Adds horizontal whitespace.

| argument  | type  | description                 | default |
| --------- | ----- | --------------------------- | ------- |
| **count** | `int` | the number of spaces to add | `1`     |

```nim
newPrint()
  .space(81) # <-- adds some spaces
  .text("the forbidden zone!")
```

### `.enter(count)`

Moves to the next line.

| argument  | type  | description                | default |
| --------- | ----- | -------------------------- | ------- |
| **count** | `int` | the number of lines to add | `1`     |

```nim
newPrint()
  .text("Patience...")
  .enter(4000) # <-- RIP your terminal
  .text("is a virtue.")
```

### `.bright(on)`

Makes subsequent text be bright/bold.

| argument | type   | description                      | default |
| -------- | ------ | -------------------------------- | ------- |
| **on**   | `bool` | should this style setting be on? | `true`  |

You can turn this off again with `.bright(off)`.

```nim
newPrint()
  .bright()      # <-- on
  .text("twinkle twinkle")
  .bright(false) # <-- off
  .text("little star")
```

### `.dim(on)`

Makes subsequent text be dim.

| argument | type   | description                      | default |
| -------- | ------ | -------------------------------- | ------- |
| **on**   | `bool` | should this style setting be on? | `true`  |

You can turn this off again with `.dim(off)`.

```nim
newPrint()
  .text("867-5309")
  .dim()      # <-- on
  .text("/ Jenny")
  .dim(false) # <-- off
```

# Why not use this?

- the `terminal` module is already great
- your program doesn't print much styled text
- this library does very little

# Changelog

**`0.1.0`** - Jan 21, 2019

- Initial release

# Requirements

- Nim 0.19.2+

# Installing

`nimble install https://github.com/skellock/crappyprint#head`

( NOTE: I haven't submitted this to `nimble` just yet. )

# TODOs

- [ ] make CI work on `nim@0.19.2`
- [ ] in `text()`, make `fg`, `bg`, and `style` changes independent from each other
- [ ] support for "\n" characters when using `text()`
- [ ] finish testing all functions
- [ ] support windows (not sure what's involved)
- [ ] show more examples of control flow
- [ ] change name of library?
- [ ] submit to nimble

# License

MIT.

# Contributing

Fork it. Pull it. Patch it. Push it.

Send a PR, that should do it.
