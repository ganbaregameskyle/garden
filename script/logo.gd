extends Node2D

func _ready():
	$Timer.connect("timeout", self, "nextScene")
	$Timer.start()
	$AudioStreamPlayer.play()

func nextScene():
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).queue_free()
	var sceneClass = load("res://scene/gameplay.tscn")
	var scene = sceneClass.instance()
	root.add_child(scene)
	get_tree().set_current_scene(scene)