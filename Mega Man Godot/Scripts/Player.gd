extends CharacterBody2D

@onready var collision_shape_stand: CollisionShape2D = $CollisionShape_Stand
@onready var collision_shape_slide: CollisionShape2D = $CollisionShape_Slide

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var ladder_raycast: RayCast2D = $Ladder_raycast
@onready var slide_raycast: RayCast2D = $Slide_Raycast

@onready var can_shot_timer: Timer = $Can_Shot_Timer
@onready var can_dash_timer: Timer = $Can_Dash_Timer
@onready var ghost_timer: Timer = $Ghost_Timer

@onready var Muzzle = $Marker2D


var bullet = preload("res://Mega Man Godot/Scenes/Player/bullet.tscn")

var speed = 50
var dash_speed = 150
var cilm_speed = -60
var jumpforce = -400
var gravity = 20

var can_shoot = false
var can_dash = false
var can_climb = false
var can_jump = true
var can_move = true

var jump_anim_played := false
var dash_anim_played := false


var climb_ready = false

var turn_left = false
var turn_right = false

var finish_climb =  false
var climb_pos_x : float
var ladder_snap_weight = 50

var timer_shoot = 1.0 
var timer_dash = 0.3

@export var ghost_node : PackedScene

var current_anim := ""

func _ready() -> void:
	Muzzle.position.y = 3.0


func _physics_process(delta):
	if climb_ready:
		_climbing(delta)
	else:
		_move(delta)
	_shooting()
	_update_animation()
	_turn()
	_dash()


	if _climb() and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		climb_ready = true

	if is_on_floor() and Input.is_action_just_pressed("down"):
		SignalisBus.oneway_disabled.emit()
	move_and_slide()


func _move(delta):
	var horizontal_direction = Input.get_axis("left", "right")

	if can_dash == false:
		if can_move == true:
			velocity.x = speed * horizontal_direction
	elif turn_right:
		velocity.x = dash_speed
	else:
		velocity.x = -dash_speed 


	if !is_on_floor():
		velocity.y += gravity
		can_dash = false

	if Input.is_action_just_pressed("jump") && is_on_floor():
		if can_jump == true:
			velocity.y = jumpforce
			jump_anim_played = false 
	

	if Input.is_action_pressed("shoot") and can_shot_timer.is_stopped():
		can_shoot = true
		can_dash = false
		can_shot_timer.start(0.2)
		_shoot()
				
func _on_can_shot_timer_timeout() -> void:
	can_shoot = false
	can_shot_timer.stop()


func _turn():
	if Input.is_action_pressed("left"):
		turn_left = true
		turn_right = false
	if Input.is_action_pressed("right"):
		turn_right = true
		turn_left = false
	
	if turn_left == true:
		animated_sprite_2d.flip_h = false
	elif turn_right == true:
		animated_sprite_2d.flip_h = true
	
func _shooting():
	if Input.is_action_pressed("shoot") and can_shot_timer.is_stopped():
		can_shoot = true
		can_dash = false
		can_shot_timer.start(0.2)
		_shoot()

func _dash():
	if Input.is_action_just_pressed("dash"):
		can_dash = true
		can_shoot = false
		can_dash_timer.start(timer_dash)
	
	if can_dash:
		collision_shape_stand.disabled = true
		collision_shape_slide.disabled = false
	elif !slide_raycast.is_colliding():
		collision_shape_stand.disabled = false
		collision_shape_slide.disabled = true



func _on_can_dash_timer_timeout() -> void:
	can_dash = false

func _shoot():
	var bullet_instantiate = bullet.instantiate()
	var direction = -1 if not animated_sprite_2d.flip_h else 1 
	bullet_instantiate.global_position = Muzzle.global_position
	bullet_instantiate.direction = direction 
	get_parent().add_child(bullet_instantiate)

	if turn_left == true:
		Muzzle.position.x = -21.0
	elif turn_right == true:
		Muzzle.position.x = 21.0
	
	if not is_on_floor():
		Muzzle.position.y = -3.0
	else:
		Muzzle.position.y = 3.0
	

func _climb() -> bool:
	if not ladder_raycast.is_colliding():
		return false
	climb_pos_x = ladder_raycast.get_collider().global_position.x

	return true

func _climbing(delta):
	global_position.x = lerp(global_position.x, climb_pos_x, ladder_snap_weight * delta)
	var vertical_direction = Input.get_axis("down", "up")
	
	velocity.x = 0 

	if vertical_direction:
		velocity.y = vertical_direction * cilm_speed
	else:
		velocity.y = 0 
	
	if can_shoot == true:
		velocity.y = 0 

	if Input.is_action_just_pressed("jump"):
		velocity.y = jumpforce
		climb_ready = false

	if not _climb() or is_on_floor():
		climb_ready = false
	

func _update_animation():

	if can_dash:
		animation_player.play("Dash")
		return

	if climb_ready:
		if Input.is_action_just_pressed("jump"):
			animation_player.play("Jump")
		elif can_shoot:
			animation_player.play("Climb_Shoot")
		else:
			animation_player.play("Climb")
		
		if velocity.y == 0 and !can_shoot:
			animation_player.play("climb_stop")
		
		if finish_climb == true:
			animation_player.play("Climb_End")
		return

	if not is_on_floor():
		if can_shoot:
			animation_player.play("Jump_Shot_2")
		else:
			if not jump_anim_played:
				animation_player.play("Jump")
				jump_anim_played = true
		return
	else:
		jump_anim_played = false

	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		if can_shoot:
			animation_player.play("Run_Shoot")
		else:
			animation_player.play("Run")
	else:
		if can_shoot:
			animation_player.play("Shoot")
		else:
			animation_player.play("Idle")
	
	if slide_raycast.is_colliding():
		if not dash_anim_played:
			animation_player.play("Dash")
			dash_anim_played = true
	return



func play_anim(name: String):
	if current_anim == name:
		return
	current_anim = name
	animation_player.play(name)
	





	
