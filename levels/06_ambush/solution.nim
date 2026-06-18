# Reference Solution - Level 6: Ambush
import discard_api

proc playTurn*(bot: var Bot) =
  if bot.feel(Forward).isEnemy:
    bot.attack(Forward)
  elif bot.feel(Backward).isEnemy:
    bot.attack(Backward)
  elif bot.look(2, Forward) == Slug or bot.look(3, Forward) == Slug:
    bot.shoot(Forward)
  elif bot.look(2, Backward) == Slug or bot.look(3, Backward) == Slug:
    bot.shoot(Backward)
  else:
    bot.walk(Forward)
