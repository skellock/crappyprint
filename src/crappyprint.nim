import terminal, strutils, sets # stdlib

system.addQuitProc(resetAttributes)

type
    PrintStyle = object
        ## Styling information
        name: string        ## the name of the style (currently unused)
        style: set[Style]   ## the terminal style
        fg: ForegroundColor ## the terminal foreground color
        bg: BackgroundColor ## the terminal background color
        indentBy: int       ## how many spaces are we over?

    Print* = ref object
        ## For printing text out on the terminal.
        target*: File        ## The file we're writing to (e.g. stdout).
        current: PrintStyle  ## The style we're currently set to.
        spacesPerIndent: int ## How many spaces per indent?
        isLineIndented: bool ## Have we already applied indentation for this line?


proc applyStyle(print: Print, style: PrintStyle): Print {.discardable.} =
    ## Bestows the proper colors and style onto the underlying file (e.g. stdout).
    result = print
    print.target.setForegroundColor(style.fg)
    print.target.setBackgroundColor(style.bg)
    print.target.setStyle(style.style)


proc applyCurrentStyle(print: Print): Print {.discardable.} =
    ## Reapplies whatever is on the top of the style stack
    result = print.applyStyle(print.current)


proc indent*(print: Print, levels=1): Print {.discardable.} =
    ## Increases indentation.
    result = print
    for i in 1..levels:
        print.current.indentBy += print.spacesPerIndent


proc dedent*(print: Print, levels=1): Print {.discardable.} =
    ## Decreases indentation.
    result = print
    for i in 1..levels:
        print.current.indentBy -= print.spacesPerIndent


proc unindent*(print: Print): Print {.discardable.} =
    result = print
    print.current.indentBy = 0


proc reset*(print: Print): Print {.discardable.} =
    ## Resets us back to the original state.
    result = print
    print.isLineIndented = false
    print.current = PrintStyle(
        name: "root",
        style: {},
        fg: fgDefault,
        bg: bgDefault,
        indentBy: 0,
        )
    print.target.resetAttributes()
    # print.applyCurrentStyle()


proc bright*(print: Print, on = true): Print {.discardable.} =
    ## Makes the current style bright.
    result = print
    if on:
        print.current.style.incl(styleBright)
    else:
        print.current.style.excl(styleBright)

    print.applyCurrentStyle()


proc dim*(print: Print, on = true): Print {.discardable.} =
    ## Makes the current style dim.
    result = print
    if on:
        print.current.style.incl(styleDim)
    else:
        print.current.style.excl(styleDim)

    print.applyCurrentStyle()


proc fg*(print: Print, color: ForegroundColor): Print {.discardable.} =
    ## Sets the foreground color.
    result = print
    print.current.fg = color
    print.target.setForegroundColor(color)
    # print.applyCurrentStyle()


proc bg*(print: Print, color: BackgroundColor): Print {.discardable.} =
    result = print
    print.current.bg = color
    print.applyCurrentStyle()


proc space*(print: Print, count=1): Print {.discardable.} =
    ## Writes a space.
    result = print
    for i in 1..count:
        print.target.write(" ")

proc text*(
    print: Print,
    text: string,
    style: set[Style] = {},
    fg: ForegroundColor = fgDefault,
    bg: BackgroundColor = bgDefault,
    indentBy = 0,
): Print {.discardable.} =
    ## Writes some text on the screen.
    result = print

    var hasChanges = false
    if fg != fgDefault or bg != bgDefault or style != {}:
        # we need to temporarily change the style, fg or bg
        var tempStyle = print.current
        hasChanges = true
        tempStyle.style = style
        tempStyle.fg = fg
        tempStyle.bg = bg
        print.applyStyle(tempStyle)

    # indentation
    if indentBy > 0:
        # we need to temporarily change the indentation
        print.space(indentBy)
        print.isLineIndented = true
    elif not print.isLineIndented and print.current.indentBy > 0:
        # apply the indentation if we've already set it
        print.space(print.current.indentBy)
        print.isLineIndented = true

    # write the text
    print.target.write(text)

    # revert the style changes (if any)
    if hasChanges:
        print.applyCurrentStyle()


proc enter*(print: Print, count=1): Print {.discardable.} =
    ## Advances to the next line.
    result = print
    print.isLineIndented = false
    for i in 1..count:
        print.target.writeLine("")


func newPrint*(target: File = stdout, spacesPerIndent = 4): Print =
    new result
    result.current.name = "root"
    result.target = target
    result.spacesPerIndent = spacesPerIndent
