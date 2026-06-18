# LEVEL 11: SCRAP SORTING

### Lore
Discard is bolted to a sorting belt. **Each turn a new scrap item rides up** for inspection, and you make one call:

- **Keep it** — `walk(Forward)`. A good item rolls into the drive and carries Discard one step toward the exit.
- **Reject it** — `rest()`. The item is discarded off the belt; Discard stays put.

Force a *reject* into the drive (walk when you should have discarded) and the whole line **jams — instant fail**. Discard the whole belt without ever keeping a good one and you run out of time. You have to classify every item correctly.

Scrap comes in three shapes, and Nim models that with an **object variant**: one type whose valid fields depend on a `kind` discriminator. Read the wrong field for the wrong kind and the compiler/ runtime stops you — that safety is the whole point.

---

### Objectives
- Read `bot.currentScrap()` each turn and `case` on its `kind`.
- Keep (walk) when the item passes its threshold, reject (rest) otherwise:
  - `skGear` → `teeth > 10`
  - `skWire` → `length > 5.0`
  - `skCore` → `energy > 100`
- Sort the whole belt and reach the exit (`>`) within **20 cycles**.

---

### Unlocked Abilities & Sensors
- **Analyzer Subroutine**: inspect variant objects:
  - `bot.currentScrap()` returns the `Scrap` riding the belt this turn.
  - Kinds: `skGear`, `skWire`, `skCore`.

---

### Nim Syntax Manual: Object Variants

A variant's `kind` decides which fields are legal — a `case` is how you unpack it safely. The *pattern* (fill in the other two arms yourself):
```nim
let scrap = bot.currentScrap()
case scrap.kind:
of skGear:
  if scrap.teeth > 10: bot.walk(Forward) else: bot.rest()
of skWire:
  discard   # length field is valid here
of skCore:
  discard   # energy field is valid here
```
Reading `scrap.energy` inside the `skGear` arm is a runtime error — the variant only lets you touch the fields that belong to the current kind.

Watch the **ON BELT** line above the corridor: it shows the item Discard is holding each turn so you can confirm your classification.

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. `case` on the scrap kind, keep good items (walk), reject bad ones (rest).
3. Run `./discard check` (use `./discard check --step` to inspect each belt item one at a time).
