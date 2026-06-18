# levels/06_ambush/verify.nim
# The level verification harness for Level 6.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster}

proc main() =
  # Grid Layout: Slug at 0, Bot starts at 3, Slug at 6, Exit at 9
  verifyLevel(
    grid = "S  @  S  >",
    maxTurns = 30,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully survived the ambush, clearing hostiles on both sides!"
  )

main()
