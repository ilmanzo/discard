# player.nim - Level 4: Rescue Mission
# Write your robot AI here and run './discard check' to test.

import discard_api

proc playTurn*(bot: var Bot) =
  # TODO: Move forward, detect buddy bots with 'tile.isCrew', rescue them, and reach the exit.
  # Use 'bot.rescue(Forward)' to repair buddy bots.
  
  let tile = bot.feel(Forward)
  # Replace 'discard' below with your buddy-bot rescue AI!
  discard
