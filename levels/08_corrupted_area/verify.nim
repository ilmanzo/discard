# levels/08_corrupted_area/verify.nim
# The level verification harness for Level 8.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqRestModule}

proc main() =
  verifyLevel(
    grid = "@      >",
    maxTurns = 20,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard state processor successfully executed the radiation bypass sequence!",
    plasmaField = true
  )

main()
