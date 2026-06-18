# core/types.nim
# Core types shared between the simulation engine and the player API.

type
  Direction* = enum
    Forward
    Backward

  TileKind* = enum
    Empty
    Wall
    Exit
    Battery
    Weapon
    Slug
    Crew
    Mine

  ActionKind* = enum
    ActNone
    ActWalk
    ActCollect
    ActAttack
    ActRest
    ActRescue
    ActShoot

  Equipment* = enum
    EqBattery, EqBlaster, EqRestModule

type
  ScrapKind* = enum
    skGear
    skWire
    skCore

  Scrap* = object
    case kind*: ScrapKind
    of skGear:
      teeth*: int
    of skWire:
      length*: float
    of skCore:
      energy*: int

  Bot* = object
    health*: int
    maxHealth*: int
    position*: int
    hasActed*: bool
    action*: ActionKind
    actionDir*: Direction
    nearTiles*: array[Direction, TileKind]
    radarTiles*: array[Direction, array[3, TileKind]]
    currentScrap*: Scrap
    equipment*: set[Equipment]

# Senses helper procs — accept TileKind directly (feel returns TileKind)
func isItem*(s: TileKind): bool = s in {Battery, Weapon}
func isEnemy*(s: TileKind): bool = s == Slug
func isCrew*(s: TileKind): bool = s == Crew
