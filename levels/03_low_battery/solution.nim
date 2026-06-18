# Reference Solution - Level 3: Low Battery
import discard_api

proc playTurn*(bot: var Bot) =
  let tile = bot.feel(Forward)
  if bot.health <= 10:
    bot.rest()
  elif tile.isEnemy:
    bot.attack(Forward)
  elif tile.isItem:
    bot.collect(Forward)
  else:
    bot.walk(Forward)
