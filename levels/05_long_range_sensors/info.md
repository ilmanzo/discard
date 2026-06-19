# LEVEL 5: GOPHER (MID-BOSS)

### Lore
WARNING! A reinforced **Golang Gopher** blocks the corridor ahead. This is your first Mid-Boss encounter!

The Gopher takes **2 hits** to bring down. Step adjacent and it will gnaw your chassis for 4 HP per turn — melee is suicide.

Fortunately, your **Radar Scanner Card** is now active! With this, Discard can scan ahead up to **3 tiles** away using `bot.look(distance, direction)`.

Stay at range and fire your **Laser Blaster** with `bot.shoot(Forward)` until the Gopher's HP hits zero, then roll forward safely!

---

### Objectives
- Look up to 3 tiles ahead using `bot.look(dist, Forward)`.
- When a `Slug`-typed tile is detected at distance 2 or 3, shoot it using `bot.shoot(Forward)`.
- Drain the Gopher's HP to zero and reach the exit portal (`>`) within **25 cycles** without taking damage.

---

### Unlocked Abilities & Sensors
- **Radar Scanner**: Scan the corridor at distance:
  - `bot.look(distance, direction)`: Returns the `SpaceKind` at the specified distance (1 to 3).
  - *Default direction*: `Forward`
- **Laser Blaster (Ranged)**: Fire ranged laser beams:
  - `bot.shoot(direction)`: Fires a laser up to 3 tiles away.
  - *Default direction*: `Forward`

---

### Nim Syntax Manual: Helper Procs & Implicit `result`

When writing helper procedures (functions) in Nim, we can return values. Nim provides an implicit variable called **`result`** representing the return value. You don't need to declare it, and you don't need a `return` keyword!

For this level, we want to define a helper proc to check if a tile is a threat:
```nim
proc isThreat(bot: Bot, dist: int): bool =
  # 'result' is implicitly declared as a bool (defaulting to false)
  if bot.look(dist, Forward) == Slug:
    result = true # Set the implicit return variable!
```

Using `result = true` is the idiomatic, optimized way to write functions in Nim!

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your AI to check the radar ahead, shoot at distance, and walk forward when the path is clear.
3. Run `./discard check` in your terminal to compile and run the simulation!
