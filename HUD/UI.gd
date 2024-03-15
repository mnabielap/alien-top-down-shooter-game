extends CanvasLayer

var max_hp: int = 100

onready var player: KinematicBody2D = get_parent().get_node("Player")
onready var health = get_node("Health")
onready var kills_counter = get_node("KillsCounter")

func _ready():
	max_hp = player.hp
	update_health(max_hp)

# function to update player´s life
func update_health(new_value: int):
	health.text = "Health: " + str(new_value)

# signal connected to player
func _on_Player_hp_changed(new_hp):
	update_health(new_hp)

