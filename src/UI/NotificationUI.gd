extends Control

@onready var label = $Label
var tween: Tween

func show_notification(text: String, duration: float = 3.0):
	print("NotificationUI: Showing notification for: ", text)
	label.text = text
	self.visible = true # Ensure the Control node is visible
	self.modulate.a = 1.0 # Ensure it's fully visible
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		self.visible = false
		self.modulate.a = 0.0 # Reset alpha for next time
	)

func _ready():
	modulate.a = 0.0
	self.visible = false # Start invisible
