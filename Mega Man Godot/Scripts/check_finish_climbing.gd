extends Area2D


func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    print("weszło:", body.name)

    if body.is_in_group("Player"):
        body.finish_climb = true
        print("ok")




func _on_body_exited(body: Node2D) -> void:
     if body.is_in_group("Player"):
        body.finish_climb = false
	
