# Reference Solution - Level 8: Corrupted Area
import discard_api

type BotState = enum StateWalk, StateWait
var currentState = StateWalk   # cycle 1 is safe -> start by moving

proc playTurn*(bot: var Bot) =
  case currentState:
  of StateWalk:
    bot.walk(Forward)
    currentState = StateWait
  of StateWait:
    bot.rest()
    currentState = StateWalk
