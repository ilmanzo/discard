# levels/11_scrap_sorting/verify.nim
# The level verification harness for Level 11.

import std/[os, strutils]
import ../../core/types
import ../../core/engine
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqRestModule}

# The belt: one item presented per turn. A "keep" item (passes its threshold)
# must be walked forward; a "reject" must be discarded with rest, or walking it
# jams the drive (instant fail). Exactly 6 keepers (one per corridor step),
# every variant kind appearing as both keep and reject. Trailing reject closes
# the "walk past the end" loophole.
let belt = @[
  Scrap(kind: skGear, teeth: 15),    # keep
  Scrap(kind: skWire, length: 2.0),  # reject
  Scrap(kind: skCore, energy: 150),  # keep
  Scrap(kind: skGear, teeth: 4),     # reject
  Scrap(kind: skWire, length: 9.0),  # keep
  Scrap(kind: skGear, teeth: 20),    # keep
  Scrap(kind: skCore, energy: 200),  # keep
  Scrap(kind: skWire, length: 7.5),  # keep
  Scrap(kind: skCore, energy: 50),   # reject (trailing)
]

proc checkExtra(state: LevelState): bool =
  if fileExists("player.nim"):
    let code = readFile("player.nim")
    if not ("skGear" in code) or not ("skWire" in code) or not ("skCore" in code):
      echo "\x1B[1m\x1B[31m=== OBJECT VARIANT CHECK FAILED ===\x1B[0m"
      echo "CRITICAL WARNING: No variant kind matching found! You must use a case statement matching skGear, skWire, and skCore."
      return false
  return true

proc main() =
  verifyLevel(
    grid = "@     >",
    maxTurns = 20,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully unpacked and sorted scrap variants!",
    extraCheck = checkExtra,
    scrapQueue = belt
  )

main()
