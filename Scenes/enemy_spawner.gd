extends Node2D
class_name Spawner

enum Monsters { BAT, GHOST }
enum AttemptModes { PER_FRAME, ## Each spawn attempt will be conducted per frame.
					PER_SECOND ## Each spawn attempt will be conducted per second.
					}

@export var monster : Monsters
@export var base_spawn_chance_denominator : int ## The chances of this mob spawning are equal to 1 divided by this number.
@export var spawn_attempt_mode : AttemptModes = AttemptModes.PER_SECOND ## The method by which each spawn attempt, using the aforementioned spawn chance denominator, will be performed in time.

@export_category("Drops Behaviour")
@export var can_drop_coins : bool
@export var can_drop_heals : bool
@export var can_drop_powerups : bool
@export var can_drop_weapons : bool
@export var can_drop_loot : bool

@export_category("Spawning Behaviour")
@export var use_detection_range : bool
@export_range(0.0, 1000.0) var detection_range : float ## The radius of the range of detection, in pixels. This detection area can be used for different things, like progressively reducing spawn rates as more mobs spawn, by detecting the number of mobs inside this area.
@export_range(0.0, 1.0) var spawn_rate_dropoff : float ## The amount of dropoff in the spawn rate per existing mob inside the detection range.
