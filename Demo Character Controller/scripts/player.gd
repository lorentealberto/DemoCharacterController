extends KinematicBody2D

export var HSPEED = 200 #Horizontal Speed
export var JPOWER = 525 #Jump Power
export var GRAVITY = 50 #Character Gravity
export var SOL = 150 #Speed on ladder

#Get object nodes
onready var animated_sprite = $AnimatedSprite
onready var area_2d = $Area2D

#Internal vars, necessary for correct operation
var velocity = Vector2.ZERO #Character current velocity
var direction = 0 #Character current direction
var on_ladder = false #If character is on a ladder or not

func _physics_process(_delta):
	flip()
	manage_animations()
	apply_gravity()
	horizontal_movement()
	jump()
	manage_ladders()
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	clamp_position()

#Manage character animations
func manage_animations():
	if velocity.x == 0: #If player velocity is zero, then play idle animation
		animated_sprite.play("idle")
	else: #If not zero then play walking animation
		animated_sprite.play("walking")

#Flip character sprite based on direction
func flip():
	if direction != 0:
		animated_sprite.flip_h = direction < 0

#If character is not on a ladder, apply gravity
func apply_gravity():
	if not on_ladder:
		velocity.y += GRAVITY

#Manage player horizontal movement
func horizontal_movement():
	direction = get_axis()
	velocity.x = direction * HSPEED

#If player is not on a ladder and is on floor, it may jump
func jump():
	if not on_ladder:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -JPOWER

#Detects interaction with ladders
func manage_ladders():
	if len(area_2d.get_overlapping_areas()) > 0:
		for area in area_2d.get_overlapping_areas():
			if area.is_in_group("ladder"):
				if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
					on_ladder = true
	else:
		on_ladder = false
	ladder_controls()

#If player is climbing a ladder, apply ladder controls
func ladder_controls():
	if on_ladder:
		if Input.is_action_pressed("move_up"):
			velocity.y = -SOL
		elif Input.is_action_pressed("move_down"):
			velocity.y = SOL
			if is_on_floor():
				on_ladder = false
		else:
			velocity.y = 0

#Clamp player position to avoid it may go outside screen
func clamp_position():
	position.x = clamp(position.x, 0, get_viewport_rect().size.x)

#Get character movement direction based on keys player is pressing
func get_axis():
	return Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
