extends Control

func _ready():
	if not MusicTitleScreen.is_playing():
		MusicTitleScreen.play()

func _on_Level1_pressed():
	$SFXSelect.play()
	get_tree().change_scene("res://levels/Level1.tscn")


func _on_Level2_pressed():
	$SFXSelect.play()
	get_tree().change_scene("res://levels/Level2.tscn")


func _on_Back_pressed():
	$SFXSelect.play()
	get_tree().change_scene("res://titleScreen/TitleScreen.tscn")
