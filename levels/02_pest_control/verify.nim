# levels/03_pest_control/verify.nim
# The level verification harness for Level 3.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster}

proc main() =
  verifyLevel(
    grid = "@  S  >",
    maxTurns = 20,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully eliminated the space slug pest and reached the airlock."
  )

main()
