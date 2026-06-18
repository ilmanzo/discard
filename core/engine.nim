# core/engine.nim
# The turn-based simulation engine for Discard.

import std/sequtils
import types

type
  LevelState* = object
    grid*: seq[TileKind]
    bot*: Bot
    turn*: int
    maxTurns*: int
    isSolved*: bool
    isFailed*: bool
    plasmaField*: bool   # if true, walking on venting (even) turns is lethal
    botBitten*: bool     # set for the turn a Slug bit the bot (drives combat FX)
    scrapQueue*: seq[Scrap]  # if non-empty, this is a sorting belt: one item presented per turn
    scrapIndex*: int     # which belt item is currently loaded
    log*: seq[string]

  RunResult* = object
    frames*: seq[LevelState]

func targetPos(pos: int, dir: Direction): int =
  if dir == Forward: pos + 1 else: pos - 1

func inBounds(pos, len: int): bool =
  pos >= 0 and pos < len

func scrapPasses*(s: Scrap): bool =
  ## The objective "keep this scrap" rule. Players must replicate it via a
  ## variant case to decide walk (keep) vs rest (discard) on the sorting belt.
  case s.kind
  of skGear: s.teeth > 10
  of skWire: s.length > 5.0
  of skCore: s.energy > 100

proc initLevel*(gridStr: string, maxTurns: int = 30, plasmaField: bool = false,
                scrapQueue: seq[Scrap] = @[]): LevelState =
  ## Parses a 1D grid string and returns the initialized LevelState.
  ## Legend:
  ##   @ = Bot (starts with 20 HP)
  ##   > = Exit
  ##   B = Battery (item)
  ##   W = Weapon / Laser Blaster (item)
  ##   S = Space-Slug (enemy)
  ##   C = Buddy Bot / Crew (to rescue)
  ##   M = Landmine
  ##   _ or ' ' = Empty space

  result.grid = @[]
  result.turn = 0
  result.maxTurns = maxTurns
  result.isSolved = false
  result.isFailed = false
  result.plasmaField = plasmaField
  result.scrapQueue = scrapQueue
  result.scrapIndex = 0
  result.log = @[]

  result.bot = Bot(
    health: 20,
    maxHealth: 20,
    position: 0,
    hasActed: false,
    action: ActNone
  )

  for i, c in gridStr:
    case c:
    of '@':
      result.bot.position = result.grid.len
      result.grid.add(Empty)
    of '>':
      result.grid.add(Exit)
    of 'B':
      result.grid.add(Battery)
    of 'W':
      result.grid.add(Weapon)
    of 'S':
      result.grid.add(Slug)
    of 'C':
      result.grid.add(Crew)
    of 'M':
      result.grid.add(Mine)
    else:
      result.grid.add(Empty)

proc updateSenses*(state: var LevelState) =
  ## Updates the immediate adjacent senses of the bot based on current grid.
  let pos = state.bot.position
  let gridLen = state.grid.len

  state.bot.nearTiles[Forward] =
    if inBounds(pos + 1, gridLen): state.grid[pos + 1] else: Wall
  state.bot.nearTiles[Backward] =
    if inBounds(pos - 1, gridLen): state.grid[pos - 1] else: Wall

  for dir in [Forward, Backward]:
    let step = if dir == Forward: 1 else: -1
    for d in 1..3:
      let checkPos = pos + (step * d)
      state.bot.radarTiles[dir][d - 1] =
        if inBounds(checkPos, gridLen): state.grid[checkPos] else: Wall

