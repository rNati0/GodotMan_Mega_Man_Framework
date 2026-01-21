extends StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	SignalisBus.connect("oneway_disabled", _one_way_disabled)


func _one_way_disabled():
	collision_shape_2d.disabled = true 
	await get_tree().create_timer(0.2).timeout
	collision_shape_2d.disabled = false



