# crappyprint 💩

[![CircleCI](https://circleci.com/gh/skellock/crappyprint.svg?style=svg)](https://circleci.com/gh/skellock/crappyprint)

A stateful & composable terminal printing package for [`nim`](https://nim-lang.org).

# Requirements

* Nim 0.19.2+


# Installing

`nimble install https://github.com/skellock/crappyprint`

( NOTE: I haven't submitted this to `nimble` just yet. )


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
Here's where things start to get interesting.

The previous example is pretty messy right? Let's clean that up by making some composable styling functions.

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

# here's what the previous example looks like now...
newPrint(spacesPerIndent=4)
  .title("Never gonna")
  .bullet("give you up")
  .bullet("let you down")
  .bullet("run around and desert you")
  .enter()
  .indent(0)
```

To introduce your own chainable functions, you create a function whose first parameter is `Print` and the return value is also `Print`. For example:

```nim
proc hr*(print: Print): Print =
  ## Prints a fancy line divider.
  print
    .text("-=-=-=-=-=-=-=-", style={styleBright}, fg=fgBlue)
    .enter()
```


# Principles

* programs should make their own styling functions (like a style guide)
* don't reinvent colors and style from `terminal`
* terminal printing is already stateful; so embrace that

# API

#### `newPrint(target, spacesPerIndent)`

Returns a `Print` object used to chain styling functions.

| argument           | type   | description                                                      | default  |
| ------------------ | ------ | ---------------------------------------------------------------- | -------- |
| **target**         | `File` | optional: where to write to                                      | `stdout` |
| **spacePerIndent** | `int`  | optional: how many spaces are printed for each indentation level | `2`      |

```nim
let print = newPrint()
```

#### `.text(value, fg, bg, style, indentBy)`

Prints text. You'll be using this one frequently.

| argument     | type              | description                                                                  | default     |
| ------------ | ----------------- | ---------------------------------------------------------------------------- | ----------- |
| **value**    | `string`          | the text to print                                                            | -           |
| **fg**       | `ForegroundColor` | optional: applies a foreground color to the text                             | `fgDefault` |
| **bg**       | `BackgroundColor` | optional: applies a background color to the text                             | `bgDefault` |
| **style**    | `set[Style]`      | optional: applies styling (`styleBright` for example) to the text            | `{}`        |
| **indentBy** | `int`             | optional: overrides the current indentation with a specific number of spaces | `0`         |


#### `.fg(color)`

Changes the foreground color.

| argument  | type              | description                                                  |
| --------- | ----------------- | ------------------------------------------------------------ |
| **color** | `ForegroundColor` | applies a foreground color to any text written in the future |


```nim
newPrint()
  .text("Days since last accident: ")
  .fg(fgRed)
  .text("0")
  .fg(fgDefault)
  .text(".")
```

#### `.bg(color)`

Changes the background color.

| argument  | type              | description                                                  |
| --------- | ----------------- | ------------------------------------------------------------ |
| **color** | `ForegroundColor` | applies a foreground color to any text written in the future |

```nim
newPrint()
  .text("Don't cry for me, Argentina.").enter(2)
  .bg(bgCyan)
  .text("           ").enter()
  .bg(bgWhite)
  .fg(fgYellow)
  .bright()
  .text("     *     ").enter()
  .bg(bgCyan)
  .text("           ").enter()
```

# License

MIT.


# Contributing

Fork it. Pull it. Patch it. Push it.

Send a PR, that should do it.
