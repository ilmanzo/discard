# LEVEL 12: FINAL BOSS — CORE JAMMER

### Lore
The central airlock is sealed behind the **Master Smasher Core**: a four-layer wall of armoured hostiles (`S S S S`). Melee against that plating is suicide — you must shred each layer from range with the blaster, advancing only when the corridor ahead is clear.

The same "scan, then act" decision repeats every single turn. Copy-pasting it is how 3am bugs are born. This is the level for **templates**: a `template` is a compile-time AST substitution — the compiler replaces each call with the template's body inline, so you write the routine once and reuse it with zero call overhead, parameterised however you like (e.g. by direction).

---

### Objectives
- Define a `template` that captures your per-turn decision (scan → shoot / attack / walk), parameterised by `Direction`.
- Call it from `playTurn` to grind down all four shield layers.
- Reach the escape airlock (`>`) within **30 cycles**.

---

### Unlocked Abilities & Sensors
- **Overclocker Subroutine**: compile-time templates:
  - Define: `template name(args) = ...`
  - Each call is replaced inline with the body at compile time.

---

### Nim Syntax Manual: Templates & AST Substitution

A `template` is not a runtime function call — at compile time the compiler pastes its body in place of the call. Great for reusing a block of logic without indirection. The *pattern* (fill in the decision):
```nim
template engage(bot: var Bot, dir: Direction) =
  # this whole block is inlined wherever `bot.engage(dir)` appears
  if bot.look(3, dir) == Slug:
    bot.shoot(dir)
  else:
    bot.walk(dir)

proc playTurn*(bot: var Bot) =
  bot.engage(Forward)
```

> Note: the engine executes **one action per turn**, so a template can't fire four shots in a single turn — it captures a *reusable decision*, not a burst. You grind the boss down one inlined turn at a time. That's the honest power of templates: code reuse, not action duplication.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Capture your engage routine as a template and drive every turn through it.
3. Run `./discard check`. Clear the Final Boss to fully calibrate Discard and escape the scrap yards!
