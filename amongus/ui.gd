extends Control

@onready var prompt = $PromptPanel
@onready var task_name = $PromptPanel/MarginContainer/VBoxContainer/TaskNameLabel
@onready var game_manager = $"../../GameManager"

func _ready():
	prompt.hide()

func show_task(task):
	task_name.text = task
	prompt.show()

func hide_task():
	prompt.hide()

func _on_do_task_button_pressed() -> void:
	game_manager.complete_task()
	hide_task()
