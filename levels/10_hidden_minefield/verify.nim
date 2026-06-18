# levels/10_hidden_minefield/verify.nim
# The level verification harness for Level 10.

import std/[os, strutils]
import ../../core/types
import ../../core/engine
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster}

proc checkExtra(state: LevelState): bool =
  if fileExists("player.nim"):
    let code = readFile("player.nim")
    if not ("iterator" in code) or not ("yield" in code):
      echo "\x1B[1m\x1B[31m=== ITERATOR COMPLIANCE FAILED ===\x1B[0m"
      echo "CRITICAL WARNING: No 'iterator' or 'yield' statement found! You must implement a custom iterator to yield navigation steps."
      return false
  return true

proc main() =
  verifyLevel(
    grid = "@  M  M  >",
    maxTurns = 25,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully scanned and cleared the minefield using a custom Nim iterator!",
    extraCheck = checkExtra
  )

main()
