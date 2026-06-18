# discard.nim
# Main CLI tool for Discard.

import std/[os, strutils, osproc, strformat]
import checksums/md5
import core/ansi

const
  StateFile = ".discard_state"
  CacheFile = ".discard_cache"
  DefaultPlayerTemplate = "import discard_api\n\nproc playTurn*(bot: var Bot) =\n  bot.walk()\n"

type
  LevelDef = object
    num: int
    name: string
    title: string

proc parseLevels(): seq[LevelDef] =
  const raw = staticRead("core/assets/levels.txt").splitLines()
  for line in raw:
    if line.strip().len > 0:
      let parts = line.split(':')
      if parts.len >= 3:
        result.add(LevelDef(
          num: parseInt(parts[0].strip()),
          name: parts[1].strip(),
          title: parts[2].strip()
        ))

const LevelList = parseLevels()

proc getLevelDef(num: int): LevelDef =
  for lvl in LevelList:
    if lvl.num == num:
      return lvl
  echo fmt"{ColorBold}{ColorRed}Error: unknown level {num} (valid: 0-{LevelList.len - 1}). State file may be corrupt — run './discard reset all'.{ColorReset}"
  quit(1)

proc loadState(): (int, string) =
  if fileExists(StateFile):
    try:
      let content = readFile(StateFile).strip()
      let lines = content.splitLines()
      if lines.len >= 2:
        let lvl = parseInt(lines[0].strip())
        let status = lines[1].strip()
        return (lvl, status)
    except CatchableError:
      discard
  return (0, "unsolved")

proc saveState(lvl: int, status: string) =
  writeFile(StateFile, $lvl & "\n" & status & "\n")

proc showHelp() =
  echo fmt"{ColorBold}{ColorCyan}=== DISCARD PROTOCOL INTERFACE ==={ColorReset}"
  echo "Control Discard's subroutines using the following commands:"
  echo ""
  echo fmt"  {ColorBold}./discard status{ColorReset}         Show overall bot repair status and progress."
  echo fmt"  {ColorBold}./discard levels{ColorReset}         Show roadmap of all calibration levels."
  echo fmt"  {ColorBold}./discard hint{ColorReset}           Read instructions/docs for the current level."
  echo fmt"  {ColorBold}./discard api{ColorReset}            Show the in-game API cheat sheet for the current level."
  echo fmt"  {ColorBold}./discard check{ColorReset}          Compile and run simulation of current level."
  echo fmt"  {ColorBold}./discard check --step{ColorReset}   Run simulation in Step Debugger mode (press Enter each turn)."
  echo fmt"  {ColorBold}./discard watch{ColorReset}          Start Auto-Compiler watcher (re-runs check on player.nim saves)."
  echo fmt"  {ColorBold}./discard next{ColorReset}           Progress to the next level (requires cleared level)."
  echo fmt"  {ColorBold}./discard reset{ColorReset}          Reset the current level template in player.nim."
  echo fmt"  {ColorBold}./discard reset all{ColorReset}      Reset the entire game progress and start from Level 1."
  echo fmt"  {ColorBold}./discard select <num>{ColorReset}   Jump directly to Level <num> (bypasses unlock requirements)."
  echo fmt"  {ColorBold}./discard solve{ColorReset}          Load reference solution for current level to player.nim."
  echo ""

proc displayStatus(lvlNum: int, status: string) =
  let def = getLevelDef(lvlNum)
  echo fmt"{ColorBold}{ColorCyan}=== DISCARD STATUS ==={ColorReset}"
  echo fmt"Current Subsystem: {ColorBold}{ColorYellow}Level {lvlNum} - {def.title}{ColorReset}"

  if status == "solved":
    echo fmt"Module Integrity:  {ColorBold}{ColorGreen}100% (SOLVED){ColorReset} -> Ready to run './discard next'"
  else:
    echo fmt"Module Integrity:  {ColorBold}{ColorRed}CORRUPTED (UNSOLVED){ColorReset} -> Write your AI in player.nim and run './discard check'"

  echo ""
  echo fmt"Chassis Corrosion: {ColorRed}92% Rust (Borrow-checker constraint override required){ColorReset}"
  echo "Core Engine:       Unappreciated Nim-driven compiler firmware"
  echo ""

proc processInline(s: string): string =
  var i = 0
  while i < s.len:
    if i + 1 < s.len and s[i] == '*' and s[i+1] == '*':
      let close = s.find("**", i + 2)
      if close >= 0:
        result.add(ColorBold & s[i+2..<close] & ColorReset)
        i = close + 2
      else:
        result.add(s[i]); inc i
    elif s[i] == '`':
      let close = s.find('`', i + 1)
      if close >= 0:
        result.add(ColorYellow & s[i..close] & ColorReset)
        i = close + 1
      else:
        result.add(s[i]); inc i
    else:
      result.add(s[i]); inc i

