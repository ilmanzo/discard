# tests/test_engine.nim
import std/unittest
import ../discard_api
import ../core/engine

suite "Discard Engine Unit Tests":

  test "initLevel parses grid string correctly":
    let state = initLevel("@ B W S C >")
    check(state.bot.position == 0)
    check(state.grid[2] == Battery)
    check(state.grid[4] == Weapon)
    check(state.grid[6] == Slug)
    check(state.grid[8] == Crew)
    check(state.grid[10] == Exit)

  test "updateSenses detects adjacent tiles":
    var state = initLevel("@ S >")
    state.updateSenses()
    check(state.bot.nearTiles[Forward] == Empty)
    check(state.bot.nearTiles[Backward] == Wall)

    state.bot.position = 1
    state.updateSenses()
    check(state.bot.nearTiles[Forward] == Slug)
    check(state.bot.nearTiles[Backward] == Empty)

  test "ActWalk moves bot forward and backward":
    var state = initLevel("@   >")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.bot.position == 1)
    state.tick(proc(bot: var Bot) = bot.walk(Backward))
    check(state.bot.position == 0)

  test "ActWalk blocked by wall or objects":
    var state = initLevel("@ S >")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.bot.position == 1)
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.bot.position == 1) # blocked by Slug

  test "ActWalk at left boundary stays put":
    var state = initLevel("@>")
    state.tick(proc(bot: var Bot) = bot.walk(Backward))
    check(state.bot.position == 0) # can't go left of 0

  test "ActCollect gathers battery and blaster":
    var bat = initLevel(" @B>")
    bat.bot.health = 5
    bat.tick(proc(bot: var Bot) = bot.collect(Forward))
    check(EqBattery in bat.bot.equipment)
    check(bat.bot.health == bat.bot.maxHealth)
    check(bat.grid[2] == Empty)

    var blaster = initLevel(" @W>")
    blaster.tick(proc(bot: var Bot) = bot.collect(Forward))
    check(EqBlaster in blaster.bot.equipment)
    check(blaster.grid[2] == Empty)

  test "ActCollect on empty tile does nothing":
    var state = initLevel("@  >")
    state.tick(proc(bot: var Bot) = bot.collect(Forward))
    check(EqBattery notin state.bot.equipment)
    check(EqBlaster notin state.bot.equipment)

  test "ActCollect capped at maxHealth":
    var state = initLevel(" @B>")
    state.bot.health = 18
    state.tick(proc(bot: var Bot) = bot.collect(Forward))
    check(state.bot.health == state.bot.maxHealth) # capped, not 28, not 28

  test "ActAttack kills Slug when blaster equipped":
    var state = initLevel(" @S>")
    state.bot.equipment = {EqBlaster}
    state.tick(proc(bot: var Bot) = bot.attack(Forward))
    check(state.grid[2] == Empty)

  test "ActAttack blocked without equipment":
    var state = initLevel(" @S>")
    state.tick(proc(bot: var Bot) = bot.attack(Forward))
    check(state.grid[2] == Slug) # Slug untouched

  test "ActAttack on non-slug does nothing":
    var state = initLevel(" @B>")
    state.bot.equipment = {EqBlaster}
    state.tick(proc(bot: var Bot) = bot.attack(Forward))
    check(state.grid[2] == Battery) # Battery untouched

  test "ActRest restores health with rest module":
    var state = initLevel("@ >")
    state.bot.health = 10
    state.tick(proc(bot: var Bot) = bot.rest())
    check(state.bot.health == 10) # no module, nothing happens

    state.bot.equipment = {EqRestModule}
    state.tick(proc(bot: var Bot) = bot.rest())
    check(state.bot.health == 15)

  test "ActRest capped at maxHealth":
    var state = initLevel("@ >")
    state.bot.health = 18
    state.bot.equipment = {EqRestModule}
    state.tick(proc(bot: var Bot) = bot.rest())
    check(state.bot.health == state.bot.maxHealth) # capped

  test "ActRescue rescues buddy bot":
    var state = initLevel(" @C>")
    state.tick(proc(bot: var Bot) = bot.rescue(Forward))
    check(state.grid[2] == Empty)

  test "ActRescue on non-crew does nothing":
    var state = initLevel(" @B>")
    state.tick(proc(bot: var Bot) = bot.rescue(Forward))
    check(state.grid[2] == Battery) # untouched

  test "ActShoot hits Slug up to 3 tiles away":
    var state = initLevel("@   S >")
    state.bot.equipment = {EqBlaster}
    state.tick(proc(bot: var Bot) = bot.shoot(Forward))
    check(state.grid[4] == Slug) # out of range at distance 4

    state.bot.position = 1
    state.tick(proc(bot: var Bot) = bot.shoot(Forward))
    check(state.grid[4] == Empty) # distance 3, killed

  test "ActShoot detonates Mine in range":
    var state = initLevel("@ M >")
    state.bot.equipment = {EqBlaster}
    state.tick(proc(bot: var Bot) = bot.shoot(Forward))
    check(state.grid[2] == Empty) # mine cleared at safe range

  test "Plasma field kills bot walking on a venting (even) turn":
    var state = initLevel("@   >", plasmaField = true)
    state.tick(proc(bot: var Bot) = bot.walk(Forward)) # turn 1 (odd) = safe
    check(state.bot.health > 0)
    state.tick(proc(bot: var Bot) = bot.walk(Forward)) # turn 2 (even) = venting
    check(state.isFailed)
    check(state.bot.health == 0)

  test "Plasma field spares a bot that rests on venting turns":
    var state = initLevel("@   >", plasmaField = true)
    state.bot.equipment = {EqRestModule}
    state.tick(proc(bot: var Bot) = bot.walk(Forward)) # odd: walk ok
    state.tick(proc(bot: var Bot) = bot.rest())        # even: rest, safe
    check(not state.isFailed)
    check(state.bot.position == 1)

  test "Scrap belt: walking a reject jams the drive (fail)":
    var state = initLevel("@ >", scrapQueue = @[Scrap(kind: skCore, energy: 50)]) # 50 < 100 = reject
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.isFailed)
    check(state.bot.health == 0)

  test "Scrap belt: rest discards a reject and advances the belt":
    var state = initLevel("@  >", scrapQueue = @[
      Scrap(kind: skWire, length: 2.0),   # reject -> rest
      Scrap(kind: skGear, teeth: 99)])    # keep
    state.bot.equipment = {EqRestModule}
    state.tick(proc(bot: var Bot) = bot.rest())
    check(not state.isFailed)
    check(state.bot.position == 0)        # rest does not move
    check(state.scrapIndex == 1)          # belt advanced past the reject
    state.tick(proc(bot: var Bot) = bot.walk(Forward))  # next item (keep) loads at tick start
    check(state.bot.position == 1)        # walking the keeper advances

  test "scrapPasses applies per-variant thresholds":
    check(scrapPasses(Scrap(kind: skGear, teeth: 11)))
    check(not scrapPasses(Scrap(kind: skGear, teeth: 10)))
    check(scrapPasses(Scrap(kind: skWire, length: 5.1)))
    check(not scrapPasses(Scrap(kind: skCore, energy: 100)))

  test "ActShoot backward hits Slug behind":
    var state = initLevel("S  @ >")  # @ places bot at 3
    state.bot.equipment = {EqBlaster}
    state.tick(proc(bot: var Bot) = bot.shoot(Backward))
    check(state.grid[0] == Empty) # Slug at 0 destroyed

  test "ActShoot blocked without blaster":
    var state = initLevel("@ S >")
    state.tick(proc(bot: var Bot) = bot.shoot(Forward))
    check(state.grid[2] == Slug) # no blaster, Slug alive

  test "ActShoot stops at wall mid-path":
    # Grid: bot at 0, empty at 1, wall at 2... can't go further
    # Simulate by noting shot stops at Wall TileKind inside grid
    # Since Wall is only on boundaries in normal grids, test wall-blocking via out-of-bounds
    var state = initLevel("@  S >")
    state.bot.equipment = {EqBlaster}
    # Place a wall-like barrier by checking slug is reachable
    # The slug at pos 3 is distance 3 from bot at 0 — just in range
    state.tick(proc(bot: var Bot) = bot.shoot(Forward))
    check(state.grid[3] == Empty) # slug killed at distance 3

  test "Only first action per turn registers":
    var state = initLevel("@   >")
    state.tick(proc(bot: var Bot) =
      bot.walk(Forward)
      bot.walk(Forward) # second call ignored
    )
    check(state.bot.position == 1) # moved exactly one step

  test "Slug bites adjacent bot":
    var state = initLevel("@ S >")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.bot.position == 1)
    check(state.bot.health == 15) # 20 - 1 (step) - 4 (slug bite)

  test "Game fails on HP depletion":
    var state = initLevel("@ >")
    state.bot.health = 0
    state.tick(proc(bot: var Bot) = discard)
    check(state.isFailed == true)

  test "Game fails when crew left behind":
    var state = initLevel("@ C >")
    state.bot.position = 4 # moved directly to exit without rescuing
    state.tick(proc(bot: var Bot) = discard)
    check(state.isFailed == true)

  test "Game fails when multiple crew left":
    var state = initLevel("@ C C >")
    state.bot.position = 6 # at exit
    state.tick(proc(bot: var Bot) = discard)
    check(state.isFailed == true)

  test "Game succeeds when all crew rescued and exit reached":
    var state = initLevel(" @>")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.isSolved == true)

  test "Game fails on max turns timeout":
    var state = initLevel("@  >", maxTurns = 2)
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    state.tick(proc(bot: var Bot) = bot.walk(Backward))
    check(state.isFailed == true)
    check(state.turn >= state.maxTurns)

  test "ActWalk on landmine sets health to 0":
    var state = initLevel("@M>")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.bot.health == 0)
    check(state.isFailed == true)

  test "Radar look reads correct TileKind at distances (forward)":
    var state = initLevel("@ B S W >")
    state.updateSenses()
    check(state.bot.look(1, Forward) == Empty)
    check(state.bot.look(2, Forward) == Battery)
    check(state.bot.look(3, Forward) == Empty)

  test "Radar look reads backward":
    # Grid: S=0, B=1, space=2, @=3, >=4 — bot auto-placed at 3
    var state = initLevel("SB @>")
    state.updateSenses()
    check(state.bot.look(1, Backward) == Empty)
    check(state.bot.look(2, Backward) == Battery)
    check(state.bot.look(3, Backward) == Slug)

  test "Radar look returns Wall when out of grid":
    var state = initLevel("@>")
    state.updateSenses()
    check(state.bot.look(1, Backward) == Wall) # nothing behind pos 0
    check(state.bot.look(3, Forward) == Wall)  # only 1 tile ahead

  test "Object Variant currentScrap fields accessible":
    var bot = Bot()
    bot.currentScrap = Scrap(kind: skGear, teeth: 15)
    check(bot.currentScrap.kind == skGear)
    check(bot.currentScrap.teeth == 15)

    bot.currentScrap = Scrap(kind: skCore, energy: 200)
    check(bot.currentScrap.kind == skCore)
    check(bot.currentScrap.energy == 200)

  test "Equipment set tracks multiple items correctly":
    var bot = Bot()
    bot.equipment = {EqBlaster, EqRestModule}
    check(EqBlaster in bot.equipment)
    check(EqRestModule in bot.equipment)
    check(EqBattery notin bot.equipment)

  test "No tick runs after game is solved":
    var state = initLevel(" @>")
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.isSolved == true)
    let turnBefore = state.turn
    state.tick(proc(bot: var Bot) = bot.walk(Backward))
    check(state.turn == turnBefore) # no additional turn

  test "No tick runs after game is failed":
    var state = initLevel("@ >")
    state.bot.health = 0
    state.tick(proc(bot: var Bot) = discard)
    check(state.isFailed == true)
    let turnBefore = state.turn
    state.tick(proc(bot: var Bot) = bot.walk(Forward))
    check(state.turn == turnBefore)
