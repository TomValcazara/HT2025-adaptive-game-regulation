extends Node2D

var time_left_onreading := 10

func _ready() -> void:
	
	if GlobalManager.CurrentProfile:
		state_machine("edit_profile")
	else:
		state_machine("create_profile")
		
		
	#if FadeTransition.fade_to_scene("res://Scenes/ProfileSelectorScene.tscn")
func state_machine(state):
	
	match state:
		"create_profile":
			$LabelTitle.text = "CREATE PROFILE"
			
			$CreateProfileWrapper/ProfileNameBox/ButtonCreateProfile.disabled = false
			
			$CreateProfileWrapper.visible = true
			$EditProfileWrapper.visible = false
			$RegisteringReadingWrapper.visible = false
			$SaveReadingWrapper.visible = false
			
		"edit_profile":
			$LabelTitle.text = "EDIT PROFILE: "+str(GlobalManager.CurrentProfile.name)
			
			$EditProfileWrapper/LabelCreatedAt.text = "PROFILE CREATED AT: "+str(GlobalManager.CurrentProfile["created_at"])+"  / ID: "+str(GlobalManager.CurrentProfile["id"])
			
			#Load the EDA Readings List
			for _child in $EditProfileWrapper/ReadingsList/VBoxWrapper.get_children():
				_child.queue_free()
			for _eda_readings in GlobalManager.CurrentProfile["emotibit_reading"]:
				var new_entry := preload("res://Artefacts/ReadingsList.tscn").instantiate()
				new_entry.get_node("LabelCreatedAt").text = str(_eda_readings.created_at)
				new_entry.get_node("LabelEDAReading").text = str(_eda_readings.eda_reading_value)
				new_entry.get_node("LabelClassification").text = str(_eda_readings.classification).to_upper()
				$EditProfileWrapper/ReadingsList/VBoxWrapper.add_child(new_entry)
				
			$CreateProfileWrapper.visible = false
			$EditProfileWrapper.visible = true
			$RegisteringReadingWrapper.visible = false
			$SaveReadingWrapper.visible = false
					
		"register_reading":
			$LabelTitle.text = "REGISTERING READING: "+str(GlobalManager.CurrentProfile.name)
			
			$RegisteringReadingWrapper/Timer/Label.text = "10 Seconds"
			$RegisteringReadingWrapper/ButtonStartReading.disabled = false
			time_left_onreading = 10
			
			$CreateProfileWrapper.visible = false
			$EditProfileWrapper.visible = false
			$RegisteringReadingWrapper.visible = true
			$SaveReadingWrapper.visible = false
			
		"save_reading":
			$LabelTitle.text = "SAVING READING: "+str(GlobalManager.CurrentProfile.name)
			
			$CreateProfileWrapper.visible = false
			$EditProfileWrapper.visible = false
			$RegisteringReadingWrapper.visible = false
			$SaveReadingWrapper.visible = true
			
func save_profile(profile_id: String, data: Dictionary):
	
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("profiles"):
		dir.make_dir("profiles")

	var file := FileAccess.open(
		"user://profiles/%s.json" % profile_id,
		FileAccess.WRITE
	)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Profile Saved")


func _on_button_create_profile_button_up() -> void:
	
	$CreateProfileWrapper/ProfileNameBox/ButtonCreateProfile.disabled = true
	
	var profile_name = $CreateProfileWrapper/ProfileNameBox/LineEdit.text
	if !profile_name:
		profile_name = "NO NAME"
	var profile_id = checkAvaiableID()
	var file_name = str(profile_id)
	#var time_stamp = Time.get_unix_time_from_system()
	var time_stamp := Time.get_datetime_dict_from_system()
	var formated_time_stamp := "%02d/%02d/%04d at %02d:%02d" % [
		time_stamp.month, time_stamp.day, time_stamp.year, time_stamp.hour, time_stamp.minute
	]

	var data = {
		"id": profile_id,
		"name": profile_name,
		"created_at": formated_time_stamp,
		"emotibit_reading": []
	}
	save_profile(file_name, data)
	
	GlobalManager.loadProfile(profile_id) #Loads Current Profile into the Global System
	
	state_machine("register_reading")
	
func checkAvaiableID() -> int:
	
	var profiles := []
	var dir := DirAccess.open("user://profiles")
	dir.list_dir_begin()
	var id = 0 #Starts with ID 1
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file := FileAccess.open("user://profiles/" + file_name, FileAccess.READ)
			var current_profile = JSON.parse_string(file.get_as_text())
			if current_profile.id >= id: #If it finds a bigger ID it is stored to compare
				id = current_profile.id
			file.close()
		file_name = dir.get_next()
	dir.list_dir_end()
	id = id + 1 #Creates a new valid ID
	return id
	
func _on_line_edit_text_changed(new_text: String) -> void: #Forces Uppercase Only
	$CreateProfileWrapper/ProfileNameBox/LineEdit.text = new_text.to_upper()
	$CreateProfileWrapper/ProfileNameBox/LineEdit.caret_column = $CreateProfileWrapper/ProfileNameBox/LineEdit.text.length()


func _on_button_start_reading_button_up() -> void:
	
	#print("clicked")
	$RegisteringReadingWrapper/ButtonStartReading.disabled = true
	$RegisteringReadingWrapper/ButtonStartReading/TimerofReading.wait_time = 1.0
	$RegisteringReadingWrapper/ButtonStartReading/TimerofReading.start()

func _on_timerof_reading_timeout() -> void:
	
	#print("Every Second")
	time_left_onreading -= 1
	
	if time_left_onreading > 1:
		$RegisteringReadingWrapper/Timer/Label.text = str(time_left_onreading)+" Seconds"
	elif time_left_onreading == 1:
		$RegisteringReadingWrapper/Timer/Label.text = str(time_left_onreading)+" Second"
	elif time_left_onreading == 0:
		$RegisteringReadingWrapper/Timer/Label.text = "Finished"
	elif time_left_onreading < 0:	
		$RegisteringReadingWrapper/ButtonStartReading/TimerofReading.stop()
		state_machine("save_reading")
	


func _on_buttonsAnswer_button_up(extra_arg_0: String) -> void:
	
	var dataToSave = GlobalManager.CurrentProfile
	var time_stamp := Time.get_datetime_dict_from_system()
	var formated_time_stamp := "%02d/%02d/%04d at %02d:%02d" % [
		time_stamp.month, time_stamp.day, time_stamp.year, time_stamp.hour, time_stamp.minute
	]
	var file_name = str(dataToSave["id"])
	var profile_id = dataToSave["id"]
	var new_eda_entry = {
		"created_at": formated_time_stamp,
		"eda_reading_value": EmotiBitBridge.get_average_live_eda(),
		"classification": extra_arg_0
	}
	dataToSave["emotibit_reading"].append(new_eda_entry)
	
	save_profile(file_name, dataToSave)
	
	GlobalManager.loadProfile(profile_id) #Loads Current Profile into the Global System
	
	state_machine("edit_profile")
	
	#match extra_arg_0:
		#"relaxed":
			#pass
		#"neutral":
			#pass
		#"tense":
			#pass


func _on_button_new_entry_button_up() -> void:
	state_machine("register_reading")


func _on_button_finish_editing_button_up() -> void:
	FadeTransition.fade_to_scene("res://Scenes/ProfileSelectorScene.tscn")
