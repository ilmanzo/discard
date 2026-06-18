# Reference Solution - Level 10: Hidden Minefield
import discard_api

# A custom iterator that sweeps the radar at each distance ahead,
# yielding one reading per step for the for-loop to consume.
iterator radarSweep(bot: Bot): TileKind =
  yield bot.look(1, Forward)
  yield bot.look(2, Forward)
  yield bot.look(3, Forward)

proc playTurn*(bot: var Bot) =
  var mineAhead = false
  for tile in radarSweep(bot):
    if tile == Mine:
      mineAhead = true

  if mineAhead:
    bot.shoot(Forward)   # detonate the nearest mine at safe range
  else:
    bot.walk(Forward)    # corridor clear -> advance