proc tick*(state: var LevelState, playTurn: proc(bot: var Bot) {.nimcall.}) =
  ## Runs one turn of the game loop, invoking the player's brain and executing the results.
  if state.isSolved or state.isFailed:
    return

  state.bot.hasActed = false
  state.bot.action = ActNone
  state.botBitten = false

  if state.scrapQueue.len > 0:
    state.bot.currentScrap = state.scrapQueue[min(state.scrapIndex, state.scrapQueue.len - 1)]

  state.updateSenses()
  playTurn(state.bot)

  state.turn += 1
  state.log.setLen(0)

  let pos = state.bot.position
  let action = state.bot.action
  let dir = state.bot.actionDir
  let gridLen = state.grid.len

  case action:
  of ActNone:
    state.log.add("Bot stands inert.")
  of ActWalk:
    if state.scrapQueue.len > 0 and not scrapPasses(state.bot.currentScrap):
      # Sorting belt: walking a reject forward jams the drive.
      state.bot.health = 0
      state.log.add("MIS-SORT! Discard forced a reject down the line — critical jam! (0 HP)")
    else:
      let next = targetPos(pos, dir)
      if not inBounds(next, gridLen):
        state.log.add("Bot bumps heavily into a metal bulkhead.")
      else:
        let targetKind = state.grid[next]
        case targetKind:
        of Empty, Exit, Mine:
          state.bot.position = next
          if targetKind == Mine:
            state.bot.health = 0
            state.log.add("CRITICAL COLLISION: Bot rolled onto a landmine! BOOM!")
          elif targetKind == Exit:
            state.log.add("Bot rolls into the airlock exit! Corridor cleared.")
          else:
            state.bot.health -= 1
            state.log.add("Bot rolls " & (if dir == Forward: "Forward" else: "Backward") & ". (-1 energy)")
        else:
          state.log.add("Bot is blocked by " & $targetKind & ".")
      if state.scrapQueue.len > 0: inc state.scrapIndex   # kept item consumed
  of ActCollect:
    let next = targetPos(pos, dir)
    if inBounds(next, gridLen):
      let targetKind = state.grid[next]
      if targetKind == Battery:
        state.bot.equipment.incl(EqBattery)
        state.bot.health = state.bot.maxHealth
        state.grid[next] = Empty
        state.log.add("Bot collects Backup Battery! Energy fully restored.")
      elif targetKind == Weapon:
        state.bot.equipment.incl(EqBlaster)
        state.grid[next] = Empty
        state.log.add("Bot scavenges a rusty Laser Blaster! Attack unlocked.")
      else:
        state.log.add("No collectable salvage there.")
    else:
      state.log.add("No salvage found in that direction.")
  of ActAttack:
    if EqBlaster notin state.bot.equipment:
      state.log.add("Bot attempts to attack, but lack of software license or weapon halts operation.")
    else:
      let next = targetPos(pos, dir)
      if inBounds(next, gridLen):
        let targetKind = state.grid[next]
        if targetKind == Slug:
          state.grid[next] = Empty
          state.log.add("Bot attacks Slug! Dealt 10 impact damage. (Slug crushed)")
        else:
          state.log.add("Bot flails limbs, hitting nothing.")
      else:
        state.log.add("Bot hits wall bulkhead in vain.")
  of ActRest:
    if EqRestModule in state.bot.equipment:
      state.bot.health = min(state.bot.health + 5, state.bot.maxHealth)
      state.log.add("Bot rests to run software defragmentation. Restored 5 HP.")
    else:
      state.log.add("Bot attempts to rest, but Rest Module is missing.")
    if state.scrapQueue.len > 0:
      inc state.scrapIndex   # reject discarded off the belt
      state.log.add("Reject scrap discarded off the belt.")
  of ActRescue:
    let next = targetPos(pos, dir)
    if inBounds(next, gridLen):
      let targetKind = state.grid[next]
      if targetKind == Crew:
        state.grid[next] = Empty
        state.log.add("Bot rescues and reboots deactivated buddy bot!")
      else:
        state.log.add("No repairable unit there.")
    else:
      state.log.add("Nothing to rescue there.")
  of ActShoot:
    if EqBlaster notin state.bot.equipment:
      state.log.add("Blaster module not found.")
    else:
      state.log.add("Bot fires Laser Blaster " & (if dir == Forward: "Forward" else: "Backward") & "!")
      var hit = false
      let step = if dir == Forward: 1 else: -1
      for d in 1..3:
        let next = pos + (step * d)
        if not inBounds(next, gridLen):
          break
        let kind = state.grid[next]
        if kind == Wall:
          break
        if kind == Slug:
          state.grid[next] = Empty
          state.log.add("Laser beam vaporizes Slug! Dealt 10 damage. (Slug destroyed)")
          hit = true
          break
        if kind == Mine:
          state.grid[next] = Empty
          state.log.add("Laser beam detonates a landmine at safe range! (Mine cleared)")
          hit = true
          break
      if not hit:
        state.log.add("Laser beam harmlessly dissipates into the dark.")

  # Plasma timing field: walking during a venting cycle (even turns) is lethal.
  if state.plasmaField and action == ActWalk and state.turn mod 2 == 0:
    state.bot.health = 0
    state.log.add("PLASMA VENT FIRES! Discard moved during an active discharge cycle. Incinerated.")

  # Environment Reactions: adjacent Slugs bite bot after it moves
  let botPos = state.bot.position
  for checkDir in [Forward, Backward]:
    let checkPos = targetPos(botPos, checkDir)
    if inBounds(checkPos, gridLen) and state.grid[checkPos] == Slug:
      let dmg = 4
      state.bot.health -= dmg
      state.botBitten = true
      state.log.add("Slug bites Bot! Discard takes " & $dmg & " corrosive damage. (HP: " & $state.bot.health & ")")

  # Level Outcomes
  if state.bot.health <= 0:
    state.isFailed = true
    state.log.add("CRITICAL FAILURE: Discard's battery fully depleted (0 HP).")
  elif state.grid[state.bot.position] == Exit:
    if state.grid.anyIt(it == Crew):
      state.isFailed = true
      state.log.add("FAILURE: Left the area without salvaging all deactivated buddy bots!")
    else:
      state.isSolved = true
      state.log.add("SUCCESS! Exit airlock reached safely.")
  elif state.turn >= state.maxTurns:
    state.isFailed = true
    state.log.add("CRITICAL FAILURE: Operation timed out (max turns reached).")

proc runLevel*(
  gridStr: string,
  maxTurns: int,
  setupBot: proc(bot: var Bot) {.nimcall.},
  playTurn: proc(bot: var Bot) {.nimcall.},
  plasmaField: bool = false,
  scrapQueue: seq[Scrap] = @[]
): RunResult =
  ## Runs a level to completion and returns frames + outcome. Does not quit().
  var state = initLevel(gridStr, maxTurns, plasmaField, scrapQueue)
  if setupBot != nil:
    setupBot(state.bot)
  result.frames = @[state]
  while not state.isSolved and not state.isFailed:
    state.tick(playTurn)
    result.frames.add(state)
