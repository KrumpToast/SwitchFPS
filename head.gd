extends CollisionShape3D

@export var damage:= 2 

signal body_part_hit(dam)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func hit():
	emit_signal("body_part_hit", damage)


func _on_body_body_part_hit(dam):
	pass # Replace with function body.
