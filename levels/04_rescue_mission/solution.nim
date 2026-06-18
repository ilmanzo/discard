# Reference Solution - Level 4: Rescue Mission
import discard_api

proc playTurn*(bot: var Bot) =
  let tile = bot.feel(Forward)
  if tile.isCrew:
    bot.rescue(Forward)
  else:
    bot.walk(Forward)
