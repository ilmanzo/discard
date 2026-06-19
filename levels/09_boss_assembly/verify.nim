# levels/09_boss_assembly/verify.nim
# The level verification harness for Level 9 (Final Boss).

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster, EqRestModule}

proc main() =
  # Grid Layout: Ferris crab boss 'F' at pos 4 (4 HP, single tile)
  verifyLevel(
    grid = "@   F >",
    maxTurns = 30,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Ferris the Crab vanquished! The route to the inner gauntlet is clear."
  )

main()
