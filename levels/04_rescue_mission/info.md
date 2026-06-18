# LEVEL 4: RESCUE MISSION

### Lore
Discard has encountered a scrapyard salvage sector littered with defunct Bloat-Corp buddy bots. These bots are deactivated and block your forward path.

You cannot leave them behind! To proceed, you must use your newly salvaged **Grabber Arm Card**. When you detect a buddy bot (`C`) right in front of you, execute `bot.rescue(Forward)` to repair and reboot its firmware. 

The exit airlock will remain locked if any buddy bot is left behind!

---

### Objectives
- Guide Discard forward.
- Senses adjacent spaces. If a buddy bot (`C`) is detected, repair it.
- Salvage all buddy bots and reach the exit airlock (`>`) within **20 cycles**.

---

### Unlocked Abilities & Sensors
- **Grabber Arm**: Repair and reboot deactivated friendly units:
  - `bot.rescue(Direction)`: Repairs adjacent buddy bot.
  - *Default direction*: `Forward`
- **Friend Sensor**: Helper queries for buddy bots:
  - `space.isCrew`: `true` if adjacent unit is a repairable buddy bot.

---

### Nim Syntax Manual: UFCS (Uniform Function Call Syntax)

Nim has a beautiful feature called **UFCS**. It means a procedure call `f(a, b)` can be written as `a.f(b)`.

This allows us to chain queries seamlessly! For example:
- Functional / Lisp style: `isCrew(feel(bot, Forward))`
- Object-oriented / UFCS: `bot.feel(Forward).isCrew`

By default, we write `let space = bot.feel(Forward)` and then check `space.isCrew`. But with UFCS, we can write it in a single clean line:
```nim
if bot.feel(Forward).isCrew:
  bot.rescue(Forward)
```

---

### How to Play
1. Edit `player.nim` at the root of the project.
2. Code your bot's loop to rescue buddy bots and navigate to the airlock exit.
3. Run `./discard check` in your terminal to compile and run the simulation!
