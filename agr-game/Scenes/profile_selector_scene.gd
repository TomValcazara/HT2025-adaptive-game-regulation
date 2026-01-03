extends Node2D

var RoomStatusTextures := {
	"analysing": preload("res://Assets/Images/RoomNoiseLabelBlue.png"),
	"loud": preload("res://Assets/Images/RoomNoiseLabelRed.png"),
	"quiet": preload("res://Assets/Images/RoomNoiseLabelGreen.png"),
}

func _ready() -> void:
	
	var loadedProfiles = load_all_profiles()
	for _currentProfile in loadedProfiles:
		var profile := preload("res://Artefacts/profileListing.tscn").instantiate()
		profile.profile_id = _currentProfile.id
		profile.get_node("EditProfileImage/Text").text = str(_currentProfile.name)
		$ProfileList.add_child(profile)
	
	#Detects Room Noise
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(checkRoomStatus)
	add_child(timer)
	timer.start()

func _on_button_create_button_up() -> void:
	print("Creating new Profile")
	
	#Resets the current ID, so the game knows it is not working with a previous ID
	GlobalManager.resetProfile()
	FadeTransition.fade_to_scene("res://Scenes/ProfileEditorScene.tscn")

#func load_profile(profile_id: String) -> Dictionary:
	#var path := "user://profiles/%s.json" % profile_id
	#if not FileAccess.file_exists(path):
		#return {}
#
	#var file := FileAccess.open(path, FileAccess.READ)
	#var data: Variant = JSON.parse_string(file.get_as_text())
	#file.close()
#
	#return data
	
func load_all_profiles() -> Array:
	var profiles := []
	var dir := DirAccess.open("user://profiles")
	if dir == null:
		return profiles

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file := FileAccess.open("user://profiles/" + file_name, FileAccess.READ)
			profiles.append(JSON.parse_string(file.get_as_text()))
			file.close()
		file_name = dir.get_next()

	dir.list_dir_end()
	return profiles

var dotsCounter = 1
func checkRoomStatus() -> void:
	
	match NoiseSensorBridge.RoomStatus:
		"analysing":
			var _animatedDotsText = ""
			for dot in dotsCounter:
				_animatedDotsText = _animatedDotsText+". "
			$AudioStatus/Label.text = "Analysing Room Noise "+_animatedDotsText
			if dotsCounter < 4:
				dotsCounter += 1
			else:
				dotsCounter = 1
		"quiet":
			$AudioStatus/Label.text = "The Room is Quiet."
		"loud":
			$AudioStatus/Label.text = "The Room is Loud."
	$AudioStatus.texture = RoomStatusTextures[NoiseSensorBridge.RoomStatus]
	
	
