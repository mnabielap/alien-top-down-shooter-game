extends Entity

var can_shoot: bool = true
var target = null
#red color
var laser_color = Color(1.0, .329, .298) 

onready var parent = get_parent()
onready var muzzle = $Weapon/Muzzle
onready var weapon = $Weapon
onready var sight = $Weapon/Sight
onready var ray_cast = $RayCast2D
onready var reload_timer = $RayCast2D/ReloadTimer

export (PackedScene) var alien_bullet: PackedScene = preload("res://bullet/AlienBullet.tscn")
export (float) var weapon_speed
# simple finite state machine
export (String, "aim", "patrol") var patrol_type = "patrol" 


func _on_AlienDude_hp_changed(new_hp):
	pass

func _on_AlienDude_died():
	speed = 0
	weapon.visible = false
	anim_player.play("death")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		Globals.enemy_killed()
		queue_free()

func _physics_process(delta):
	# to draw
	update() 
	
	# if the state is "patrol", the enemy moves following a path
	if patrol_type == "patrol" and self.hp > 0:
		if parent is PathFollow2D:
			parent.set_offset(parent.get_offset() + speed * delta)
			anim_player.play("run")
			position = Vector2()
	
func _process(delta):
	if target and self.hp > 0:
		# rotation of raycast
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		ray_cast.global_rotation = angle_to_target
		
		# moving the weapon towards the target
		if target.name == "Player":
			var target_dir = (target.global_position - global_position).normalized()
			var current_dir = Vector2(1,0).rotated($Weapon.global_rotation)
			$Weapon.global_rotation = current_dir.linear_interpolate(target_dir, weapon_speed * delta).angle()
		
			# look at the target
			if target.global_position.x < global_position.x:
				weapon.flip_v = true
				animated_sprite.flip_h = true
			else:
				weapon.flip_v = false
				animated_sprite.flip_h = false
			
		# detect a collision with player
		# change state to "aim", the enemy stops moving
		# shoot
		if ray_cast.is_colliding(): 
			var collision = ray_cast.get_collider()
			if collision.name == "Player":
				patrol_type = "aim"
				anim_player.play("idle")
				if can_shoot:
					shoot()
			else:
				patrol_type = "patrol"

func shoot():
	if alien_bullet:
		var alien_bullet_instance = alien_bullet.instance()
		get_tree().current_scene.add_child(alien_bullet_instance)
		alien_bullet_instance.global_position = muzzle.global_position
		alien_bullet_instance.rotation_degrees = weapon.rotation_degrees
		can_shoot = false
	reload_timer.start()

func _on_DetectRadius_body_entered(body):
	if body.name == "Player":
		target = body

func _on_DetectRadius_body_exited(body):
	if body == target:
		target = null

func _on_ReloadTimer_timeout():
	can_shoot = true

func _draw():
	if target != null and self.hp > 0:
		pass
