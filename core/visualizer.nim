# core/visualizer.nim
# The block-based ANSI terminal visualizer and animator for Discard.

import std/[os, strutils, strformat]
import types, engine, ansi

proc checkUnicodeSupport(): bool =
  ## Checks standard POSIX environment variables for UTF-8/Unicode support.
  for varName in ["LANG", "LC_ALL", "LC_CTYPE"]:
    let val = getEnv(varName).toLowerAscii()
    if "utf-8" in val or "utf8" in val:
      return true
  return false

let hasUnicode = checkUnicodeSupport()

proc checkFlag(flag: string): bool =
  for i in 1..paramCount():
    if paramStr(i) == flag:
      return true
  return false

let stepMode  = checkFlag("--step")
let fastMode  = checkFlag("--fast")
let batchMode = checkFlag("--batch")

# Load entity colors and frames from separate assets files at compile-time (Zero runtime I/O overhead!)
const
  # Bot
  BotEvenUnicode = staticRead("assets/bot_even.txt").splitLines()
  BotOddUnicode  = staticRead("assets/bot_odd.txt").splitLines()
  BotEvenAscii   = staticRead("assets/bot_even_ascii.txt").splitLines()
  BotOddAscii    = staticRead("assets/bot_odd_ascii.txt").splitLines()

  # Gopher (Mid-Boss)
  GopherHeadEven = staticRead("assets/gopher_head_even.txt").splitLines()
  GopherHeadOdd  = staticRead("assets/gopher_head_odd.txt").splitLines()

  # Crab (Final Boss)
  CrabHeadEvenUnicode = staticRead("assets/crab_head_even.txt").splitLines()
  CrabHeadOddUnicode  = staticRead("assets/crab_head_odd.txt").splitLines()
  CrabHeadEvenAscii   = staticRead("assets/crab_head_even_ascii.txt").splitLines()
  CrabHeadOddAscii    = staticRead("assets/crab_head_odd_ascii.txt").splitLines()

  # Slug (Normal enemy)
  SlugEvenUnicode = staticRead("assets/slug_even.txt").splitLines()
  SlugOddUnicode  = staticRead("assets/slug_odd.txt").splitLines()
  SlugEvenAscii   = staticRead("assets/slug_even_ascii.txt").splitLines()
  SlugOddAscii    = staticRead("assets/slug_odd_ascii.txt").splitLines()

  # Crew (Rescue buddy)
  CrewEven = staticRead("assets/crew_even.txt").splitLines()
  CrewOdd  = staticRead("assets/crew_odd.txt").splitLines()

  # Level registry (used to display the title during the check animation)
  LevelInfoRaw = staticRead("assets/levels.txt")

  # Visible width of the crab boss tile (asset is 9 chars wide; bigger than the standard 5)
  CrabTileWidth = 9

proc resolveLevelTitle(): string =
  ## The verify binary lives at levels/<dir>/verify; pull dir name and look it up in the registry.
  let dirName =
    try: getAppFilename().parentDir.lastPathPart
    except CatchableError: ""
  if dirName.len == 0: return ""
  for line in LevelInfoRaw.splitLines():
    let parts = line.strip().split(':')
    if parts.len >= 3 and parts[1] == dirName:
      return "Level " & parts[0] & ": " & parts[2]
  return ""

let currentLevelTitle = resolveLevelTitle()

func getThemeColor(entity: string): string =
  ## Maps an entity name to its ANSI color. Inlined from the old colors.txt — colors never change at runtime.
  case entity
  of "bot": ColorYellow
  of "slug", "crab", "exit", "mine": ColorRed
  of "gopher", "battery": ColorBlue
  of "crew": ColorCyan
  of "weapon": ColorPurple
  of "wall", "empty": ColorGrey
  else: ColorReset

func styled(s, color: string): string =
  ColorBold & color & s & ColorReset

