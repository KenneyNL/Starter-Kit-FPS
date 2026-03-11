extends Node

# Code adapted from KidsCanCode

var num_players:int = 12
var bus:String = "master"

var available:Array[AudioStreamPlayer] = []  # The available players.
var queue:Array[String] = []  # The queue of sounds to play.

func _ready() -> void:
	for i in num_players:
		var p := AudioStreamPlayer.new()
		add_child(p)

		available.append(p)

		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream:AudioStreamPlayer) -> void:
	available.append(stream)

func play(sound_path:String) -> void:  # Path (or multiple, separated by commas)
	var sounds:PackedStringArray = sound_path.split(",")
	queue.append("res://" + sounds[randi() % sounds.size()].strip_edges())

func _process(_delta:float) -> void:
	if not queue.is_empty() and not available.is_empty():
		# The "queue" Array holds "String" values, but unfortunately most of the
		# containers in Godot will not return the assigned type and return a "Variant"
		# type instead.  This reduces the safety that static typing provides.
		# As a workaround, we manually cast the popped value as a String and
		# ignore the warning.
		@warning_ignore("unsafe_cast")
		available[0].stream = load((queue.pop_front() as String))
		
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)

		available.pop_front()
