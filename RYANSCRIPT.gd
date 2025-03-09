extends CharacterBody3D

var state_machine
var health = 6

const SPEED = 4.0 
const ATTACK_RANGE = 2.5

@export var player_path := "/root/Game/NavigationRegion3D/CharacterBody3d"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = anim_tree.get("parameters/playback")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"WALK":
			nav_agent.set_target_position(player.instance1.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"ATTACK":
			look_at(Vector3(player.instance1.global_position.x, global_position.y, player.instance1.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.instance1.global_position) < ATTACK_RANGE

func _hit_finished(): 
	if global_position.distance_to(player.instance1.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.instance1.global_position)
		player.instance1.hit(dir) 


func _on_collision_shape_3d_body_part_hit(dam):
	health -= dam
	if health <= 0:
		queue_free()


func _on_area_3d_body_part_hit(dam):
	health -= dam
	if health <= 0:
		queue_free()
