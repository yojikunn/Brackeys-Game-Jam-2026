extends Node
var gameStarted: bool
var playerBody: CharacterBody2D
var fairyBody: CharacterBody2D
var Respawn_pos: Vector2
var On_stage_level: int
var Turn_right: bool
var Turn_left: bool
var First_Cutscene = false
var Path01_Cutscene = false
var Path02_Cutscene = false
var Bat_Cutscene = false
var Button_push = false
var Boots01_collect = false
var Boots02_collect = false
var Key_collect = false
var Fairy_IsAround = true
var Batkillcount = 0
var Ending = 0

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
var Current_dialogue: int = 0

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

func drain_exp(amount: int) -> void:
	experience -= amount
	while experience < 0 and level > 1:
		level -= 1
		experience += LEVEL_THRESHOLDS[level - 1]
	if experience < 0:
		experience = 0
	recalc_stats()
	experience_updated.emit(experience, level)

const BASE_SWORD_DAMAGE: float = 6.0
const BASE_MAX_HP: float = 100.0
func recalc_stats() -> void:
	playerSwordDamage = BASE_SWORD_DAMAGE + (level - 1) * DAMAGE_PER_LEVEL
	playerMaxHP = BASE_MAX_HP + (level - 1) * MAXHP_PER_LEVEL
	playerHP = min(playerHP, playerMaxHP)
	Global.playerBody.healthbar.init_health(Global.playerMaxHP)
	Global.playerBody.healthbar.HP = Global.playerMaxHP
