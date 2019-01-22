import terminal # stdlib
import crappyprint # project

# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)

template expect(content: string, body: untyped): untyped {.dirty.} =
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
    let 
        filename = "tests/output"
        file = open(filename, fmReadWrite)
    try:
        discard body
    finally:
        file.close()
    doAssert readFile(filename) == content
    

block: # regular text
    expect "hello":
        newPrint(file).text("hello")

block: # line breaks
    expect "hi\n\n\n\n":
        newPrint(file).text("hi").enter().enter(3)

block: # foreground text color
    expect "\e[31m\e[49mhello\e[0m\e[0m":
        newPrint(file).text("hello", fg=fgRed)

block: # background text color
    expect "\e[39m\e[41mhello\e[0m\e[0m":
        newPrint(file).text("hello", bg=bgRed)

block: # indentation
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

block: # indent during text
    expect "  hello":
        newPrint(file).text("hello", indentBy=2)

block: # space
    expect "     ":
        newPrint(file).space().space(4)

block: # enter
    expect "\n\n\n\n\n":
        newPrint(file).enter().enter(4)
