import terminal, streams, unittest # stdlib
import crappyprint # project


# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)


proc sp(spaces = 1): Print {.discardable.} =
    newStringPrint(spacesPerIndent = spaces)


suite "text":
    test "empty":
        let p = sp().text()
        check $p == ""

    test "normal text":
        let p = sp().text("hi")
        check $p == "hi"

    test "supports 1-off indentation":
        let p = sp().text("a").enter().text("b", indentBy = 2).enter().text("c")
        check $p == "a\l  b\lc"


suite "enter":
    test "enter produces line breaks":
        let p = sp().text("hi").enter().enter(3)
        check $p == "hi\l\l\l\l"


suite "space":
    test "space makes spaces":
        let p = sp().space().space(4)
        check $p == "     "


suite "indent":
    test "does nothing alone":
        let p = sp().indent()
        check $p == ""

    test "indents subsequent text":
        let p = sp().indent.text("a")
        check $p == " a"

    test "survives new lines":
        let p = sp().indent.enter.text("a").enter().text("b")
        check $p == "\l a\l b"

    test "doesn't affect text already printed":
        let p = sp().text("hi").indent()
        check $p == "hi"

    test "can't have negative numbers":
        let p = sp().indent(-1).text("a")
        check $p == "a"

    test "can be called many times":
        let p = sp().indent().indent().text("a")
        check $p == "  a"

    test "can be passed an int for multiple indents":
        let p = sp().indent(4).text("a")
        check $p == "    a"

    test "can use negative numbers to unindent":
        let p = sp().indent(3).indent(-2).text("a")
        check $p == " a"


suite "unindent":
    test "goes back":
        let p = sp().indent(3).unindent().text("a")
        check $p == "  a"

    test "accepts an int for multiple unindents":
        let p = sp().indent(3).unindent(2).text("a")
        check $p == " a"

    test "with a negative number indents instead":
        let p = sp().unindent(-1).text("a")
        check $p == " a"

suite "reset":
    test "resets indentation to 0":
        let p = sp().indent().text("a").enter().reset().text("b")
        check $p == " a\lb"


suite "non-styling targets":
    test "newStringPrint won't style with terminal characters":
        let p = sp().fg(fgRed).dim.text("hi")
        check $p == "hi"

    test "newStreamPrint won't style with terminal characters":
        var ss = newStringStream()
        defer: ss.close()
        let p = newStreamPrint(ss).fg(fgRed).dim.text("hi")
        ss.setPosition 0
        check ss.readAll == "hi"


suite "File targets":
    test "colors in files":
        template expectFile(expected: string, body: untyped): untyped {.dirty.} =
            block:
                let filename = "tests/output"
                var file = open(filename, fmReadWrite)
                try:
                    discard body
                finally:
                    file.close()

                let content = readFile(filename)
                check content == expected

        # foreground text color
        expectFile "\e[31mhello\e[39m":
            newFilePrint(file).text("hello", fg = fgRed)

        # background text color
        expectFile "\e[41mhello\e[49m":
            newFilePrint(file).text("hello", bg = bgRed)
