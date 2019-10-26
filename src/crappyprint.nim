import terminal, streams # stdlib

# system.addQuitProc(resetAttributes)

type
    PrintStyle = object
        ## Styling information
        style: set[Style]   ## the terminal style
        fg: ForegroundColor ## the terminal foreground color
        bg: BackgroundColor ## the terminal background color
        indentBy: int       ## how many spaces are we over?

    PrintTargetKind* = enum
        ptFile
        ptStream
        ptString

    Print* = ref object
        ## For printing text.
        case kind: PrintTargetKind
        of ptFile:
            targetFile*: File           ## The file we're writing to (e.g. stdout).
        of ptStream:
            targetStream*: StringStream ## The stream we're writing to
        of ptString:
            targetString*: string       ## The string we're writing to
        current: PrintStyle             ## The style we're currently set to.
        spacesPerIndent: int            ## How many spaces per indent?
        isLineIndented: bool            ## Have we already applied indentation for this line?

# the default style used for starting and resetting
let defaultStyle = PrintStyle(
    style: {},
    fg: fgDefault,
    bg: bgDefault,
    indentBy: 0,
)

proc applyStyle(print: Print, style: PrintStyle): Print {.discardable.} =
    ## Bestows the proper colors and style onto the underlying file (e.g. stdout)
    ## if the print kind is a File, otherwise no-op.
    ##
    result = print
    case print.kind
    of ptFile:
        print.targetFile.setForegroundColor(style.fg)
        print.targetFile.setBackgroundColor(style.bg)
        print.targetFile.setStyle(style.style)
    else:
        discard

proc applyCurrentStyle(print: Print): Print {.discardable.} =
    ## Reapplies whatever is on the top of the style stack.
    ##
    result = print.applyStyle(print.current)

proc indent*(print: Print, levels = 1): Print {.discardable.} =
    ## Changes the indentation for new lines. Levels indicates the number
    ## of indendations to apply and not the number of spaces.
    ##
    ## If the number is positive, the indentation will go to the right.
    ##
    ## If the number is negative, the indentation will go back to the left.
    ##
    ## If the number is 0, indentation is reset.
    ##
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


proc unindent*(print: Print, levels = 1): Print {.discardable.} =
    ## Has the same effect as calling indent(-1).
    ##
    result = print.indent(-levels)

proc reset*(print: Print): Print {.discardable.} =
    ## Resets us back to the original state also clears any indentation.
    ##
    result = print
    print.isLineIndented = false
    print.current = defaultStyle
    case print.kind
    of ptFile:
        print.targetFile.resetAttributes()
    else:
        discard

proc bright*(print: Print, on = true): Print {.discardable.} =
    ## Makes the current style bright if the target is a File.
    ##
    result = print
    if on:
        print.current.style.incl(styleBright)
    else:
        print.current.style.excl(styleBright)

    case print.kind
    of ptFile:
        print.targetFile.resetAttributes()
    else:
        discard
    print.applyCurrentStyle()


proc dim*(print: Print, on = true): Print {.discardable.} =
    ## Makes the current style dim if the target is a File.
    ##
    result = print
    if on:
        print.current.style.incl(styleDim)
    else:
        print.current.style.excl(styleDim)

    print.applyCurrentStyle()


proc fg*(print: Print, color: ForegroundColor): Print {.discardable.} =
    ## Sets the foreground color if the target is a File.
    ##
    result = print
    print.current.fg = color
    case print.kind
    of ptFile:
        print.targetFile.setForegroundColor(color)
    else:
        discard


proc bg*(print: Print, color: BackgroundColor): Print {.discardable.} =
    ## Sets the background color if the target is a File.
    ##
    result = print
    print.current.bg = color
    case print.kind
    of ptFile:
        print.targetFile.setBackgroundColor(color)
    else:
        discard


