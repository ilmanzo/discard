# Reference Solution - Level 1: Reboot
import discard_api

proc playTurn*(bot: var Bot) =
  # Simply walk forward to reach the exit.
  bot.walk(Forward)
