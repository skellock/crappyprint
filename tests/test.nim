import terminal # stdlib
import crappyprint # project
import verify # testing

# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)

template expect(expected: string, body: untyped): untyped {.dirty.} =
    ## A janky boilerplate-avoidance function to check that the expected
    ## content is being generated.
    ##
    ## I really don't like that I had to use {.dirty.} for this because
    ## it forces me to use `block:` down below.
    ##
    ## It is better than what I had before though.
    ##
    ## I'm just not sure how to pass the `file` back to the body. I'd love to
    ## find a way to not have to touch the filesystem at all.
    ##
    ## Halp!
    block:
      let
          filename = "tests/output"
          file = open(filename, fmReadWrite)
      try:
          discard body
      finally:
          file.close()

      # The stackOffset is a hack that will capture the source of the error
      # and not the next line of code: verify(...). I do this because this
      # is a template.
      #
      # If you use verify() outside a template, you can leave
      # this parameter off since the default is 1.
      let content = readFile(filename)
      verify(content, expected, stackOffset=2)


# normal text
expect "hello":
    newPrint(file).text("hello")

# line breaks
expect "hi\n\n\n\n":
    newPrint(file).text("hi").enter().enter(3)

# foreground text color
expect "\e[31m\e[49mhello\e[0m\e[0m":
    newPrint(file).text("hello", fg=fgRed)

# background text color
expect "\e[39m\e[41mhello\e[0m\e[0m":
    newPrint(file).text("hello", bg=bgRed)

# indentation
expect "  a\nb\n    c\nd\ne":
    newPrint(file, spacesPerIndent=2)
        .indent()    # over 1
        .text("a").enter()
        .indent(-1)  # back 1
        .text("b").enter()
        .indent(2)   # over 2
        .text("c").enter()
        .indent(0)   # reset
        .text("d").enter()
        .indent(-69) # minimum of 0
        .text("e")

# indent during text
expect "  hello":
    newPrint(file).text("hello", indentBy=2)

# space
expect "     ":
    newPrint(file).space().space(4)

# enter
expect "\n\n\n\n\n":
    newPrint(file).enter().enter(4)
