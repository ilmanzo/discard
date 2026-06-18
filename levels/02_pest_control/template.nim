# player.nim - Level 3: Pest Control
# Write your robot AI here and run './discard check' to test.

import discard_api

proc playTurn*(bot: var Bot) =
  # TODO: Walk forward, detect any adjacent Slug, and use 'bot.attack(Forward)' to destroy it.
  # Use a 'case tile' statement to handle Slug, Empty, and other spaces.
  
  let tile = bot.feel(Forward)
  # Replace 'discard' below with your case-statement combat AI!
  discard