proc getTileBlock(kind: TileKind, isBot: bool, turn: int, bossKind: BossKind = bkNone): array[3, string] =
  ## Not a func: reads the global `let hasUnicode`, which the effect system treats as state.
  ## Returns the 3-line high, 5-character wide representation of a tile.
  if isBot:
    let lines = if turn mod 2 == 0:
                  if hasUnicode: BotEvenUnicode else: BotEvenAscii
                else:
                  if hasUnicode: BotOddUnicode else: BotOddAscii
    let color = getThemeColor("bot")
    return [
      " " & styled(lines[0], color),
      " " & styled(lines[1], color),
      " " & styled(lines[2], color)
    ]

  case kind:
  of Empty:
    let color = getThemeColor("empty")
    return [
      "     ",
      "  " & color & "." & ColorReset & "  ",
      "     "
    ]
  of Wall:
    let color = getThemeColor("wall")
    return [
      color & "#####" & ColorReset,
      color & "#####" & ColorReset,
      color & "#####" & ColorReset
    ]
  of Exit:
    let color = getThemeColor("exit")
    return [
      ColorBold & color & "/---\\" & ColorReset,
      ColorBold & color & "| # |" & ColorReset,
      ColorBold & color & "\\---/" & ColorReset
    ]
  of Mine:
    let color = getThemeColor("mine")
    return [
      "  " & ColorBold & color & "/\\" & ColorReset & " ",
      " " & ColorBold & color & "(M)" & ColorReset & " ",
      "  " & ColorBold & color & "\\/" & ColorReset & " "
    ]
  of Battery:
    let color = getThemeColor("battery")
    return [
      ColorBold & color & "+===+" & ColorReset,
      ColorBold & color & "|[B]|" & ColorReset,
      ColorBold & color & "+---+" & ColorReset
    ]
  of Weapon:
    let color = getThemeColor("weapon")
    return [
      ColorBold & color & "+===+" & ColorReset,
      ColorBold & color & "|[W]|" & ColorReset,
      ColorBold & color & "+---+" & ColorReset
    ]
  of Slug:
    case bossKind
    of bkGopher:
      let color = getThemeColor("gopher")
      let lines = if turn mod 2 == 0: GopherHeadEven else: GopherHeadOdd
      return [
        styled(lines[0], color),
        styled(lines[1], color),
        styled(lines[2], color)
      ]
    of bkCrab:
      let color = getThemeColor("crab")
      let lines = if turn mod 2 == 0:
                    if hasUnicode: CrabHeadEvenUnicode else: CrabHeadEvenAscii
                  else:
                    if hasUnicode: CrabHeadOddUnicode else: CrabHeadOddAscii
      return [
        styled(lines[0], color),
        styled(lines[1], color),
        styled(lines[2], color)
      ]
    of bkNone:
      let lines = if turn mod 2 == 0:
                    if hasUnicode: SlugEvenUnicode else: SlugEvenAscii
                  else:
                    if hasUnicode: SlugOddUnicode else: SlugOddAscii
      let color = getThemeColor("slug")
      return [
        styled(lines[0], color),
        styled(lines[1], color),
        styled(lines[2], color)
      ]
  of Crew:
    let lines = if turn mod 2 == 0: CrewEven else: CrewOdd
    let color = getThemeColor("crew")
    return [
      styled(lines[0], color),
      styled(lines[1], color),
      " " & styled(lines[2], color) & " "
    ]

func fxCenter(token: string, tl, vw: int, color: string): string =
  ## Centers a combat token (visible length `tl`) in a cell `vw` wide, colored.
  let pad = max(0, vw - tl)
  repeat(" ", pad div 2) & ColorBold & color & token & ColorReset & repeat(" ", pad - pad div 2)

