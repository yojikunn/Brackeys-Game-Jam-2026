extends Node
var gameStarted: bool
var playerBody: CharacterBody2D
var playerSwordDamage:int = 100

#Added Level
var playerMaxHP: int = 100
var playerHP: int = 100
var playerDead: bool
var playerCanMove: bool

var batBody: CharacterBody2D
var batDamage = 20

var skeletonDamage = 30
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
