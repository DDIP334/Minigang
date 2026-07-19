extends Button

func _ready():
	print("Button Ready")

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Button got mouse input")

func _pressed():
	print("Pressed!")
