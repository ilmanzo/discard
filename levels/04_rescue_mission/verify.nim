# levels/04_rescue_mission/verify.nim
# The level verification harness for Level 4.

import std/[os, strutils]
import ../../core/types
import ../../core/engine
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {}

proc checkExtra(state: LevelState): bool =
  if fileExists("player.nim"):
    let code = readFile("player.nim")
    if not (".isCrew" in code):
      echo "\x1B[1m\x1B[31m=== UFCS COMPLIANCE FAILED ===\x1B[0m"
      echo "CRITICAL WARNING: No method chaining `.isCrew` found! You must call `.isCrew` on your sensor data using Nim's UFCS."
      return false
  return true

proc main() =
  # Grid: Buddy bot 'C' at pos 3, Exit at 6.
  verifyLevel(
    grid = "@  C  >",
    maxTurns = 20,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully rescued the deactivated buddy bot and escaped!",
    extraCheck = checkExtra
  )

main()
