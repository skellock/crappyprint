import os, strutils, terminal

type
    Pos = tuple [filename: string, line: int, column: int]

template errLine(body: untyped) =
    ## Surrounds any output with an error prefix.
    stdout.styledWrite styleBright, fgRed, "✖︎  "
    body
    stdout.writeLine ""

template blankErrLine() =
    ## Prints a blank line, but with an error prefix.
    errLine:
        discard

proc section(value: string) =
    ## Prints a section header.
    errLine:
        stdout.styledWrite styleDim, "$1" % value
    blankErrLine()

proc printAssertionFailure[T](actualValue, expectedValue: T, pos: Pos) =
    ## Prints a nicer looking error message.
    let
        filename = os.getAppDir() / pos.filename
        content = readFile(filename)
        lines = content.splitLines()
        line = lines[pos.line - 1]
        lineNumberSize = (pos.line + 1).intToStr.len
        columnNumberSize = (pos.column).intToStr.len

    stdout.flushFile()
    stdout.writeLine ""
    errLine:
        stdout.styledWrite styleDim, "Test failed in "
        stdout.styledWrite "👑"
        stdout.styledWrite fgYellow, styleBright, pos.filename
        stdout.styledWrite styleDim, " on line "
        stdout.styledWrite fgYellow, styleBright, $pos.line
        stdout.styledWrite styleDim, " column "
        stdout.styledWrite fgYellow, styleBright, $pos.column
        stdout.styledWrite ".", styleDim

    errLine:
        stdout.styledWrite styleDim, "~".repeat(70)


    # the line before
    if pos.line - 3 >= 0:
        errLine:
            stdout.styledWrite styleDim, "  $1|  " % $(pos.line - 2)
            stdout.styledWrite lines[pos.line - 3]

    # the line before
    if pos.line - 2 >= 0:
        errLine:
            stdout.styledWrite styleDim, "  $1|  " % $(pos.line - 1)
            stdout.styledWrite lines[pos.line - 2]

    # the target line
    errLine:
        stdout.styledWrite fgYellow, styleBright, "  $1|  " % $pos.line
        stdout.styledWrite fgYellow, styleBright, "$1 " % line

    # the line after
    if pos.line < lines.len:
        errLine:
            stdout.styledWrite styleDim, "  $1|  " % $(pos.line + 1)
            stdout.styledWrite lines[pos.line]
    
    # the line after
    if pos.line + 1 < lines.len:
        errLine:
            stdout.styledWrite styleDim, "  $1|  " % $(pos.line + 2)
            stdout.styledWrite lines[pos.line + 1]

    blankErrLine()

    let actual = $actualValue
    let expected = $expectedValue

    if actual.len < 30 and expected.len < 30:
        # shorter content gets a more compact layout
        errLine:
            stdout.styledWrite styleDim, "Actual".alignLeft(10)
            stdout.styledWrite actual
        errLine:
            stdout.styledWrite styleDim, "Expected".alignLeft(10)
            stdout.styledWrite expected
          
    else:
        section "Actual"
        errLine:
            stdout.styledWrite "    $1" % actual
        blankErrLine()

        section "Expected"
        errLine: stdout.styledWrite "    $1" % $expected

    stdout.writeLine ""
    stdout.flushFile()


template verify*(actual, expected: untyped): untyped =
    try:
        # perform the assertion
        doAssert actual == expected
    except AssertionError:
        # if there was an assertion error, capture the position
        let pos = instantiationInfo()
        # and pass it to a pretty print function
        printAssertionFailure actual, expected, pos
        raise
