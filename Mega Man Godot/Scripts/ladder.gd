extends Node2D
@onready var ladder_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D



func _on_ladder_area_body_entered(body:Node2D) -> void:
    if body.name == "Player":
        body.climb_ready = true

        if body.can_climb ==  true:
            body.position.x = ladder_collision.position.x


func _on_ladder_area_body_exited(body:Node2D) -> void:
    if body.name == "Player":
        body.climb_ready = false
        ladder_collision.set_deferred("disabled", false)
       

func _on_ladder_area_down_body_entered(body:Node2D) -> void:
    if body.name == "Player":
        if body.climb_ready_down == true:
            ladder_collision.set_deferred("disabled", true)


    
func _on_ladder_area_down_body_exited(body:Node2D) -> void:
    if body.name == "Player":
        body.climb_ready_down = false
