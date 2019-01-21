import terminal, os, unittest # stdlib
import crappyprint # project

# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)

# TODO:
#   * can we use a File without touching the file system?
#   * write a template or something to get rid of the boilerplate

let filename = "tests/output"

# --- Normal Text ---

suite "text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello")
    f.close()

    test "writing":
        check readFile(filename) == "hello"

# --- Line breaks ---

suite "enter":
    let f = open(filename, fmReadWrite)
    newPrint(f)
        .text("hi")
        .enter()
        .enter(3)
    f.close()

    test "writing":
        check readFile(filename) == "hi\n\n\n\n"


# --- Text color & style ---

suite "red fg text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello", fg=fgRed)
    f.close()

    test "writing":
        check readFile(filename) == "\e[31m\e[49mhello\e[0m\e[0m"

suite "red bg text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello", bg=bgRed)
    f.close()

    test "writing":
        check readFile(filename) == "\e[39m\e[41mhello\e[0m\e[0m"

# --- Indentation ---

suite "indent":
    let f = open(filename, fmReadWrite)
    newPrint(f, spacesPerIndent = 2)
        .indent()    # over 1
        .text("a")
        .enter()
        .indent(-1)  # back 1
        .text("b")
        .enter()
        .indent(2)   # over 2
        .text("c")
        .enter()
        .indent(0)   # reset
        .text("d")
        .enter()
        .indent(-69) # minimum of 0
        .text("e")
    f.close()

    test "writing":
        check readFile(filename) == "  a\nb\n    c\nd\ne"

suite "indent during text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello", indentBy=2)
    f.close()

    test "writing":
        check readFile(filename) == "  hello"

# --- Space ---

suite "space":
    let f = open(filename, fmReadWrite)
    newPrint(f).space().space(4)
    f.close()

    test "writing":
        check readFile(filename) == "     "
