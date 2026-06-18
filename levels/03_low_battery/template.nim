# player.nim - Level 3: Low Battery
# Write your robot AI here and run './discard check' to test.

import discard_api

proc playTurn*(bot: var Bot) =
  # TODO: Rest to recharge battery if HP is low (<= 10), attack any Slug, collect items, and reach exit!
  # Use 'bot.health' to check battery.
  # Use 'bot.rest()' to recharge.
  
  let tile = bot.feel(Forward)
  # Replace 'discard' below with your conditional low-battery combat AI!
  discard
