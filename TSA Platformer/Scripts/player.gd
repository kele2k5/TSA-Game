extends CharacterBody2D

@export var movement_data : PlayerMovementData

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var handling_dash = false

@onready var dashing_timer = $DashingTimer
@onready var coyote_timer = $CoyoteTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var starting_position = global_position
@onready var dash_detector = $DashDetector

func _physics_process(delta):
	if not coyote_timer.time_left > 0:
		apply_gravity(delta)
	handle_jump()
	handle_wall_jump()
	handle_dash()
	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animation(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()
	print(dashing_timer.time_left)
	print(handling_dash)


func handle_jump():
	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

func handle_wall_jump():
	if not is_on_wall() or is_on_floor(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("jump") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.speed * 1.25
		velocity.y = movement_data.jump_velocity
	if Input.is_action_just_pressed("jump") and wall_normal == Vector2.RIGHT :
		velocity.x = wall_normal.x * movement_data.speed  * 1.25
		velocity.y = movement_data.jump_velocity
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0: 
		animated_sprite_2d.flip_h = true

func handle_dash():
	if dash_detector.get_overlapping_areas().size() >= 1:
		if(Input.is_action_pressed("dash")):
			handling_dash = true
			velocity.y = 0
			velocity.x = 0
		if(Input.is_action_just_released("dash")):
			var direction = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			)
			velocity.y = direction.y * movement_data.dash_speed - 80
			velocity.x = direction.x * movement_data.dash_speed
			dashing_timer.start()
			await dashing_timer.is_stopped()
			handling_dash = false

func handle_acceleration(input_axis, delta):
	if handling_dash: return
	if not is_on_floor(): return
	if(input_axis != 0):
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if handling_dash: return
	if is_on_floor(): return
	if(input_axis != 0):
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_gravity(delta):
	if handling_dash: return
	if is_on_wall_only(): 
		if Input.is_action_pressed("move_left") and get_wall_normal() == Vector2.RIGHT and velocity.y >= 0:
			movement_data.gravity_scale = 0.05
		elif Input.is_action_pressed("move_right") and get_wall_normal() == Vector2.LEFT and velocity.y >= 0:
			movement_data.gravity_scale = 0.05
	else:
		movement_data.gravity_scale = 1
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func apply_friction(input_axis, delta):
	if handling_dash: return
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if handling_dash: return
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animation(input_axis):
	if handling_dash: return
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("RUN")
	else:
		animated_sprite_2d.play("IDLE")
	
	if not is_on_floor():
		animated_sprite_2d.play("JUMP")

func _on_hazard_detector_area_entered(area):
	global_position = starting_position

