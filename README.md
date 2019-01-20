# crappyprint 💩

[![CircleCI](https://circleci.com/gh/skellock/crappyprint.svg?style=svg)](https://circleci.com/gh/skellock/crappyprint)

A crappy [`nim`](https://nim-lang.org) package for printing stuff to the terminal.

# Installing

`nimble install https://github.com/skellock/crappyprint`

# Usage

```nim
import crappyprint

crappyPrint()
  .text("We're ")
  .text("no ", style={styleDim})
  .text("strangers to ")
  .text("love", fg=fgWhite, bg=bgRed)
  .text(".").enter()

  .text("You know the rules")
  .text(" and so do I")
  .enter()

  .enter(3)
```

# License

MIT.

# Contributing

Fork it. Pull it. Patch it. Push it.

Send a PR, that should do it.
