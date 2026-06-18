# levels/07_memory_matrix/verify.nim
# The level verification harness for Level 7.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqRestModule}

proc main() =
  # Grid Layout: 6 spaces of empty matrix, Exit at 7
  verifyLevel(
    grid = "@      >",
    maxTurns = 20,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully navigated the matrix using a dynamic memory sequence!",
    plasmaField = true
  )

main()
