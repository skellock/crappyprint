import terminal, strutils # stdlib

system.addQuitProc(resetAttributes)

type
    PrintStyle = object
        ## Styling information
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
    ## Reapplies whatever is on the top of the style stack.
    result = print.applyStyle(print.current)


proc indent*(print: Print, levels=1): Print {.discardable.} =
    ## Changes the indentation for new lines. Levels indicates the number
    ## of indendations to apply and not the number of spaces.
    ##
    ## If the number is positive, the indentation will go to the right.
    ##
    ## If the number is negative, the indentation will go back to the left.
    ##
    ## If the number is 0, indentation is reset.
    result = print
    if levels > 0:
        for i in 1..levels:
            print.current.indentBy += print.spacesPerIndent
    elif levels < 0:
        for i in 1..(levels * -1):
            print.current.indentBy -= print.spacesPerIndent
        # minimum of 0
        if print.current.indentBy < 0:
            print.current.indentBy = 0
    elif levels == 0:
        print.current.indentBy = 0


proc reset*(print: Print): Print {.discardable.} =
    ## Resets us back to the original state.
    result = print
    print.isLineIndented = false
    print.current = PrintStyle(
        style: {},
        fg: fgDefault,
        bg: bgDefault,
        indentBy: 0,
        )
    print.target.resetAttributes()


proc bright*(print: Print, on = true): Print {.discardable.} =
    ## Makes the current style bright.
    result = print
    if on:
        print.current.style.incl(styleBright)
    else:
        print.current.style.excl(styleBright)

    print.target.resetAttributes()
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


proc bg*(print: Print, color: BackgroundColor): Print {.discardable.} =
    result = print
    print.current.bg = color
    print.target.setBackgroundColor(color)


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

    var
        differentFg = fg != print.current.fg
        differentBg = bg != print.current.bg
        differentStyle = style != print.current.style

    if differentFg:
        # switch the fg
        print.target.setForegroundColor(fg)

    if differentBg:
        # switch the bg
        print.target.setBackgroundColor(bg)

    if differentStyle:
        # switch the style
        print.target.setStyle(style)

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
    if style != print.current.style:
        # HACK(steve):
        #   Osnap! Looks like you can't unset a style. We have
        #   to clear everything! That doesn't seem right. Look
        #   this up.
        #
        #   For now, we have to flag the colors as being changed
        #   because of the resetAttributes() call below.
        print.target.resetAttributes()
        print.target.setStyle(print.current.style)

        # and here's the hack... we have to pretend the colours changed.
        differentFg = true
        differentBg = true

    if fg != print.current.fg:
        print.target.setForegroundColor(print.current.fg)

    if bg != print.current.bg:
        print.target.setBackgroundColor(print.current.bg)

proc enter*(print: Print, count=1): Print {.discardable.} =
    ## Advances to the next line.
    result = print
    print.isLineIndented = false
    for i in 1..count:
        print.target.writeLine("")


func newPrint*(target: File = stdout, spacesPerIndent = 4): Print =
    let style = PrintStyle(
        style: {},
        fg: fgDefault,
        bg: bgDefault,
        indentBy: 0,
    )
    result = Print(current: style)
    result.target = target
    result.spacesPerIndent = spacesPerIndent
