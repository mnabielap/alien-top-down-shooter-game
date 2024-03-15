extends KinematicBody2D
class_name Entity # class


signal hp_changed(new_hp)       
signal hp_max_changed(new_hp_max) 
signal died 

export (int) var hp_max: int = 100 setget set_hp_max
export (int) var hp: int = hp_max setget set_hp, get_hp
export (int) var speed: int = 40                             # acceleration
export (int) var max_speed: int = 100                        # speed
export (bool) var is_knockback: bool = true
export (float) var knockback_modifier: float = 0.1

const FRICTION: float = 0.15

onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")
onready var coll_shape = $CollisionShape2D
onready var anim_player = $AnimationPlayer
onready var hurtbox = $Hurtbox

var move_direction: Vector2 = Vector2.ZERO  # movement vector
var velocity: Vector2 = Vector2.ZERO        # speed vector

func _physics_process(delta):
	velocity = move_and_slide(velocity)
	velocity = lerp(velocity, Vector2.ZERO, FRICTION) # interpolate speed
	move()
	
func move():
	move_direction = move_direction.normalized()  # normalize vector
	velocity += move_direction * speed 
	velocity = velocity.clamped(max_speed)        # clamp speed	

func die():
	if not anim_player.is_playing():
		queue_free()
	
func receive_damage(damage: int):
	self.hp -= damage

func _on_Hurtbox_area_entered(hitbox):
	if (str(hitbox.get_name()).begins_with("MineBomb")):
		receive_damage(20)
		# knockback_force(hitbox.global_position, hitbox.damage, knockback_modifier)
		var child_sprite = hitbox.get_node("AnimatedSprite")
		if child_sprite and child_sprite is AnimatedSprite:
			child_sprite.play("explode")
	elif !(str(hitbox.get_name()) == "HurtBox"):
		if self.hp > 0:
			# print("Hitbox_name: "+str(hitbox.get_name()))
			receive_damage(hitbox.damage)
		if hitbox.is_in_group("bullet"):
			hitbox.destroy()
		if self.hp > 0 and !hitbox.is_in_group("bullet"):
			knockback_force(hitbox.global_position, hitbox.damage, knockback_modifier)

func set_hp(value):
	if value != hp:
		hp = clamp(value, 0, hp_max) # clamp health
		emit_signal("hp_changed", hp)
		if hp == 0:
			coll_shape.set_deferred("disabled", true)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			emit_signal("died")

func get_hp():
	return hp
	
func set_hp_max(value):
	if value != hp_max:
		hp_max = max(0, value)

func _on_Entity_died():
	die()

func knockback_force(damage_pos: Vector2, damage: int, knockback_modifier_new: int):
	if is_knockback:
		var knockback_direction = damage_pos.direction_to(self.global_position)  # direction
		var knockback_strength = damage * knockback_modifier_new                 # strenght
		var knockback = knockback_direction * knockback_strength                 # vector
		
		global_position += knockback # new position
	
