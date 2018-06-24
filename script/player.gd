extends KinematicBody2D

const SPEED = 384.0
const MAX_WATER = 1.28

var movingUp = false
var movingDown = false
var movingLeft = false
var movingRight = false
var inPond = false
var wantsWatering = false
var score = 0
var numFruit = 0
var water = MAX_WATER
var velocity = Vector2()

onready var fruitHud = [get_node("FruitHud/Fruit0"), get_node("FruitHud/Fruit1"), 
						get_node("FruitHud/Fruit2"), get_node("FruitHud/Fruit3")]

func reset():
	movingUp = false
	movingDown = false
	movingLeft = false
	movingRight = false
	inPond = false
	wantsWatering = false
	score = 0
	numFruit = 0
	water = MAX_WATER
	velocity = Vector2()
	position = Vector2(512.0, 360.0)
	for f in fruitHud:
		f.hide()
	$WaterParticles.emitting = false
	$WaterBar.value = 1.28
	$Ani/AniPlayer.play("idle")
	$Ani/ArmAniPlayer.play("idle")

func collect(fruit):
	if numFruit < 4:
		fruitHud[numFruit].show()
		numFruit += 1
		$PickupPlayer.pitch_scale = 0.7 + 0.3 * numFruit
		$PickupPlayer.play()
		return true
	return false

func checkInput(event):
	if event.is_action_pressed("up"):
		movingUp = true
	elif event.is_action_pressed("down"):
		movingDown = true
	elif event.is_action_pressed("left"):
		movingLeft = true
	elif event.is_action_pressed("right"):
		movingRight = true
	elif event.is_action_pressed("watering"):
		wantsWatering = true
		if water > 0:
			$Ani/ArmAniPlayer.play("pour")
			$WaterParticles.emitting = true
			$SprinklePlayer.play()
	elif event.is_action_released("up"):
		movingUp = false
	elif event.is_action_released("down"):
		movingDown = false
	elif event.is_action_released("left"):
		movingLeft = false
	elif event.is_action_released("right"):
		movingRight = false
	elif event.is_action_released("watering"):
		wantsWatering = false
		$Ani/ArmAniPlayer.play("idle")
		$WaterParticles.emitting = false
		$SprinklePlayer.stop()

func enterPond():
	inPond = true
	if water < MAX_WATER:
		$SlurpPlayer.play()

func exitPond():
	inPond = false
	$SlurpPlayer.stop()
	
func enterBushel():
	for fh in fruitHud:
		fh.hide()
	score += numFruit
	get_node("../Score/ScoreLabel").text = "Score: " + str(score)
	if numFruit > 0:
		$DropoffPlayer.play()
	numFruit = 0

func updateWater(delta):
	if inPond && water < MAX_WATER:
		if water == 0.0 && wantsWatering:
			$Ani/ArmAniPlayer.play("pour")
			$WaterParticles.emitting = true
			$SprinklePlayer.play()
		water += delta * 1.5
		if water > MAX_WATER:
			water = MAX_WATER
			$SlurpPlayer.stop()
	if wantsWatering && water > 0:
		var waterSprayed = delta
		if water <= waterSprayed:
			waterSprayed = water
			water = 0
			$Ani/ArmAniPlayer.play("idle")
			$WaterParticles.emitting = false
			$SprinklePlayer.stop()
		else:
			water -= waterSprayed
		for p in get_node("../Plots").get_children():
			if p.isColliding:
				p.addWater(waterSprayed)
	$WaterBar.value = water

func move(delta):
	var prevMove = velocity.length_squared()
	var accel = Vector2(0.0, 0.0)
	if movingUp:
		accel.y -= 1.0
	if movingDown:
		accel.y += 1.0
	if movingLeft:
		accel.x -= 1.0
	if movingRight:
		accel.x += 1.0
	accel = accel.normalized() * SPEED / 8.0
	velocity += accel
	if abs(velocity.length()) > SPEED:
		velocity = velocity.normalized() * SPEED
	if !(movingUp || movingDown || movingLeft || movingRight):
		velocity *= 0.95
	move_and_slide(velocity)
	if abs(velocity.length_squared()) >= 4096.0:
		if prevMove < 4096.0:
			$Ani/AniPlayer.play("move")
		if velocity.x > 0.0:
			$Ani.scale = Vector2(1.0, 1.0)
		elif velocity.x < 0.0:
			$Ani.scale = Vector2(-1.0, 1.0)
	elif prevMove > 4096.0:
		$Ani/AniPlayer.play("idle")

func update(delta):
	updateWater(delta)
	move(delta)