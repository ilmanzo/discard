# LEVEL 7: MEMORY MATRIX

### Lore
The corridor floor is a **plasma vent matrix**. The vents discharge on a strict rhythm: they are **SAFE on odd cycles** and **VENTING on even cycles**. Move while a vent is firing and Discard is incinerated instantly (0 HP).

Standing still (resting) is always safe. So the crossing is a timing puzzle: **walk only on safe cycles, rest through the venting ones.**

The catch — Discard has no clock. To know which cycle it is, you must *count the cycles yourself*. Top-level variables in `player.nim` persist between turns, so a growing `seq` is your memory: append one entry per turn, and its length tells you the current cycle.

---

### Objectives
- Keep a persistent `var history: seq[int] = @[]` and append to it every turn.
- Walk forward only on **odd** cycles; `rest()` on **even** (venting) cycles.
- Reach the exit airlock (`>`) within **20 cycles** without being caught mid-stride.

---

### Unlocked Abilities & Sensors
- **RAM Module**: persistent dynamic sequences (`seq`):
  - Create: `var history: seq[int] = @[]`
  - Append: `history.add(1)`
  - Length: `history.len`

---

### Nim Syntax Manual: Sequences (`seq`) and Persistent Globals

A variable declared at the top level of `player.nim` keeps its value across every turn tick — that is your memory between calls. Pair it with the modulo operator `mod` to read a rhythm.

The *pattern* (not the answer — wire up the timing yourself):
```nim
var ticks: seq[int] = @[]      # persists across turns

proc playTurn*(bot: var Bot) =
  ticks.add(1)                 # one entry per cycle
  if ticks.len mod 2 == 0:
    discard                    # even cycle -> decide what is safe here
  else:
    discard                    # odd cycle  -> ...
```

Read the on-screen **PLASMA FIELD** banner while debugging: it shows SAFE/VENTING each cycle so you can confirm your counter is in phase.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Track cycles with a persistent `seq`, then walk on safe cycles and rest on venting ones.
3. Run `./discard check` to compile and run the simulation. Run `./discard check --step` to advance one cycle at a time.
