extends Node3D

@onready var hit_rect = $UIW/ColorRect
@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D

var ryan = load("res://RTYA.tscn")
var rinstance

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_character_body_3d_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
#func _get_random_child(parent_node):
	#var random_id = randi_range(0, parent_node.get_child_count()-1)  
	#return parent_node.get_child(random_id)


#func _on_spawn_timer_timeout():
	#var spawn_point = _get_random_child(spawns).global_position
	#rinstance = ryan.instantiate() 
	#rinstance.position = spawn_point
	#navigation_region.add_child(rinstance)
