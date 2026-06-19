# levels/05_long_range_sensors/verify.nim
# The level verification harness for Level 5.

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
    if not ("result =" in code) and not ("result=" in code):
      echo "\x1B[1m\x1B[31m=== RESULT CONVENTION FAILED ===\x1B[0m"
      echo "CRITICAL WARNING: No assignment to implicit variable 'result' found! You must assign to 'result' inside your helper procedure."
      return false
  return true

proc main() =
  # Grid Layout: Gopher mid-boss 'G' at pos 4 (2 HP, single tile)
  verifyLevel(
    grid = "@   G >",
    maxTurns = 25,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully scanned ahead and dismantled the Gopher Mid-Boss!",
    extraCheck = checkExtra
  )

main()
