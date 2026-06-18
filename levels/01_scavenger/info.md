# LEVEL 1: SCAVENGER

### Lore
Excellent navigational work. Discard has moved deeper into the Bloat-Corp scrap facility. Ahead lies a dense junk corridor littered with valuable debris.

Our primary scans detect two valuable subsystem expansion cards (or **"dis-cards"**):
1. A **Backup Battery** (`B`)
2. A **rusty Laser Blaster** (`W`)

Discard's chassis is too wide to roll past these scrap piles directly. You are blocked from moving forward if an item lies in your path. You must deploy the active scavenger routines to **collect** them before you can pass.

---

### Objectives
- Sense adjacent spaces using `bot.feel(Direction)`.
- If an item is in front of you, use `bot.collect(Direction)`.
- Salvage both items and reach the airlock exit (`>`) within **30 cycles**.

---

### Unlocked Abilities & Sensors
- **Senses Subroutine**: You can now look one step ahead or behind:
  - `bot.feel(Direction)`: Returns a `Space` object.
  - *Default direction*: `Forward`
- **Collector Subroutine**: You can pick up adjacent items:
  - `bot.collect(Direction)`: Picks up the adjacent item.
  - *Default direction*: `Forward`

---

### Nim Syntax Manual: Immutability & Branching

#### Immutability Default: `let` vs `var`
In Nim, we prioritize immutability for safe, predictable code.
- **`let`**: Declares a read-only variable (immutable). Use `let` by default!
- **`var`**: Declares a mutable variable that can be changed.

Since the space we sense does not change after we read it, we **must** store it using `let`:
```nim
let space = bot.feel(Forward)
```

#### Conditionals (`if`/`else`)
In Nim, conditionals use `if`, `elif`, and `else`:
```nim
if space.isItem:
  bot.collect(Forward)
else:
  bot.walk(Forward)
```

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Enter your code to feel ahead, collect items when detected, and walk forward when clear.
3. Run `./discard check` in your terminal to compile and run the simulation!
