# LEVEL 6: AMBUSH

### Lore
Double Warning! Multiple territorial Space-Slugs have detected your core heat signatures. They are closing in on Discard from **both sides** (front and back) inside this narrow repair shaft.

To survive, you must deploy your sensors in both directions! Your **Rear Sensor Card** allows you to perform scans (`bot.feel(Backward)` and `bot.look(dist, Backward)`) and fire backward (`bot.shoot(Backward)` / `bot.attack(Backward)`).

Watch your back and clear both sides of the corridor to secure your path to the airlock!

---

### Objectives
- Scan and attack enemies in both directions: `Forward` and `Backward`.
- Eliminate all surrounding hostile slugs.
- Reach the exit airlock (`>`) within **30 cycles** with your battery intact.

---

### Unlocked Abilities & Sensors
- **Rear Sensors & Actuators**: You can now sense and act in both directions:
  - `bot.feel(Backward)`: Check immediate adjacent tile behind you.
  - `bot.look(dist, Backward)`: Scan up to 3 tiles behind you.
  - `bot.attack(Backward)`: Melee attack behind you.
  - `bot.shoot(Backward)`: Fire laser blaster behind you.

---

### Nim Syntax Manual: Iterating Directions (Bonus Concept)

You can check directions individually, or write exhaustive sequential logic:
```nim
if bot.feel(Forward).isEnemy:
  bot.attack(Forward)
elif bot.feel(Backward).isEnemy:
  bot.attack(Backward)
```

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your AI to defend from both sides, then roll forward when clear.
3. Run `./discard check` in your terminal to compile and run the simulation!
