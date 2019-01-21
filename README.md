# crappyprint 💩

[![CircleCI](https://circleci.com/gh/skellock/crappyprint.svg?style=svg)](https://circleci.com/gh/skellock/crappyprint)

A [`nim`](https://nim-lang.org) package for printing stuff to the terminal with a fluent-style interface.

# Installing

`nimble install https://github.com/skellock/crappyprint`

# Usage

```nim
# hello.nim
import terminal, crappyprint

newPrint()                            # spin it up & start chaining...
  .text("We're ")                     # plain text
  .text("no ", style={styleBright})   # adding styles (dim, bright, underline, etc)
  .text("strangers to ")
  .text("love", fg=fgWhite, bg=bgRed) # changing colours
  .text(".")
  .enter()                            # moving to the next line
```

At this point, we're doing the same thing as `styledWrite` from the `terminal` module.

Let's say you need to indent.

```nim
# indent.nim
import terminal, crappyprint

newPrint()
  .text("Never gonna:", style={styleBright}).enter()
  .indent()  # <-- from now on, every line will be indented
  .text("give you up").enter()
  .text("let you down").enter()
  .text("run around and desert you").enter(2)
  .unindent()
```

But thing I like the most about this approach is that it's composable.

```nim
# composing.nim
import terminal, crappyprint

proc title(print: Print, text: string): Print =
  ## Make the list title reusable.
  print
    .text(text, style={styleBright})
    .text(":", style={styleDim})
    .enter()
    .indent()

proc bullet(print: Print, text: string): Print =
  ## Make a bullet line reusable.
  print
    .text("* ", fg=fgGreen)
    .text(text)
    .enter()

# which simplifies our previous example a bit
newPrint()
  .title("Never gonna")
  .bullet("give you up")
  .bullet("let you down")
  .bullet("run around and desert you")
  .enter()
  .unindent()
```


# License

MIT.

# Contributing

Fork it. Pull it. Patch it. Push it.

Send a PR, that should do it.
