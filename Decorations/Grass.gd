extends Sprite

export var text_green: Texture
export var text_yellow: Texture


func _ready():
	if frame > 1:
		$Particles2D.texture = text_green
	else:
		$Particles2D.texture = text_yellow

func _on_PlayerDetector_body_entered(body):
	$AnimationPlayer.play("Wiggle")
