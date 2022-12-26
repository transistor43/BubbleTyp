extends KinematicBody2D

signal died

var velocity: Vector2

export var gravity: float = 5
export var max_speed: float = 100
export var acceleration: Curve

export var initial_jump_speed: float = 100
export var air_jump_speed: float = 2

export var dash_speed: float = 1000
export var dash_curve: Curve

var bubbled: bool

var dash_time: float
var dashing: bool

var state_machine

func _ready():
	state_machine = $AnimationTree["parameters/playback"]

func _physics_process(delta):
	velocity += Vector2.DOWN * gravity
	
	var input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input != 0:
		state_machine.travel("Walk")
	else:
		state_machine.travel("idle")
	$AnimationTree.set("parameters/Walk/blend_position", input)
	
	var thorsten = velocity.x  / max_speed
	if input < 0:
		thorsten = min(0, thorsten)
	elif input > 0:
		thorsten = max(0, thorsten)
	else:
		thorsten = 0
	velocity.x = lerp(velocity.x, input * max_speed, acceleration.interpolate_baked(abs(thorsten)))
	
	if Input.is_action_just_pressed("jump") && $JumpDetector.get_overlapping_bodies().size() > 1 and not bubbled:
		velocity.y = -initial_jump_speed
		$JumpAnimationPlayer.play("Jump")
		$JumpSound.play()
	
	if Input.is_action_pressed("jump"):
		velocity.y -= air_jump_speed
		
	if Input.is_action_just_pressed("dash") and not input == 0 and not dashing:
		dashing = true
		dash_time = 0
		$DashEffect.scale.x = input / abs(input)
		$DashAnimationPlayer.play("Dash")
		$DashSound.play()
	elif dashing:
		dash_time += delta * 7
		if dash_time > 3:
			dashing = false
	if Input.is_action_just_released("bubble"):
		$BubbleSound.play()
	if Input.is_action_pressed("bubble"):
		bubbled = true
		$Bubble.visible = true
		velocity.x /= 2
		if velocity.y > 0:
			velocity.y /= 1.05
	else:
		bubbled = false
		$Bubble.visible = false

	if bubbled and $JumpDetector.get_overlapping_bodies().size() > 1:
		velocity.y = -velocity.y


	velocity = move_and_slide(velocity)
	move_and_slide(Vector2.RIGHT * input * dash_curve.interpolate_baked(dash_time) * dash_speed)


func _on_JumpDetector_body_entered(body):
	$JumpAnimationPlayer.play("Jump")


func _on_Hitbox_damaged():
	if not bubbled:
		emit_signal("died")
		get_tree().reload_current_scene()
