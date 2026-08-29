extends Node
var gameStarted: bool
var playerBody: CharacterBody2D
var Respawn_pos: Vector2
var On_stage_level: int
var Turn_right: bool
var Turn_left: bool
var Current_dialogue: int

#Added Level
var playerMaxHP: float = 100
var playerHP: float = 100
var playerDead: bool
var playerCanMove: bool
var playerSwordDamage:float = 6
var playerMaxJump = 1
var playerHeal = 2
var level_is_up = false
var playerMaxDash = 0

var batBody: CharacterBody2D
var batDamage = 20

var skeletonDamage = 30

var goldskeletonDamage = 50

var spikeDamage = 15
#Added Level
var level: int = 1
var experience: int = 0
const MAX_LEVEL: int = 5
const LEVEL_THRESHOLDS: Array[int] = [
	20, #level 2
	30, #level 3
	50, #level 4
	100, #level 5
]
const DAMAGE_PER_LEVEL: int = 2
const MAXHP_PER_LEVEL: int = 30

signal experience_updated(current_exp: int, level: int)