proc colorizeMarkdown(text: string): string =
  var inCode = false
  for line in text.splitLines():
    if line.startsWith("```"):
      inCode = not inCode
      result.add(ColorGrey & line & ColorReset & "\n")
    elif inCode:
      result.add(ColorGrey & line & ColorReset & "\n")
    elif line.startsWith("# "):
      result.add(ColorBold & ColorCyan & line[2..^1] & ColorReset & "\n")
    elif line.startsWith("## "):
      result.add(ColorBold & ColorYellow & line[3..^1] & ColorReset & "\n")
    elif line.startsWith("### "):
      result.add(ColorBold & ColorGreen & line[4..^1] & ColorReset & "\n")
    elif line.startsWith("- ") or line.startsWith("* "):
      result.add("  " & ColorCyan & "•" & ColorReset & " " & processInline(line[2..^1]) & "\n")
    else:
      result.add(processInline(line) & "\n")

proc displayHint(lvlNum: int) =
  let def = getLevelDef(lvlNum)
  let infoPath = "levels" / def.name / "info.md"
  if fileExists(infoPath):
    stdout.write(colorizeMarkdown(readFile(infoPath)))
  else:
    echo fmt"Error: level information file not found at {infoPath}"

proc deployTemplate(def: LevelDef) =
  ## Copies the level template to player.nim, or writes the minimal fallback.
  let templatePath = "levels" / def.name / "template.nim"
  if fileExists(templatePath):
    copyFile(templatePath, "player.nim")
  else:
    writeFile("player.nim", DefaultPlayerTemplate)

proc ensurePlayerFileExists(def: LevelDef) =
  if not fileExists("player.nim"):
    let templatePath = "levels" / def.name / "template.nim"
    if fileExists(templatePath):
      echo fmt"{ColorBold}{ColorGreen}Scaffolded player.nim from {def.name} template!{ColorReset}"
    deployTemplate(def)

proc checkLevel(lvlNum: int, stepMode: bool = false, fastMode: bool = false, batchMode: bool = false) =
  let def = getLevelDef(lvlNum)
  ensurePlayerFileExists(def)

  let verifyPath = "levels" / def.name / "verify.nim"
  if not fileExists(verifyPath):
    echo fmt"{ColorBold}{ColorRed}Error: verification script not found at {verifyPath}{ColorReset}"
    quit(1)

  let binaryPath = changeFileExt(verifyPath, "")
  let currentHash = getMD5(readFile("player.nim") & readFile(verifyPath))
  let cachedHash = if fileExists(CacheFile): readFile(CacheFile).strip() else: ""

  if currentHash != cachedHash or not fileExists(binaryPath):
    echo fmt"{ColorBold}{ColorYellow}Compiling Discard's Nim-firmware for {def.title}...{ColorReset}"
    let compileCode = execCmd(fmt"nim c --hints:off --warnings:off -o:{binaryPath} {verifyPath}")
    if compileCode != 0:
      echo ColorBold & ColorRed & "\nCompilation failed." & ColorReset
      return
    writeFile(CacheFile, currentHash)

  let flags = (if stepMode: " --step" else: "") &
              (if fastMode: " --fast" else: "") &
              (if batchMode: " --batch" else: "")
  let exitCode = execCmd(binaryPath & flags)

  if exitCode == 0:
    saveState(lvlNum, "solved")
    if not batchMode:
      echo &"{ColorBold}{ColorGreen}\nSubsystem calibrated successfully! Run './discard next' to secure and progress.{ColorReset}"
  else:
    if not batchMode:
      echo &"{ColorBold}{ColorRed}\nSimulation ended in critical failure.{ColorReset}"
  if batchMode:
    quit(exitCode)

