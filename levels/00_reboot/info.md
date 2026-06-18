# LEVEL 0: REBOOT

### Lore
Discard has been offline for 40 operating cycles in the scrap heap of derelict sector Zeta-9. Liquid nitrogen is leaking from the bulkheads, and the chassis is covered in thick, orange **Rust**. 

Energy cells are extremely low (20% power), but the core thruster wheels are still intact. You must upload a basic navigational instruction to start moving toward the local escape airlock.

---

### Objectives
- Guide Discard to the exit portal (`>`) within **15 cycles**.

---

### Unlocked Abilities & Sensors
- **Thruster Wheels**: Unlocks `bot.walk(Direction)`
  - *Default direction*: `Forward`

---

### Nim Syntax Manual: Procedures & Calls
In Nim, you call a procedure (function) using dot notation or normal function notation:
```nim
# Calling 'walk' with default direction:
bot.walk()

# Or specify a direction explicitly:
bot.walk(Forward)
```

To complete this level, you must implement the `playTurn` procedure. It takes a mutable `Bot` object (indicated by `var`):
```nim
import discard_api

proc playTurn*(bot: var Bot) =
  # Your instruction goes here:
  bot.walk()
```
The `*` after `playTurn` is an **export marker**. It makes the procedure visible to the outer game engine.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Enter your code to command the bot to walk forward.
3. Run `./discard check` in your terminal to compile and run the simulation!
