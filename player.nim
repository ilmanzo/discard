# Reference Solution - Level 5: Long-Range Sensors
import discard_api

proc isThreat(bot: Bot, dist: int): bool =
  if bot.look(dist, Forward) == Slug:
    result = true

proc playTurn*(bot: var Bot) =
  if bot.isThreat(2) or bot.isThreat(3):
    bot.shoot(Forward)
  elif bot.feel(Forward).isEnemy:
    bot.attack(Forward)
  else:
    bot.walk(Forward)
