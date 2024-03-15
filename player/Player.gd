extends Entity

 # smooth movement of camera
const SMOOTH := 0.1
var is_alive : bool = true

export (PackedScene) var bullet: PackedScene = preload("res://bullet/PlayerBullet.tscn")

onready var muzzle = $Weapon/Muzzle
onready var weapon = $Weapon
onready var sight = $Weapon/Sight
onready var flash = $Weapon/Flash
onready var fire_rate = $FireRate


func _process(delta: float):
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if is_alive:
		# Animations
		if mouse_direction.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
		elif mouse_direction.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true
		
		# player is moving
		if move_direction != Vector2.ZERO:
			anim_player.play("run")
		else:
			# player is idle
			anim_player.play("idle") 
			$Shadow.global_position.x = global_position.x
			
		# Shadow position
		if animated_sprite.flip_h and move_direction != Vector2.ZERO:
			$Shadow.global_position.x = global_position.x + 1
		if not animated_sprite.flip_h and move_direction != Vector2.ZERO:
			$Shadow.global_position.x = global_position.x - 1
		
		
		# Shoot
		if Input.is_action_pressed("ui_fire") and fire_rate.is_stopped():
			$SFXShoot.play()
			shoot()
	
		# Weapon rotation
		weapon.look_at(get_global_mouse_position())
		if get_global_mouse_position().x < position.x:
			weapon.flip_v = true
		else:
			weapon.flip_v = false	
			
		handle_camera()
		get_input()

func get_input():
	if is_alive:
		move_direction = Vector2.ZERO
		if Input.is_action_pressed("ui_down"):
			move_direction += Vector2.DOWN
		if Input.is_action_pressed("ui_up"):
			move_direction += Vector2.UP
		if Input.is_action_pressed("ui_left"):
			move_direction += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			move_direction += Vector2.RIGHT

func handle_camera():
	var new_camera_position = global_position + (get_global_mouse_position() - global_position) * SMOOTH
	$Camera.global_position = new_camera_position

func shoot():
	if bullet:
		anim_player.play("flash")
		var bullet_instance = bullet.instance()
		get_tree().current_scene.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation_degrees = weapon.rotation_degrees
		fire_rate.start()
		
		
func heal(value):
	$SFXHeal.play()
	hp += value
	hp = clamp(hp, 0, hp_max)
	emit_signal("hp_changed", hp * 100/hp_max)

func _on_Player_died():
	hp = 0
	$SFXDied.play()
	anim_player.play("death")
	move_direction = Vector2.ZERO
	weapon.visible = false
	$Shadow.visible = false
	coll_shape.disabled = true
	$Hurtbox/CollisionShape2D.disabled = true
	is_alive = false


func _on_Player_hp_changed(new_hp):
	if hp > 0:
		$SFXScream.play()

func _on_FireRate_timeout():
	flash.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	pass
