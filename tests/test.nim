import terminal, os, unittest # stdlib
import crappyprint # project

# ensure we reset when we kill the process
system.addQuitProc(resetAttributes)

# TODO:
#   * can we use a File without touching the file system?
#   * write a template or something to get rid of the boilerplate

let filename = "tests/sample"

suite "text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello")
    f.close()

    test "writing":
        check readFile(filename) == "\e[39m\e[49mhello\e[0m\e[0m"

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

suite "indented text":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hello", indentBy=2)
    f.close()

    test "writing":
        check readFile(filename) == "\e[39m\e[49m  hello\e[0m\e[0m"

suite "enter":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hi").enter()
    f.close()

    test "writing":
        check readFile(filename) == "\e[39m\e[49mhi\e[0m\e[0m\n"

suite "many enters":
    let f = open(filename, fmReadWrite)
    newPrint(f).text("hi").enter(3)
    f.close()

    test "writing":
        check readFile(filename) == "\e[39m\e[49mhi\e[0m\e[0m\n\n\n"
