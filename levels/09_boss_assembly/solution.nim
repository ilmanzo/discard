# Reference Solution - Level 9: Boss Assembly
import discard_api

proc playTurn*(bot: var Bot) =
  let tile = bot.feel(Forward)
  if bot.look(3, Forward) == Slug:
    bot.shoot(Forward)
  elif bot.look(2, Forward) == Slug:
    bot.shoot(Forward)
  elif tile.isEnemy:
    bot.attack(Forward)
  else:
    bot.walk(Forward)
