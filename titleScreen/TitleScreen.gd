extends Control

func _ready():
	$CanvasLayer/Buttons/NewGame.grab_focus()
	if not MusicTitleScreen.is_playing():
		MusicTitleScreen.play()

func _on_NewGame_pressed():
	$SFXSelect.play()
	get_tree().change_scene("res://menu/ControlsScreen.tscn")

func _on_Quit_pressed():
	$SFXSelect.play()
	get_tree().quit()

func _on_SelectLevel_pressed():
	$SFXSelect.play()
	get_tree().change_scene("res://menu/SelectLevel.tscn")
