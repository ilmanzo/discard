# levels/09_boss_assembly/verify.nim
# The level verification harness for Level 9 (Final Boss).

import ../../core/types
import ../../core/visualizer
import ../../player

proc setup(bot: var Bot) =
  bot.equipment = {EqBlaster, EqRestModule}

proc main() =
  # Grid Layout: 3 tiles empty, then 3 defensive slug armor plates representing the Boss, then Exit.
  # Layout: @   S S S > (S S S represents the Boss shield layers)
  verifyLevel(
    grid = "@   S S S >",
    maxTurns = 30,
    setupBot = setup,
    playTurn = playTurn,
    successMessage = "ALL SYSTEMS CALIBRATED! Discard has Escaped the Scrap Yards! Congratulations!"
  )

main()
