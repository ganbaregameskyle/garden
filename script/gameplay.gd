extends Node2D

onready var fruitArray = [get_node("Bushel/Fruits/Fruit0"), get_node("Bushel/Fruits/Fruit1"), get_node("Bushel/Fruits/Fruit2"), 
							get_node("Bushel/Fruits/Fruit3"), get_node("Bushel/Fruits/Fruit4"), get_node("Bushel/Fruits/Fruit5"), 
							get_node("Bushel/Fruits/Fruit6"), get_node("Bushel/Fruits/Fruit7"), get_node("Bushel/Fruits/Fruit8"), 
							get_node("Bushel/Fruits/Fruit9"), get_node("Bushel/Fruits/Fruit10"), get_node("Bushel/Fruits/Fruit11"), 
							get_node("Bushel/Fruits/Fruit12"), get_node("Bushel/Fruits/Fruit13"), get_node("Bushel/Fruits/Fruit14")]

var gaming = false
var highscore = 0
var prevTime = 120.0
var player = null

func _ready():
	randomize()
	player = preload("res://scene/player.tscn").instance()
	add_child(player)
	$CanvasLayer/ResetButton.connect("button_up", self, "reset")
	$CanvasLayer/MuteButton.connect("button_up", self, "mute")
	$Pond.connect("body_entered", self, "enterPond")
	$Pond.connect("body_exited", self, "exitPond")
	$Bushel.connect("body_entered", self, "enterBushel")
	$StartTimer.connect("timeout", self, "start")
	$Popup/Button.connect("button_up", self, "reset")
	$TimeBar/Tween.connect("tween_completed", self, "endGame")
	set_process_input(true)
	set_physics_process(true)

func start():
	var rates = [4.0, 6.0, 8.0, 10.0]
	for p in $Plots.get_children():
		var i = randi() % rates.size()
		p.rate = rates[i]
		p.spawnFruit()
		rates.remove(i)
	gaming = true
	$TimeBar/Tween.interpolate_property($TimeBar, "value", 120.0, 0.0, 120.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$TimeBar/Tween.start()

func reset():
	player.get_node("SprinklePlayer").stop()
	player.get_node("SlurpPlayer").stop()
	for p in $Plots.get_children():
		p.get_node("WarningPlayer").stop()
		p.water = 10.24
		p.modulate = Color(1.0, 1.0, 1.0)
		p.alive = true
		p.get_node("Fruit/AniPlayer").stop()
		p.get_node("Fruit").hide()
		p.get_node("ded").hide()
		p.get_node("WaterBar").value = 10.24
		p.fruitTimer = 0.0
	for f in $Bushel/Fruits.get_children():
		f.hide()
	for f in $Fruits.get_children():
		f.queue_free()
	$TimeBar/Tween.stop_all()
	$StartTimer.stop()
	$Score/ScoreLabel.text = "Score: 0"
	$TimeBar.value = 120.0
	$TimeLabel.text = "2:00"
	$Popup.hide()
	player.reset()
	gaming = false
	AudioServer.set_bus_effect_enabled(0, 0, true)
	$Camera.position = Vector2(512.0, -480.0)

func mute():
	var muted = !AudioServer.is_bus_mute(0)
	$CanvasLayer/MuteButton/Slash.visible = muted
	AudioServer.set_bus_mute(0, muted)

func endGame(obj, key):
	player.get_node("SprinklePlayer").stop()
	player.get_node("SlurpPlayer").stop()
	for p in $Plots.get_children():
		p.get_node("WarningPlayer").stop()
	gaming = false
	if player.score > highscore:
		if player.score > 73:
			$Popup/Label.text = "You cheating bastard."
		else:
			highscore = player.score
			$Title/HighScoreLabel.text = "HIGH SCORE: " + str(player.score)
			if player.score == 73:
				$Popup/Label.text = "You got the new High Score with 73 points! You mathematically cannot do better!"
			elif player.score >= 70:
				$Popup/Label.text = "You got the new High Score with " + str(player.score) + " points! You probably can't do better."
			else:
				$Popup/Label.text = "You got the new High Score with " + str(player.score) + " points! But you can do better!"
	elif player.score == highscore:
		if player.score == 0:
			$Popup/Label.text = "You got zero points! You didn't play at all, did you?"
		elif player.score > 73:
			$Popup/Label.text = "You cheating bastard."
		elif player.score == 73:
			$Popup/Label.text = "You tied with the High Score of 73 points! You mathematically cannot do better!"
		elif player.score >= 70:
			$Popup/Label.text = "You tied with the High Score of " + str(player.score) + " points! You probably can't do better."
		else:
			$Popup/Label.text = "You tied with the High Score of " + str(player.score) + " points! But you can do better!"
	else:
		if player.score == 0:
			$Popup/Label.text = "You got zero points! You didn't play at all, did you?"
		elif player.score == 0:
			$Popup/Label.text = "Good job! You got " + str(player.score) + " point! But you can do much better!"
		else:
			$Popup/Label.text = "Good job! You got " + str(player.score) + " points! But you can do better!"
	$Popup.show()

func enterPond(body):
	if body == player:
		player.enterPond()

func exitPond(body):
	if body == player:
		player.exitPond()

func enterBushel(body):
	if body == player:
		var prevScore = player.score
		player.enterBushel()
		if prevScore < player.score && player.score < 75:
			fruitArray[player.score / 5].show()

func _input(event):
	if gaming:
		player.checkInput(event)
	else:
		if !$Popup.visible && $StartTimer.is_stopped():
			if event.is_action_released("watering"):
				player.position = Vector2(512.0, 360.0)
				AudioServer.set_bus_effect_enabled(0, 0, false)
				$Camera.position = Vector2(512.0, 300.0)
				$CountdownPlayer.play()
				$StartTimer.start()

func _physics_process(delta):
	if gaming:
		var time = int($TimeBar.value)
		if time <= 3.0 && prevTime > 3.0:
			$TimeupPlayer.play()
		$TimeLabel.text = str(time / 60) + ":%02d" % (time % 60)
		player.update(delta)
		for p in $Plots.get_children():
			p.update(delta)
		prevTime = time