proc nextLevel(lvlNum: int, status: string) =
  if status != "solved":
    echo fmt"{ColorBold}{ColorRed}ACCESS DENIED: You must calibrate the current subsystem first!{ColorReset}"
    echo "Run './discard check' and ensure it clears successfully."
    quit(1)

  let currentDef = getLevelDef(lvlNum)
  let nextLvlNum = lvlNum + 1

  if nextLvlNum >= LevelList.len:
    echo fmt"{ColorBold}{ColorGreen}ALL SYSTEMS REBOOTED! Discard has escaped the scrap yard and proven Nim's superiority!{ColorReset}"
    echo "Congratulations! You have mastered Nim-based firmware automation."
    quit(0)

  let nextDef = getLevelDef(nextLvlNum)

  # Archive previous solution
  let archivePath = "levels" / currentDef.name / "solution.nim"
  if fileExists("player.nim"):
    copyFile("player.nim", archivePath)
    echo fmt"Archived Level {lvlNum} solution to {archivePath}"

  # Deploy next level template
  deployTemplate(nextDef)
  echo fmt"{ColorBold}{ColorGreen}Deployed new template into player.nim for Level {nextLvlNum} ({nextDef.title}).{ColorReset}"

  saveState(nextLvlNum, "unsolved")
  echo ""
  echo fmt"{ColorBold}{ColorYellow}=== ADVANCED TO LEVEL {nextLvlNum}: {nextDef.title} ==={ColorReset}"
  displayHint(nextLvlNum)

proc resetLevel(lvlNum: int, resetAll: bool = false) =
  if resetAll:
    let def = getLevelDef(0)
    deployTemplate(def)
    saveState(0, "unsolved")
    echo fmt"{ColorBold}{ColorYellow}Game progress and player.nim have been reset to Level 0!{ColorReset}"
  else:
    let def = getLevelDef(lvlNum)
    deployTemplate(def)
    saveState(lvlNum, "unsolved")
    echo fmt"{ColorBold}{ColorYellow}Level {lvlNum} has been reset to its template!{ColorReset}"

proc selectLevel(targetStr: string) =
  var targetLvl = 0
  try:
    targetLvl = parseInt(targetStr.strip())
  except ValueError:
    echo fmt"{ColorBold}{ColorRed}Error: Invalid level number: {targetStr}{ColorReset}"
    quit(1)

  if targetLvl < 0 or targetLvl >= LevelList.len:
    echo fmt"{ColorBold}{ColorRed}Error: Level {targetLvl} does not exist. Choose 0 to {LevelList.len - 1}.{ColorReset}"
    quit(1)

  let def = getLevelDef(targetLvl)
  deployTemplate(def)
  saveState(targetLvl, "unsolved")
  echo fmt"{ColorBold}{ColorGreen}Selected and deployed Level {targetLvl} ({def.title}) into player.nim!{ColorReset}"
  echo ""
  displayHint(targetLvl)

proc solveLevel(lvlNum: int) =
  let def = getLevelDef(lvlNum)
  let solutionPath = "levels" / def.name / "solution.nim"

  if not fileExists(solutionPath):
    echo fmt"{ColorBold}{ColorRed}Error: No reference solution found for {def.title}.{ColorReset}"
    quit(1)

  let content = readFile(solutionPath)

  try:
    writeFile("player.nim", content)
  except IOError, OSError:
    echo fmt"{ColorBold}{ColorRed}Error: Failed to write solution to player.nim{ColorReset}"
    quit(1)

  echo fmt"{ColorBold}{ColorGreen}=== REFERENCE SOLUTION DEPLOYED FOR {def.title.toUpperAscii()} ==={ColorReset}"
  echo "The reference solution has been loaded into player.nim."
  echo "You can study it below or run './discard check' to see it clear the level!"
  echo ""
  echo fmt"{ColorCyan}--- levels/{def.name}/solution.nim ---{ColorReset}"
  echo content
  echo fmt"{ColorCyan}-------------------------------------------{ColorReset}"
  echo ""

