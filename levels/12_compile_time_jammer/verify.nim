# levels/12_compile_time_jammer/verify.nim
# The level verification harness for Level 12.

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
    if not ("template" in code):
      echo "\x1B[1m\x1B[31m=== TEMPLATE COMPLIANCE FAILED ===\x1B[0m"
      echo "CRITICAL WARNING: No 'template' keyword found! Capture your engage routine as a template."
      return false
  return true

proc main() =
  verifyLevel(
    grid = "@   S S S S >",
    maxTurns = 30,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "ALL SYSTEMS CALIBRATED! Discard has Escaped the Scrap Yards! Congratulations!",
    extraCheck = checkExtra
  )

main()
