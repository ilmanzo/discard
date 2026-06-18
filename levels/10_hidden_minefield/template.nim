# player.nim - Level 10: Hidden Minefield
# Write your robot AI here and run './discard check' to test.

import discard_api

# TODO: Declare a custom iterator that yields each radar reading ahead.
# iterator radarSweep(bot: Bot): TileKind =
#   yield bot.look(1, Forward)
#   ...

proc playTurn*(bot: var Bot) =
  # TODO: for-loop over your iterator. If a Mine is in range, shoot to
  # detonate it at safe range; otherwise the path is clear, so walk.

  # Replace 'discard' below with your custom iterator AI!
  discard
