# levels/02_scavenger/verify.nim
# The level verification harness for Level 2.

import std/[os, strutils]
import ../../core/types
import ../../core/engine
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {}
  bot.health = bot.maxHealth div 2

proc checkExtra(state: LevelState): bool =
  if fileExists("player.nim"):
    let code = readFile("player.nim")
    if "var tile" in code:
      echo "\x1B[1m\x1B[31m=== SYNTAX DEFECT DETECTED ===\x1B[0m"
      echo "CRITICAL WARNING: Mutating variable 'var tile' found! You must use 'let tile' for immutable sensor data."
      return false
  if EqBattery notin state.bot.equipment or EqBlaster notin state.bot.equipment:
    echo "\x1B[1m\x1B[31m=== SYSTEM VERIFICATION FAILED ===\x1B[0m"
    echo "Discard bypassed the scavenger requirements! You must collect both items before exiting."
    return false
  return true

proc main() =
  verifyLevel(
    grid = "@  B  W  >",
    maxTurns = 30,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully collected the Battery and Blaster and reached the airlock.",
    extraCheck = checkExtra
  )

main()
