extends Area2D

signal damaged

func _on_Hitbox_body_entered(body):
	emit_signal("damaged")
