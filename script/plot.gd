extends Area2D

export(float, 4.0, 16.0, 2.0) var rate = 3.0

const MAX_WATER = 10.24

var alive = true
var isColliding = false
var water = MAX_WATER
var fruitTimer = 0.0
var fruitPos = Vector2()

var fruitClass = preload("res://scene/fruit.tscn")

func _ready():
	connect("body_entered", self, "setColliding", [true])
	connect("body_exited", self, "setColliding", [false])

func spawnFruit():
	fruitPos = Vector2(-128.0 + 256.0 * randf(), -64.0 + 128.0 * randf())
	$Fruit.position = fruitPos
	$Fruit/AniPlayer.playback_speed = 4.0 / rate
	$Fruit/AniPlayer.play("grow")
	$Fruit.show()

func setColliding(body, c):
	if body == get_parent().get_parent().player:
		isColliding = c

func addWater(w):
	if alive:
		water += w * 5.0
		if water > MAX_WATER:
			water = MAX_WATER
		if water > 1.75:
			modulate = Color(1.0, 1.0, 1.0)
			$WarningPlayer.stop()

func updateFruit(delta):
	fruitTimer += delta
	if fruitTimer >= rate:
		fruitTimer -= rate
		var fruit = fruitClass.instance()
		fruit.position = position + fruitPos
		get_node("../../Fruits").add_child(fruit)
		$SpawnPlayer.play()
		spawnFruit()

func updateWater(delta):
	var prevWater = water
	water -= delta / rate
	$WaterBar.value = water
	if water <= 0:
		alive = false
		modulate = Color(0.25, 0.25, 0.25)
		$Fruit.hide()
		$ded.show()
		$WarningPlayer.stop()
		$AudioStreamPlayer2D.play()
	elif water < 1.75:
		var m = cos(water * 18.4 + PI) / 4.0 + 0.75
		modulate = Color(m, m, m)
		if prevWater > 1.75:
			$WarningPlayer.play()

func update(delta):
	if alive:
		updateFruit(delta)
		updateWater(delta)