proc space*(print: Print, count = 1): Print {.discardable.} =
    ## Writes a space.
    ##
    result = print
    for i in 1..count:
        case print.kind
        of ptFile:
            print.targetFile.write(" ")
        of ptStream:
            print.targetStream.write(" ")
        of ptString:
            print.targetString.add(" ")


proc text*(
    print: Print,
    text: string = "",
    style: set[Style] = {},
    fg: ForegroundColor = fgDefault,
    bg: BackgroundColor = bgDefault,
    indentBy = 0,
): Print {.discardable.} =
    ## Writes some text to the target. Terminal styles are only applied
    ## to File targets.
    result = print

    var
        differentFg = fg != print.current.fg
        differentBg = bg != print.current.bg
        differentStyle = style != print.current.style

    case print.kind
    of ptFile:
        if differentFg:
            print.targetFile.setForegroundColor(fg)

        if differentBg:
            print.targetFile.setBackgroundColor(bg)

        if differentStyle:
            print.targetFile.setStyle(style)
    else:
        discard

    if indentBy > 0:
        # we need to temporarily change the indentation
        print.space(indentBy)
        print.isLineIndented = true
    elif not print.isLineIndented and print.current.indentBy > 0:
        # apply the indentation if we've already set it
        print.space(print.current.indentBy)
        print.isLineIndented = true

    # write the text
    case print.kind
    of ptFile:
        print.targetFile.write text

        if differentStyle:
            # HACK(steve):
            #   Osnap! Looks like you can't unset a style. We have
            #   to clear everything! That doesn't seem right. Look
            #   this up.
            #
            #   For now, we have to flag the colors as being changed
            #   because of the resetAttributes() call below.
            print.targetFile.resetAttributes()
            print.targetFile.setStyle(print.current.style)

            # and here's the hack... we have to pretend the colours changed.
            differentFg = true
            differentBg = true

        if differentFg:
            print.targetFile.setForegroundColor(print.current.fg)

        if differentBg:
            print.targetFile.setBackgroundColor(print.current.bg)

    of ptStream:
        print.targetStream.write(text)

    of ptString:
        print.targetString.add(text)

proc enter*(print: Print, count = 1): Print {.discardable.} =
    ## Advances to the next line.
    ##
    result = print
    print.isLineIndented = false
    for i in 1..count:
        case print.kind
        of ptFile:
            print.targetFile.writeLine("")
        of ptStream:
            print.targetStream.write("\l")
        of ptString:
            print.targetString.add("\l")

proc newFilePrint*(target: var File = stdout, spacesPerIndent = 4): Print =
    ## Creates a new Print targeting a File. This is great for writing things
    ## to the terminal.
    ##
    result = Print(current: defaultStyle, kind: ptFile)
    result.targetFile = target
    result.spacesPerIndent = spacesPerIndent

proc newStreamPrint*(target: var StringStream, spacesPerIndent = 4): Print =
    ## Creates a new Print targeting a Stream. Any terminal styles are ignored.
    ##
    result = Print(current: defaultStyle, kind: ptStream)
    result.targetStream = target
    result.spacesPerIndent = spacesPerIndent

proc newStringPrint*(initialValue: string = "", spacesPerIndent = 4): Print =
    ## Creates a new Print which can be acquired by calling `$` or `.toString`
    ## on the `Print`. Any terminal styles are ignored.
    ##
    result = Print(current: defaultStyle, kind: ptString)
    result.targetString = initialValue
    result.spacesPerIndent = spacesPerIndent

proc `$`*(print: Print): string =
    ## String-based `Print`s will return the built string that has been assembled
    ## whereas `File` and `StringStream` will return an empty string since there's better
    ## ways for the source program to get that information from a `File` or `StringStream`.
    ##
    case print.kind
    of ptFile:
        result = ""
    of ptStream:
        result = ""
    of ptString:
        result = print.targetString

proc toString*(print: Print): string =
    ## String-based `Print`s will return the built string that has been assembled
    ## whereas `File` and `StringStream` will return an empty string since there's better
    ## ways for the source program to get that information from a `File` or `StringStream`.
    ##
    $print
