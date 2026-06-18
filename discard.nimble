# discard.nimble
version       = "0.1.0"
author        = "Andrea"
description   = "Discard - A terminal-based programming game representing the semi-forgotten Nim language"
license       = "MIT"
bin           = @["discard"]

requires "nim >= 2.2.10"
requires "checksums"

task test, "Run the unit tests":
  exec "nim c -r --hints:off --warnings:off tests/test_engine.nim"
