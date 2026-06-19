# LEVEL 9: FERRIS THE CRAB (BOSS)

### Lore
WARNING! **Ferris the Rust Crab** blocks the corridor — armoured, memory-safe, and stubborn. Ferris takes **4 HP** of laser fire before its pincers retract. Step adjacent and those pincers shred your chassis for 4 HP every turn.

Combine every subroutine you've salvaged so far: Radar to detect Ferris at range, Blaster to chip away its 4 HP one shot at a time, Rest module to recharge between volleys.

Vanquish Ferris and the route to the inner gauntlet opens.

---

### Objectives
- Combine all firmware subroutines (Radar, Blaster, Thrusters, Rest).
- Scan and fire at Ferris (`Slug`-typed tile) from long range.
- Drain all 4 HP and reach the inner exit (`>`) within **30 cycles**.

---

### Unlocked Abilities & Sensors
- **Deck Assembly**: All subroutines unlocked!
  - `bot.walk()`, `bot.feel()`, `bot.look()`, `bot.shoot()`, `bot.rest()`.

---

### Nim Syntax Manual: Full API Composition

You have full command of all bot procedures and state variables. Assemble them to form your master AI firmware deck!

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your firmware solution, combining radar scanning and ranged laser volleys.
3. Run `./discard check` in your terminal to compile and run the simulation!
4. Vanquish Ferris to unlock the final approach.
