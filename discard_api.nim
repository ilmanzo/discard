# discard_api.nim
# Public API imported by the player's `player.nim`.

import core/types
export types

# Senses
func feel*(bot: Bot, dir: Direction = Forward): TileKind =
  ## Senses the space in the specified direction. Returns TileKind directly.
  return bot.nearTiles[dir]

func look*(bot: Bot, dist: int, dir: Direction = Forward): TileKind =
  ## Looks up to 3 tiles away in the specified direction. dist must be 1..3.
  if dist < 1 or dist > 3:
    raise newException(ValueError, "look: dist must be 1..3, got " & $dist)
  return bot.radarTiles[dir][dist - 1]

func currentScrap*(bot: Bot): Scrap =
  ## Returns the scrap payload currently loaded for inspection (Level 11).
  return bot.currentScrap

# Actions
proc registerAction(bot: var Bot, kind: ActionKind, dir: Direction = Forward) =
  if bot.hasActed:
    return # Ignore subsequent actions in a single turn
  bot.action = kind
  bot.actionDir = dir
  bot.hasActed = true

proc walk*(bot: var Bot, dir: Direction = Forward) =
  ## Commands the bot to walk one step in the specified direction.
  bot.registerAction(ActWalk, dir)

proc collect*(bot: var Bot, dir: Direction = Forward) =
  ## Command the bot to collect an item (battery or blaster) from the adjacent tile.
  bot.registerAction(ActCollect, dir)

proc attack*(bot: var Bot, dir: Direction = Forward) =
  ## Commands the bot to melee-attack in the specified direction.
  bot.registerAction(ActAttack, dir)

proc rest*(bot: var Bot) =
  ## Commands the bot to rest and recharge its battery for a turn.
  bot.registerAction(ActRest)

proc rescue*(bot: var Bot, dir: Direction = Forward) =
  ## Commands the bot to repair/rescue a deactivated buddy bot.
  bot.registerAction(ActRescue, dir)

proc shoot*(bot: var Bot, dir: Direction = Forward) =
  ## Commands the bot to fire its Blaster up to 3 tiles away in a direction.
  bot.registerAction(ActShoot, dir)
