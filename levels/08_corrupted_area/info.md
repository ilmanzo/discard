# LEVEL 8: CORRUPTED AREA

### Lore
Same lethal plasma vents as the Memory Matrix — **SAFE on odd cycles, VENTING on even cycles** — but this sector has scrambled your sequence memory. You can no longer lean on a `seq` counter.

Instead, model the rhythm as an explicit **Finite State Machine (FSM)**: a custom `enum` of states plus a persistent state variable that *flips itself* every turn. The bot doesn't count cycles; it just knows "I moved last turn, so this turn I wait," and toggles.

Cycle 1 is safe, so the machine must **start in the moving state**.

---

### Objectives
- Define a custom `enum` (e.g. `BotState = enum StateWalk, StateWait`).
- Hold the current state in a persistent global and transition it on every turn.
- Walk on safe cycles, rest on venting cycles, and reach the exit (`>`) within **20 cycles**.

---

### Unlocked Abilities & Sensors
- **State Processor**: custom enums + persistent state:
  - Define: `type BotState = enum StateWalk, StateWait`
  - Route behavior with a `case` statement on the current state.

---

### Nim Syntax Manual: Custom Enums + `case`

An `enum` names a fixed set of states; a `case` routes behavior per state. The *pattern* (fill in the transitions yourself):
```nim
type BotState = enum
  StateWalk
  StateWait

var state = StateWalk          # persists across turns

proc playTurn*(bot: var Bot) =
  case state:
  of StateWalk:
    # ... act, then flip the state
    state = StateWait
  of StateWait:
    # ... act, then flip back
    state = StateWalk
```

An FSM and the `seq` counter from Level 7 solve the *same* timing puzzle two different ways — that's the lesson: pick the model that reads cleanest.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Build a two-state FSM that toggles every turn, starting in the moving state.
3. Run `./discard check` (or `./discard check --step` to watch the SAFE/VENTING banner cycle).
