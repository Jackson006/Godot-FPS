extends Spatial

# All of the audio files.
var audio_pistol_shot = preload("res://Blast Laser 2.wav") # the sound for the pistol firing
var audio_gun_cock = preload("res://WEAPON CLICK Reload Mechanism 01.wav") # the sound for the weapons reloading
var audio_rifle_shot = preload("res://Big Blast 4.wav") # The sound of the rifle firing

var audio_node = null

func _ready(): # makes sure no audio is playing to begin with?
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "destroy_self")
	audio_node.stop()


func play_sound(sound_name, position=null):
	if audio_pistol_shot == null or audio_rifle_shot == null or audio_gun_cock == null: # plays the required audio for the guns
		print ("Audio not set!")
		queue_free()
		return

# plays the required audio for the guns
	if sound_name == "Pistol_shot":
		audio_node.stream = audio_pistol_shot
	elif sound_name == "Rifle_shot":
		audio_node.stream = audio_rifle_shot
	elif sound_name == "Gun_cock":
		audio_node.stream = audio_gun_cock
	else:
		print ("UNKNOWN STREAM")
		queue_free()
		return

# If you are using an AudioStreamPlayer3D, then uncomment these lines to set the position.
#if audio_node is AudioStreamPlayer3D:
#    if position != null:
#        audio_node.global_transform.origin = position

	audio_node.play()


func destroy_self(): # stops the audio when it is finished playing
	audio_node.stop()
	queue_free()
