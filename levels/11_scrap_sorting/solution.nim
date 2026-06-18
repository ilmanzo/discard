# Reference Solution - Level 11: Scrap Sorting
import discard_api

proc playTurn*(bot: var Bot) =
  let scrap = bot.currentScrap()
  case scrap.kind:
  of skGear:
    if scrap.teeth > 10:
      bot.walk(Forward)
    else:
      bot.rest()
  of skWire:
    if scrap.length > 5.0:
      bot.walk(Forward)
    else:
      bot.rest()
  of skCore:
    if scrap.energy > 100:
      bot.walk(Forward)
    else:
      bot.rest()
