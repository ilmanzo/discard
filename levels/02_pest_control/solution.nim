# Reference Solution - Level 3: Pest Control
import discard_api

proc playTurn*(bot: var Bot) =
  # Feel forward. If a Slug is detected, attack. Otherwise, walk forward.
  let tile = bot.feel(Forward)
  case tile:
  of Slug:
    bot.attack(Forward)
  else:
    bot.walk(Forward)