proc renderLevel*(state: LevelState) =
  ## Renders a single frame of the level state using block compositions.
  # 1. Clear terminal and print header
  stdout.write(ClearScreen)
  stdout.writeLine(fmt"{ColorBold}{ColorCyan}=== DISCARD OPERATION CORRIDOR ==={ColorReset}")
  if currentLevelTitle.len > 0:
    stdout.writeLine(fmt"{ColorBold}{ColorYellow}{currentLevelTitle}{ColorReset}")
  stdout.writeLine(fmt"Turn: {ColorBold}{state.turn}{ColorReset} / {state.maxTurns}")
  if state.plasmaField:
    if state.turn mod 2 == 0:
      stdout.writeLine(fmt"{ColorBold}{ColorRed}  PLASMA FIELD: VENTING (do not walk!){ColorReset}")
    else:
      stdout.writeLine(fmt"{ColorBold}{ColorGreen}  PLASMA FIELD: SAFE (clear to move){ColorReset}")
  if state.scrapQueue.len > 0:
    let s = state.bot.currentScrap
    let (icon, name, stat, col) =
      case s.kind
      of skGear: ((if hasUnicode: "⚙" else: "[G]"), "GEAR", "teeth = " & $s.teeth, ColorYellow)
      of skWire: ((if hasUnicode: "≈" else: "[W]"), "WIRE", "length = " & $s.length, ColorCyan)
      of skCore: ((if hasUnicode: "◉" else: "[C]"), "CORE", "energy = " & $s.energy, ColorBlue)
    let bar = ColorBold & col & (if hasUnicode: "┃" else: "|") & ColorReset
    stdout.writeLine(fmt"  {bar} {ColorGrey}INCOMING SCRAP{ColorReset}")
    stdout.writeLine(fmt"  {bar}  {ColorBold}{col}{icon}  {name}{ColorReset}")
    stdout.writeLine(fmt"  {bar}  {col}{stat}{ColorReset}{ColorGrey}    walk = keep · rest = drop{ColorReset}")

  # 2. Render Bot Telemetry
  let hpPercent = float(state.bot.health) / float(state.bot.maxHealth)
  let barWidth = 10
  let filledBars = int(hpPercent * float(barWidth))
  var bars = newSeq[string](barWidth)
  for i in 0..<barWidth:
    bars[i] = if i < filledBars: ColorGreen & "█" & ColorReset else: ColorGrey & "░" & ColorReset
  let barStr = "[" & bars.join("") & "]"

  stdout.write(fmt"Discard Energy: {barStr} {ColorBold}{state.bot.health}{ColorReset}/{state.bot.maxHealth} HP")

  # Render inventory/perks
  var inventory = @[ColorGrey & "Thrusters" & ColorReset]
  if EqBattery in state.bot.equipment: inventory.add(ColorBlue & "Battery" & ColorReset)
  if EqBlaster in state.bot.equipment: inventory.add(ColorPurple & "Blaster" & ColorReset)
  if EqRestModule in state.bot.equipment: inventory.add(ColorGreen & "Rest Module" & ColorReset)

  let cards = inventory.join(", ")
  stdout.writeLine(fmt"  |  Active Cards: {cards}")

  # Boss HP bar (only when an active boss is present)
  if state.boss.kind != bkNone and state.boss.hp > 0:
    let (bossName, bossColor) =
      if state.boss.kind == bkGopher: ("GOPHER MID-BOSS", getThemeColor("gopher"))
      else: ("FERRIS FINAL BOSS", getThemeColor("crab"))
    var bossBar = ""
    for i in 0 ..< state.boss.maxHp:
      bossBar.add(if i < state.boss.hp: bossColor & "█" & ColorReset else: ColorGrey & "░" & ColorReset)
    stdout.writeLine(fmt"  {ColorBold}{bossColor}{bossName}{ColorReset}  HP: [{bossBar}] {state.boss.hp}/{state.boss.maxHp}")

  stdout.writeLine(fmt"{ColorGrey}================================================================{ColorReset}")

  # 3. Collect and print the block-based corridor (Row-by-Row rendering)
  var corridorRows: array[3, string] = ["", "", ""]

  # Combat FX overlay: a tile-aligned row drawn only on turns where something fights.
  let bpos = state.bot.position
  let astep = if state.bot.actionDir == Forward: 1 else: -1
  let hasBlaster = EqBlaster in state.bot.equipment
  let beamOn = state.bot.action == ActShoot and hasBlaster
  let meleeOn = state.bot.action == ActAttack and hasBlaster
  let beamEnd =
    if astep == 1: min(bpos + 3, state.grid.len - 1)
    else: max(bpos - 3, 0)
  var fxRow = ""

  for i, kind in state.grid:
    let isBot = (i == bpos)
    let bossHere = state.boss.kind != bkNone and i == state.boss.pos and state.boss.hp > 0
    let bossKind = if bossHere: state.boss.kind else: bkNone

    let blockLines = getTileBlock(kind, isBot, state.turn, bossKind)
    corridorRows[0].add(blockLines[0] & " ")
    corridorRows[1].add(blockLines[1] & " ")
    corridorRows[2].add(blockLines[2] & " ")

    # Build the matching FX cell (same visible width as the tile + 1 separator).
    let vw =
      if isBot: 6
      elif bossHere and state.boss.kind == bkCrab: CrabTileWidth
      else: 5
    let onBeam = beamOn and i != bpos and
                 (if astep == 1: i > bpos and i <= beamEnd else: i < bpos and i >= beamEnd)
    if isBot and state.botBitten:
      fxRow.add(fxCenter((if hasUnicode: "✦✦✦" else: "!!!"), 3, vw, ColorRed) & " ")
    elif onBeam:
      let head = if astep == 1: (if hasUnicode: "════►" else: "====>")
                 else: (if hasUnicode: "◄════" else: "<====")
      let fill = if hasUnicode: "═════" else: "====="
      fxRow.add(fxCenter((if i == beamEnd: head else: fill), 5, vw, ColorPurple) & " ")
    elif meleeOn and i == bpos + astep:
      fxRow.add(fxCenter((if hasUnicode: "✸✸✸" else: "***"), 3, vw, ColorYellow) & " ")
    elif state.scrapQueue.len > 0 and isBot:
      # Sorting result of this turn's decision (shown under the bot).
      if state.bot.action == ActWalk and state.bot.health <= 0:
        fxRow.add(fxCenter("JAM!", 4, vw, ColorRed) & " ")
      elif state.bot.action == ActWalk:
        fxRow.add(fxCenter((if hasUnicode: "KEEP►" else: "KEEP>"), 5, vw, ColorGreen) & " ")
      elif state.bot.action == ActRest:
        fxRow.add(fxCenter("DROP", 4, vw, ColorYellow) & " ")
      else:
        fxRow.add(repeat(" ", vw + 1))
    else:
      fxRow.add(repeat(" ", vw + 1))

  stdout.writeLine(fmt"{ColorGrey} Corridor:{ColorReset}")
  stdout.writeLine("  " & corridorRows[0])
  stdout.writeLine("  " & corridorRows[1])
  stdout.writeLine("  " & corridorRows[2])
  stdout.writeLine("  " & fxRow)   # always drawn (blank when idle) so the block height never changes
  stdout.writeLine(fmt"{ColorGrey}================================================================{ColorReset}")

  # 4. Render Event Log for this turn
  stdout.writeLine(fmt"{ColorBold}Log Telemetry:{ColorReset}")
  if state.log.len == 0:
    stdout.writeLine("  - Idle.")
  else:
    for event in state.log:
      stdout.writeLine(fmt"  - {event}")
  stdout.writeLine("")
  stdout.flushFile()

