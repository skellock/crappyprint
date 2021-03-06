import terminal, strformat, std/with # stdlib
import crappyprint # vendor

# --- come up with your own styles ---

proc lit(print: Print, text: string): Print {.discardable.} =
    print.text(text, fg = fgBlue, style = {})


proc cool(print: Print, text: string): Print {.discardable.} =
    print.text(text, fg = fgBlue, style = {styleDim})


proc icy(print: Print, text: string): Print {.discardable.} =
    print.text(text, style = {styleBlink, styleUnderscore}, bg = bgBlue, fg = fgWhite)


proc hip(print: Print, text: string): Print {.discardable.} =
    print.text(text, fg = fgBlue, style = {styleBright})

# --- compose your own blocks ---

proc section(print: Print, text: string): Print {.discardable.} =
    with print:
        text "==--- ", fg = fgMagenta, style = {styleBright}
        icy fmt"  {text}  "
        text " ----->", fg = fgMagenta, style = {styleBright}
        enter 2
        indent


proc sectionEnd(print: Print): Print {.discardable.} =
    print.unindent().enter(2)

# --- start of program ---


let print = newFilePrint()

with print:
    section "Intro"
    text "(awesome music starts)", style = {styleBright}
    sectionEnd
    section "Verse 1"
    # line 1
    text "We're "
    text "no strangers ", style = {styleBright}, fg = fgWhite
    text "to "
    text "love", fg = fgWhite, bg = bgRed
    text "."
    enter

    # line 2
    text "You know the rules"
    text " and so do I"
    text " ... do i ... do i ...", fg = fgBlack
    enter

    # line 3
    text "A"
    bright
    text " full commitment's "
    bright false
    fg fgYellow
    text "what I'm thinking of"
    fg fgDefault

    enter
    # line 4
    text "You "
    text "wouldn't", style = {styleUnderscore}
    text " get this from "
    cool "any "
    lit "other"
    hip " guy!"
    sectionEnd

    section "Pre-Chorus 1"
    # line 1
    text "..."
    sectionEnd
    reset
