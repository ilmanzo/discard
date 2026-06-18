# Reference Solution - Level 12: Final Boss: Core Jammer
import discard_api

# A template performs compile-time AST substitution: every `bot.engage(dir)`
# call is replaced inline with this whole decision block, parameterised by `dir`.
# One reusable routine, no proc-call overhead, works in either direction.
template engage(bot: var Bot, dir: Direction) =
  if bot.look(1, dir) == Slug or bot.look(2, dir) == Slug or bot.look(3, dir) == Slug:
    bot.shoot(dir)          # vaporise the nearest shield layer at range
  elif bot.feel(dir).isEnemy:
    bot.attack(dir)
  else:
    bot.walk(dir)

proc playTurn*(bot: var Bot) =
  bot.engage(Forward)
