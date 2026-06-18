# levels/03_low_battery/verify.nim
# The level verification harness for Level 3.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster, EqRestModule}
  bot.health = 8 # Starts with low health!

proc main() =
  # Grid Layout: Bot starts at 0, Slug at 3, Battery at 6, Exit at 9
  # String legend: @  S  B  >
  verifyLevel(
    grid = "@  S  B  >",
    maxTurns = 25,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully defragmented its subsystems and survived the low battery run!"
  )

main()
