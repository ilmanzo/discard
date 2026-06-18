# Reference Solution - Level 2: Scavenger
import discard_api

proc playTurn*(bot: var Bot) =
  # Feel forward. If adjacent to an item, collect it. Otherwise, roll forward.
  let tile = bot.feel(Forward)
  if tile.isItem:
    bot.collect(Forward)
  else:
    bot.walk(Forward)