const FramesPerState = 10
  ## Each turn's frame is held on screen this many ticks so the action stays readable.

proc animateLevel*(states: seq[LevelState], delayMs: int = 150) =
  ## Animates a sequence of level frames, holding each one for FramesPerState ticks.
  for i, state in states:
    renderLevel(state)
    if stepMode:
      if i < states.len - 1:
        stdout.write(fmt"{ColorBold}{ColorYellow}--- STEP DEBUGGER: Press Enter for next turn ---{ColorReset}")
        stdout.flushFile()
        discard stdin.readLine()
    else:
      for _ in 1 .. FramesPerState:   # hold the drawn frame (flicker-free, no re-render)
        sleep(delayMs)

proc verifyLevel*(
  grid: string,
  maxTurns: int,
  setupBot: proc(bot: var Bot) {.nimcall.},
  playTurn: proc(bot: var Bot) {.nimcall.},
  successMessage: string,
  extraCheck: proc(state: LevelState): bool {.nimcall.} = nil,
  plasmaField: bool = false,
  scrapQueue: seq[Scrap] = @[]
) =
  ## Thin wrapper: runs the level via runLevel, animates, then quits.
  let res = runLevel(grid, maxTurns, setupBot, playTurn, plasmaField, scrapQueue)
  if not batchMode:
    animateLevel(res.frames, delayMs = if fastMode: 80 else: 150)
  if res.frames[^1].isSolved:
    if extraCheck != nil and not extraCheck(res.frames[^1]):
      quit(1)
    let final = res.frames[^1]
    echo fmt"{ColorBold}{ColorGreen}=== LEVEL CLEARED! ==={ColorReset}"
    echo successMessage
    echo fmt"{ColorBold}{ColorCyan}Score: {ColorReset}{final.turn} turns | {final.bot.health}/{final.bot.maxHealth} HP remaining"
    quit(0)
  else:
    echo fmt"{ColorBold}{ColorRed}=== SYSTEM FAILURE ==={ColorReset}"
    echo "Check your code in player.nim and try again."
    quit(1)
