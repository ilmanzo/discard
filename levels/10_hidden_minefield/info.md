# LEVEL 10: HIDDEN MINEFIELD

### Lore
The corridor ahead is seeded with live **landmines** (`M`). Step onto one and Discard is vaporised instantly (0 HP, game over). In a one-wide shaft you cannot walk around them — so clear them at range: a blaster shot down the corridor **detonates the nearest mine safely** before you advance.

Each turn you must look before you leap: sweep the radar ahead, and if a mine sits within range, shoot; otherwise the path is clear, so step forward.

This is the level for **custom iterators**. An `iterator` is a resumable routine that `yield`s values one at a time into a `for` loop — perfect for "give me each radar reading ahead, in order" without building an intermediate `seq`.

---

### Objectives
- Write a custom `iterator` that `yield`s the radar reading at each distance ahead.
- `for`-loop over it; if any reading is a `Mine`, `shoot(Forward)` to detonate it.
- Otherwise `walk(Forward)`. Reach the exit (`>`) within **25 cycles** without detonating a mine under your own treads.

---

### Unlocked Abilities & Sensors
- **Grid Scanner**: custom sequential iterators:
  - Define: `iterator name(args): Type = ...`
  - Emit a value: the `yield` keyword.
- **Blaster** detonates a `Mine` in its path, exactly as it vaporises a `Slug`.

---

### Nim Syntax Manual: Iterators & `yield`

An `iterator` looks like a proc but may `yield` many times; it runs only inside a `for` loop, resuming where it left off after each value. The *pattern* (wire the decision yourself):
```nim
iterator radarSweep(bot: Bot): TileKind =
  yield bot.look(1, Forward)
  yield bot.look(2, Forward)
  yield bot.look(3, Forward)

proc playTurn*(bot: var Bot) =
  for tile in radarSweep(bot):
    # inspect each reading...
    discard
```
Because the bot takes exactly **one action per turn**, the loop is for *deciding*, not for acting — gather what's ahead, then issue a single `shoot` or `walk`.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Sweep the radar with a custom iterator, detonate mines in range, and advance when clear.
3. Run `./discard check` (use `./discard check --step` to inch through the field one cycle at a time).
