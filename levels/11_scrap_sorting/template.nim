# player.nim - Level 11: Scrap Sorting
# Write your robot AI here and run './discard check' to test.

import discard_api

proc playTurn*(bot: var Bot) =
  # A new scrap item rides the belt each turn. Keep good ones (walk) and reject
  # bad ones (rest) -- walking a reject jams the drive (instant fail)!
  # TODO: case on scrap.kind (skGear/skWire/skCore) and check its field:
  #   skGear: teeth > 10   skWire: length > 5.0   skCore: energy > 100
  let scrap = bot.currentScrap()
  # Replace 'discard' below with your object variant sorting AI!
  discard
