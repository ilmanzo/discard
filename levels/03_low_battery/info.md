# LEVEL 3: LOW BATTERY

### Lore
Our metrics show extreme heat and high-damage friction on Sector Delta-9. Discard is leaking energy and is deployed with a low battery state (8% health)!

To clear this corridor, you must study your **Rest Module Card** unlocked from Level 2. When Discard is severely depleted (under 10 HP), command it to **rest** and defragment its energy cells to restore **5 HP** per turn. 

If a hostile Space-Slug is adjacent, it bites for **4 HP** at the end of the turn. So be sure you only rest when safe, or recharge enough HP to survive a hit!

---

### Objectives
- Sense your battery level using `bot.health`.
- If health is critical (e.g. `<= 10`), call `bot.rest()`.
- Eliminate the Space-Slug and collect the battery to reach the exit airlock (`>`) within **25 cycles**.

---

### Unlocked Abilities & Sensors
- **Rest Module**: Recharge depleted battery cells:
  - `bot.rest()`: Restores 5 HP.
- **Battery Sensor**: Check current health:
  - `bot.health`: Returns an integer (0 to 20).

---

### Nim Syntax Manual: Operators & Comparators

To check variable or sensor thresholds, use standard comparison operators:
- `<` (less than)
- `<=` (less than or equal to)
- `>` (greater than)
- `>=` (greater than or equal to)
- `==` (equal to)

Example check:
```nim
if bot.health <= 10:
  bot.rest()
```

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your AI to rest if HP is low, attack if a slug is adjacent, collect the battery, and walk forward when clear.
3. Run `./discard check` in your terminal to compile and run the simulation!
