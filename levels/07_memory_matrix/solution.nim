# Reference Solution - Level 7: Memory Matrix
import discard_api

var history: seq[int] = @[]

proc playTurn*(bot: var Bot) =
  history.add(1)
  if history.len mod 2 == 1:
    bot.walk(Forward)
  else:
    bot.rest()