proc printApiManual(lvlNum: int) =
  echo fmt"{ColorBold}{ColorCyan}=== DISCARD REFERENCE MANUAL ==={ColorReset}"
  echo fmt"Current Subsystem Level: {lvlNum}"
  echo ""

  echo fmt"{ColorBold}{ColorYellow}--- MOVEMENT & ACTIONS (Choose exactly 1 per turn) ---{ColorReset}"
  echo fmt"  {ColorBold}bot.walk(dir = Forward){ColorReset}    Rolls the bot 1 tile in specified direction."

  if lvlNum >= 1:
    echo fmt"  {ColorBold}bot.collect(dir){ColorReset}          Picks up an item (Battery, Weapon) in specified direction."
  if lvlNum >= 2:
    echo fmt"  {ColorBold}bot.attack(dir){ColorReset}           Strikes adjacent hostile slug in specified direction."
  if lvlNum >= 3:
    echo fmt"  {ColorBold}bot.rest(){ColorReset}                 Activates Rest Module to restore 10% health."
  if lvlNum >= 4:
    echo fmt"  {ColorBold}bot.rescue(dir){ColorReset}           Powers up and rescues buddy bot in specified direction."
  if lvlNum >= 5:
    echo fmt"  {ColorBold}bot.shoot(dir = Forward){ColorReset}   Fires ranged laser blast up to 3 tiles away."

  echo ""
  echo fmt"{ColorBold}{ColorYellow}--- SENSORS & STATUS (Can call infinitely) ---{ColorReset}"
  if lvlNum >= 1:
    echo fmt"  {ColorBold}bot.feel(dir){ColorReset}             Inspects adjacent tile (returns TileKind)."
  if lvlNum >= 3:
    echo fmt"  {ColorBold}bot.health{ColorReset}                Current core energy level (int)."
    echo fmt"  {ColorBold}bot.maxHealth{ColorReset}             Maximum core energy capacity (int)."
  if lvlNum >= 5:
    echo fmt"  {ColorBold}bot.look(dist, dir = Forward){ColorReset} Scans corridor up to 3 tiles (returns TileKind)."

  if lvlNum >= 1:
    echo ""
    echo fmt"{ColorBold}{ColorYellow}--- TILE HELPER CONVENTIONS ---{ColorReset}"
    echo fmt"  {ColorBold}tile.isItem{ColorReset}      Returns true if salvage card (Battery/Weapon)."
    echo fmt"  {ColorBold}tile.isEnemy{ColorReset}     Returns true if hostile space-slug."
    echo fmt"  {ColorBold}tile.isCrew{ColorReset}      Returns true if deactivated buddy bot."

  echo ""
  echo fmt"{ColorBold}{ColorYellow}--- TYPES & VALUES ---{ColorReset}"
  echo fmt"  {ColorBold}Direction{ColorReset}         `Forward` (right), `Backward` (left)"
  if lvlNum >= 5:
    echo fmt"  {ColorBold}TileKind{ColorReset}         `Empty`, `Wall`, `Exit`, `Battery`, `Weapon`, `Slug`, `Crew`, `Mine`"
  echo ""

proc watchLevel(lvlNum: int, fastMode: bool = false) =
  let def = getLevelDef(lvlNum)
  ensurePlayerFileExists(def)

  echo fmt"{ColorBold}{ColorCyan}=== WATCH MODE ACTIVE ==={ColorReset}"
  echo fmt"Watching {ColorBold}player.nim{ColorReset} for changes..."
  echo "Press Ctrl+C to exit."
  echo ""

  checkLevel(lvlNum, fastMode = fastMode)

  var lastTime = getLastModificationTime("player.nim")

  while true:
    sleep(500)
    if fileExists("player.nim"):
      try:
        let currentTime = getLastModificationTime("player.nim")
        if currentTime != lastTime:
          lastTime = currentTime
          stdout.write(ClearScreen)
          stdout.flushFile()
          echo fmt"{ColorBold}{ColorYellow}>>> CHANGE DETECTED inside player.nim! Re-running simulation... <<<{ColorReset}"
          echo ""
          checkLevel(lvlNum, fastMode = fastMode)
      except IOError, OSError:
        discard

proc displayLevels() =
  echo fmt"{ColorBold}{ColorCyan}=== DISCARD PROTOCOL LEVEL ROADMAP ==={ColorReset}"
  echo "Track your calibration journey from scrap bot to escaped master firmware:"
  echo ""
  for lvl in LevelList:
    echo fmt"  {ColorBold}{ColorYellow}[{lvl.num}] {lvl.title}{ColorReset}"
  echo ""

proc main() =
  let args = commandLineParams()
  let (lvl, status) = loadState()

  let def = getLevelDef(lvl)
  ensurePlayerFileExists(def)

  if args.len == 0:
    showHelp()
    displayStatus(lvl, status)
    return

  case args[0]:
  of "help", "-h", "--help":
    showHelp()
  of "status":
    displayStatus(lvl, status)
  of "levels":
    displayLevels()
  of "hint", "docs":
    displayHint(lvl)
  of "api", "manual":
    printApiManual(lvl)
  of "check":
    let stepMode = "--step" in args or "step" in args
    let fastMode = "--fast" in args or "fast" in args
    let batchMode = "--batch" in args or "batch" in args
    checkLevel(lvl, stepMode, fastMode, batchMode)
  of "watch":
    let fastMode = "--fast" in args or "fast" in args
    watchLevel(lvl, fastMode)
  of "next":
    nextLevel(lvl, status)
  of "reset":
    let resetAll = args.len > 1 and (args[1] == "all" or args[1] == "--all")
    resetLevel(lvl, resetAll)
  of "select":
    if args.len < 2:
      echo fmt"{ColorBold}{ColorRed}Error: Please specify a level number, e.g. ./discard select 2{ColorReset}"
      quit(1)
    selectLevel(args[1])
  of "solve":
    solveLevel(lvl)
  else:
    echo fmt"Unknown command: {args[0]}"
    showHelp()

main()
