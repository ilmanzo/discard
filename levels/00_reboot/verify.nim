# levels/01_reboot/verify.nim
# The level verification harness for Level 1.

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {}
  bot.health = bot.maxHealth div 2

proc main() =
  verifyLevel(
    grid = "@     >",
    maxTurns = 15,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "Discard successfully rebooted its thrusters and reached the airlock."
  )

main()
