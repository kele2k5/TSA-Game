extends CharacterBody2D

@export var dashObject = PackedScene.new()

@export var gravity = 520
@export var acceleration = 1800
@export var deacceleration = 500
@export var friction = 2000
@export var currentFriction = 2000
@export var maxHoriSpeed = 120
@export var maxFallSpeed = 1000
@export var jumpHeight = -300

@export var squashSpeed = 0.1

@export var wallJumpHeight = -100
@export var wallJumpPush = 200

@export var maxWallSlideFallSpeed = 80
@export var wallSlideGravity = 80

@export var dashSpeed = 400
@export var dashLength = 0.2

var vSpeed = 0
var hSpeed = 0


var touchingGround : bool = false
var touchingWall : bool = false
var isJumping : bool = false
var airJumpPressed: bool = false
var coyoteTime : bool = false
var isWallSliding : bool = false
var UP :Vector2 = Vector2(0,-1)

var isDashing : bool = false
var canDash : bool = false
var dashDirection : Vector2

@onready var ani = $AnimatedSprite2D
@onready var groundRay = $rayCastContainer/rayGround
@onready var rightRay = $rayCastContainer/rayRight
@onready var leftRay = $rayCastContainer/rayLeft
@onready var dashTimer = $dashTimer

func _ready():
	if(Input.is_action_just_pressed("dash")):
		print("bruh")
	dashTimer.timeout.connect(dashTimerTimeout)
	pass
	
func dashTimerTimeout():
	isDashing = false
	
func get_direction_from_input():
	var moveDir = Vector2()
	moveDir.x = -Input.get_action_strength("moveLeft") + Input.get_action_strength("moveRight")
	moveDir.y = Input.get_action_strength("moveDown") - Input.get_action_strength("moveUp")
		
	moveDir = moveDir.limit_length(1)
	
	#check if no movement is pressed further enough... then dash towards ur facing position
	if (moveDir == Vector2(0,0)):
		if(ani.flip_h):
			moveDir.x = -1
		else:
			moveDir.x = 1
			
	return moveDir * dashSpeed
	
func _physics_process(delta):
	checkGroundAndWallLogic()
	handleDash(delta)
	handleInput(delta)
	doPhysics(delta)
	pass

func checkGroundAndWallLogic():
	if(touchingGround and !groundRay.is_colliding()):
		touchingGround = false
		coyoteTime = true
		await(get_tree().create_timer(0.2).timeout)
		coyoteTime = false
	if(!touchingGround and groundRay.is_colliding()):
		ani.scale = Vector2(1.2,0.8) 
		canDash = true
	if(rightRay.is_colliding() or leftRay.is_colliding()):
		touchingWall = true
	else:
		touchingWall = false
	if(rightRay.is_colliding()):
		velocity.x = 0
		hSpeed = 0
	touchingGround = groundRay.is_colliding()
	if(touchingGround):
		isJumping = false
		velocity.y = 0
		vSpeed = 0
	
	if(touchingWall and !touchingGround and vSpeed > 0):
		if(Input.is_action_pressed("moveLeft") or Input.is_action_pressed("moveRight")):
			isWallSliding = true
		else:
			isWallSliding = false
	else:
		isWallSliding = false
	pass

func handleInput(delta):
	handleMovement(delta)
	handleJumping(delta)
	pass

func handleMovement(delta):
	if(Input.is_action_pressed("moveRight")):
		if(hSpeed < -100):
				hSpeed += (deacceleration * delta)
				if(touchingGround):
					ani.play("TURN")
		elif(hSpeed < maxHoriSpeed):
			hSpeed += (acceleration * delta)
			ani.flip_h = false
			if(touchingGround):
				ani.play("RUN")
		else:
			if(touchingGround):
				ani.play("RUN")
	elif(Input.is_action_pressed("moveLeft")):
		if(hSpeed > 100):
				hSpeed -= (deacceleration * delta)
				if(touchingGround):
					ani.play("TURN")
		elif(hSpeed > -maxHoriSpeed):
			hSpeed -= (acceleration * delta)
			ani.flip_h = true
			if(touchingGround):
				ani.play("RUN")
		else:
			if(touchingGround):
				ani.play("RUN")
	else:
		if(touchingGround):
			ani.play("IDLE")
		hSpeed -= min(abs(hSpeed),currentFriction * delta) * sign(hSpeed)
	pass

func handleJumping(_delta):
	if(coyoteTime and Input.is_action_just_pressed("jump")):
		vSpeed = jumpHeight
		isJumping = true
	if(touchingGround):
		if((Input.is_action_just_pressed("jump") or airJumpPressed) and !isJumping):
			vSpeed = jumpHeight
			isJumping = true
			touchingGround = false
			ani.scale = Vector2(0.5, 1.2)
	else:
		if(vSpeed < 0 and !Input.is_action_pressed("jump")):
			vSpeed = max(vSpeed,jumpHeight / 2)
		if(rightRay.is_colliding() and Input.is_action_just_pressed("jump")):
			vSpeed = wallJumpHeight
			hSpeed = -wallJumpPush
			ani.flip_h = true
		elif(leftRay.is_colliding() and Input.is_action_just_pressed("jump")):
			vSpeed = wallJumpHeight
			hSpeed = wallJumpPush
			ani.flip_h = false
			
		if(isWallSliding):
			ani.play("WALLSLIDE")
			
		if(Input.is_action_just_pressed("jump")):
			airJumpPressed = true
			await(get_tree().create_timer(.5).timeout)
			airJumpPressed = false
	pass

func handleDash(delta):
	if(Input.is_action_just_pressed("dash") and canDash and !touchingGround):
		isDashing = true
		canDash = false
		dashDirection = get_direction_from_input()
		dashTimer.start(dashLength)
	if(isDashing):
		var dashNode = dashObject.instantiate()
		#dashNode.texture = ani.frames.get_frame(ani.animation,ani.frame)
		dashNode.global_position = global_position
		dashNode.flip_h = ani.flip_h
		get_parent().add_child(dashNode)
		if(touchingGround):
			isDashing = false
		if(rightRay.is_colliding() or leftRay.is_colliding()):
			isDashing = false
		pass

func doPhysics(delta):
	if(is_on_ceiling()):
		velocity.y = 10
		vSpeed = 10
	if(touchingGround):
		vSpeed = 0
		velocity.y = 0
	else:
		if(!isWallSliding):
			vSpeed += (gravity * delta)
			vSpeed = min(vSpeed, maxFallSpeed)
		else:
			vSpeed += (wallSlideGravity * delta)
			vSpeed = min(vSpeed, maxWallSlideFallSpeed)
	velocity.y = vSpeed
	velocity.x = hSpeed
	if(isDashing):
		print("dashDir" + str(dashDirection))
		velocity.y += dashDirection.y
		velocity.x += dashDirection.x
		move_and_slide()
		vSpeed = 0
		hSpeed = 0
	else:
		move_and_slide()
	if touchingWall:
		handleWallCollisionCorrection()
	applySquashSqueeze()
	pass

func applySquashSqueeze():
	ani.scale.x = lerp(ani.scale.x, 1.0, squashSpeed)
	ani.scale.y = lerp(ani.scale.y, 1.0, squashSpeed)
	pass

func handleWallCollisionCorrection():
	var direction = 1 if hSpeed > 0 else -1
	var ray = rightRay if direction == 1 else leftRay
	if ray.is_colliding():
		var collision = ray.get_collision_point()
		var wallWidth = 8  # Adjust this value based on your wall thickness
		if direction == 1:
			position.x = collision.x - wallWidth
		else:
			position.x = collision.x + wallWidth
	pass
