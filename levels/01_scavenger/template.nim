# player.nim - Level 2: Scavenger
# Write your robot AI here and run './discard check' to test.

import discard_api

proc playTurn*(bot: var Bot) =
  # TODO: Guide Discard forward, collect the Battery and Blaster, and reach the exit.
  # Use 'bot.feel(Forward)' to see what is in front of you.
  # Use 'bot.collect(Forward)' to pick up items.
  # Use 'bot.walk(Forward)' to roll forward.
  
  let tile = bot.feel(Forward)
  # Replace 'discard' below with your conditional scavenger AI logic!
  discard
