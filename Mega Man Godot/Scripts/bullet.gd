extends Sprite2D

var speed = 500
var direction = 3


func _physics_process(delta):
	move_local_x(direction * speed * delta)



func _on_timer_timeout():
	queue_free()
