extends Node2D
class_name Spawner

enum Monsters { TEST }
enum Dependence { DEPENDENT, INDEPENDENT }

@export var mob_type : Monsters
@export var starting_spawn_chance : float ## The spawn chance of the first spawn attempt.
@export var event_dependency : Dependence ## Whether or not the rolls cascade off one another. If the events are dependent, a spawn fail will mean the next spawns won't be rolled. If they are independent, then all rolls will be rolled at once.
@export var spawn_chance_dropoff : float ## The amount the spawn chance drops by after each successive successful spawn attempt. For instance, if set at 0.20, the spawn after the initial one will be 20% less likely. The one after that will be 40% less likely than the initial spawn chance, and so on, until it reaches 0, or the spawn pool of enemies has been depleted.
@export var spawn_pool_size : int ## The total number of spawn attempts.
