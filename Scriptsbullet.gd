extends Node3D


const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	particles.emitting = false 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var step = SPEED * delta 
	var next_position = position + transform.basis * Vector3(0, 0, -step) 
	ray.global_transform.origin = next_position
	ray.target_position = Vector3(0, 0, -SPEED * delta * 4)
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider = ray.get_collider()
		var hit_position = ray.get_collision_point()
		var hit_normal = ray.get_collision_normal()
		mesh.visible = false   
		particles.global_transform.origin = hit_position 
		particles.look_at(hit_position + hit_normal, Vector3.UP)  
		particles.emitting = true
		ray.enabled = false
		if ray.get_collider() is head:
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		position = next_position 
	  


func _on_timer_timeout():
	queue_free()
