extends Node2D

var gameplay_map := {
	"purple": preload("res://Assets/Audio/challenge_purple.mp3"),
	"green": preload("res://Assets/Audio/challenge_green.mp3"),
	"yellow": preload("res://Assets/Audio/challenge_yellow.mp3"),
	"orange": preload("res://Assets/Audio/challenge_orange.mp3"),
	"pink": preload("res://Assets/Audio/challenge_pink.mp3"),
	"blue": preload("res://Assets/Audio/challenge_blue.mp3"),
	"red": preload("res://Assets/Audio/challenge_red.mp3")
}

func ResumeMusic() -> void:
	
	var bus := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, 0.0) #Full Volume
	
func setMusicVolume(_vol) -> void:
	
	var bus := AudioServer.get_bus_index("Music")
	match _vol:
		"high":
			AudioServer.set_bus_volume_db(bus, 0.0) #Full Volume
		"low":
			AudioServer.set_bus_volume_db(bus, -6.0) #Half Volume
		"off":
			AudioServer.set_bus_volume_db(bus, -80.0) #Mute

func setGamePlayVolume(_vol) -> void:
	
	var bus := AudioServer.get_bus_index("GamePlay")
	match _vol:
		"analysing":
			AudioServer.set_bus_volume_db(bus, 0.0) #Full Volume
		"quiet":
			AudioServer.set_bus_volume_db(bus, 0.0) #Full Volume
		"loud":
			AudioServer.set_bus_volume_db(bus, 1.6) #Around 20% of Volume up

			
func playGameplayAudio(stream: String, pan: String):
	
	#Loads the Audio
	$GamePlayAudios.stream = gameplay_map[stream]
	
	#Decides the side
	var _pan_value: float = 0.0
	match pan:
		"dual":
			_pan_value = 0.0
		"random":
			var _pan_random_value = [-1.0,1.0] #-1.0 LEFT only, 1.0 RIGHT only
			_pan_random_value.shuffle()
			_pan_value = _pan_random_value[0]
	var bus := AudioServer.get_bus_index("GamePlay")
	var effect := AudioServer.get_bus_effect(bus, 0) # panner index
	#effect.pan = clamp(_pan_value, -1.0, 1.0)
	effect.pan = _pan_value #Audio Enhancment on Windows turns off the PAN effect
	#$GamePlayAudios.pan = _pan_value
	
	
	#Plays the Audio
	$GamePlayAudios.play()
	
func playBubbleFX():
	$BubbleFX.play()
	
	
