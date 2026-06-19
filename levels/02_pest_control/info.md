# LEVEL 2: PEST CONTROL

### Lore
Alert! Scans of Sector Beta-4 show a hostile infestation. A giant, acidic **Space-Slug** (`S`) is guarding the corridor ahead. 

Space-Slugs are incredibly territorial. If you step adjacent to one, it will immediately bite your chassis, leaking highly corrosive fluid that drains your battery by **4 HP** each turn!

Fortunately, you have your **Laser Blaster** salvaged from Level 1. When you detect a Slug right in front of you, execute an **attack** routine to crush it with laser-guided impact force.

---

### Objectives
- Guide Discard forward.
- Sense adjacent tiles. If you detect a Slug, use `bot.attack(Forward)` to eliminate it.
- Reach the exit airlock (`>`) within **20 cycles** with your battery intact.

---

### Unlocked Abilities & Sensors
- **Combat License**: You can now make melee attacks with your Laser Blaster:
  - `bot.attack(Direction)`: Deals fatal impact damage to hostiles in the target direction.
  - *Default direction*: `Forward`

---

### Nim Syntax Manual: The `case` Statement

For multi-way branching, Nim's `case` statement is clean and powerful. It forces you to cover all possible branch matches, or use `else` for default cases.

```nim
let space = bot.feel(Forward)

case space.kind:
of Slug:
  bot.attack(Forward)
of Empty:
  bot.walk(Forward)
else:
  # Fallback for Exit or Wall
  bot.walk(Forward)
```

In the `case` block:
- `of Slug:` is triggered if the space contains an enemy slug.
- `of Empty:` is triggered if the path is clear.
- `else:` captures all other tiles (such as `Wall` or `Exit`).

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your bot's decision loop using a `case` statement to sense and eliminate slugs.
3. Run `./discard check` in your terminal to compile and run the simulation!
