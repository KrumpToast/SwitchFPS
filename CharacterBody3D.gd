extends CharacterBody3D
class_name player 
static var instance1

var chealth = 3.0
#speed
var speed 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0 
const JUMP_VELOCITY = 4.5
const SENS = 0.006 

const HIT_STAGGER = 8.0

#Double Jump
var hasDoubleJumped = false

#crouch/crawl speed
var crouchSpeed = 3.5
var crawlSpeed = 2.5

var trueSpeed = WALK_SPEED

var isCrouch = false
var isCrawl = false

# bob variables 
const BOB_FREQ = 2.0
const BOB_AMP = 0.06
var t_bob = 0.0 

#fov variables 
const BASE_POV = 75.0
const FOV_CHANGE = 1

signal player_hit


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

# gun
var is_shooting = false
var bullet = load("res://bullet.tscn")
var instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gun_anim = $Head/Camera3D/GUN/AnimationPlayer 
@onready var gun_barrel = $Head/Camera3D/GUN/RayCast3D
@onready var shot_anim = $Head/Camera3D/shotgun/AnimationPlayer

func _ready():
	print(gun_anim)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	instance1 = self
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENS)
		camera.rotate_x(-event.relative.y * SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(65))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	else: 
		hasDoubleJumped = false 

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or is_on_wall() or hasDoubleJumped == false: 
			if hasDoubleJumped == false and is_on_floor() == false and is_on_wall() == false: 
				hasDoubleJumped = true
			velocity.y = JUMP_VELOCITY

#CROUCHCRAWL
	if Input.is_action_just_pressed("crouch"):
		movementStateChange("crouch")
		trueSpeed = crouchSpeed
		
	elif Input.is_action_just_released("crouch"):
		movementStateChange("uncrouch")
		trueSpeed = WALK_SPEED
			
	elif Input.is_action_just_pressed("crawl"): 
		movementStateChange("crawl")
		trueSpeed = crawlSpeed
	elif Input.is_action_just_released("crawl"):
		movementStateChange("uncrawl")
		trueSpeed = WALK_SPEED

#Handle sprint.
	if Input.is_action_pressed("sprint"):
		trueSpeed = SPRINT_SPEED
	else: 
		trueSpeed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * trueSpeed
			velocity.z = direction.z * trueSpeed
		else:
			velocity.x = lerp(velocity.x, direction.x * trueSpeed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * trueSpeed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * trueSpeed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * trueSpeed, delta * 3.0)
		
		# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob) 
	
	#FOV 
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2.0)
	var target_fov = BASE_POV + FOV_CHANGE * velocity_clamped 
	camera.fov = lerp(camera.fov, target_fov, delta* 8.0)
	
	#Shoot
	if Input.is_action_just_pressed("shoot"): 
		if is_shooting == false: 
			if !gun_anim.is_playing():
				gun_anim.play("Shoot")
				is_shooting = true
				instance = bullet.instantiate()
				instance.position  = gun_barrel.global_position
				instance.transform.basis = gun_barrel.global_transform.basis
				get_parent().add_child(instance)
	elif Input.is_action_just_released("shoot"):
		is_shooting = false

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ /2) *BOB_AMP
	return pos
	
#crawlspeedcrouch
func movementStateChange(changeType): 
	match changeType:
		"crouch":
			if isCrawl:
				$AnimationPlayer.play_backwards("CrouchToCrawl")
			else:
				$AnimationPlayer.play("StandingToCrouch")
			isCrouch = true
			#changeCollisionShape to crouch
			isCrawl = false
			
		"uncrouch":
			$AnimationPlayer.play_backwards("StandingToCrouch")
			isCrouch = false
			isCrawl = false
			#changeCollisionShape to standing
			
		"crawl":
			if isCrouch:
				$AnimationPlayer.play("CrouchToCrawl")
			else:
				$AnimationPlayer.play("StandingToCrawl")
			isCrouch = false
			isCrawl = true
			#changeCollisionShape to crawling
		
		"uncrawl":
			$AnimationPlayer.play_backwards("StandingToCrawl")
			isCrouch = false
			isCrawl = false
			#changeCollisionShape to standing
			
func hit(dir): 
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	chealth -= 1
	if chealth <= 0:
		get_tree().change_scene_to_file("res://button.tscn")
