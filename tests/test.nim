import terminal, streams, unittest # stdlib
import crappyprint # project
import verify # testing

# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)

proc sp(spaces = 1): Print =
    result = newStringPrint(spacesPerIndent = spaces)


suite "text()":
    test "empty":
        let p = sp().text()
        verify $p, ""

    test "normal text":
        let p = sp().text("hi")
        verify $p, "hi"

    test "supports 1-off indentation":
        let p = sp().text("a").enter().text("b", indentBy = 2).enter().text("c")
        verify $p, "a\l  b\lc"


suite "enter()":
    test "enter() produces line breaks":
        let p = sp().text("hi").enter().enter(3)
        verify $p, "hi\l\l\l\l"


suite "space()":
    test "space() makes spaces":
        let p = sp().space().space(4)
        verify $p, "     "


suite "indent()":
    test "does nothing alone":
        let p = sp().indent()
        verify $p, ""

    test "indents subsequent text":
        let p = sp().indent.text("a")
        verify $p, " a"

    test "survives new lines":
        let p = sp().indent.enter.text("a").enter().text("b")
        verify $p, "\l a\l b"

    test "doesn't affect text already printed":
        let p = sp().text("hi").indent()
        verify $p, "hi"

    test "can't have negative numbers":
        let p = sp().indent(-1).text("a")
        verify $p, "a"

    test "can be called many times":
        let p = sp().indent().indent().text("a")
        verify $p, "  a"

    test "can be passed an int for multiple indents":
        let p = sp().indent(4).text("a")
        verify $p, "    a"

    test "can use negative numbers to unindent":
        let p = sp().indent(3).indent(-2).text("a")
        verify $p, " a"


suite "unindent()":
    test "goes back":
        let p = sp().indent(3).unindent().text("a")
        verify $p, "  a"

    test "accepts an int for multiple unindents":
        let p = sp().indent(3).unindent(2).text("a")
        verify $p, " a"

    test "with a negative number indents instead":
        let p = sp().unindent(-1).text("a")
        verify $p, " a"

suite "reset()":
    test "resets indentation to 0":
        let p = sp().indent().text("a").enter().reset().text("b")
        verify $p, " a\lb"


suite "non-styling targets":
    test "newStringPrint() won't style with terminal characters":
        let p = sp().fg(fgRed).dim.text("hi")
        verify $p, "hi"

    test "newStreamPrint() won't style with terminal characters":
        var ss = newStringStream()
        defer: ss.close()
        let p = newStreamPrint(ss).fg(fgRed).dim.text("hi")
        ss.setPosition 0
        verify ss.readAll, "hi"


suite "File targets":

    template expectFile(expected: string, body: untyped): untyped {.dirty.} =
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
            let filename = "tests/output"
            var file = open(filename, fmReadWrite)
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
            verify(content, expected, stackOffset = 2)

    # foreground text color
    expectFile "\e[31mhello\e[39m":
        newFilePrint(file).text("hello", fg = fgRed)

    # background text color
    expectFile "\e[41mhello\e[49m":
        newFilePrint(file).text("hello", bg = bgRed)
