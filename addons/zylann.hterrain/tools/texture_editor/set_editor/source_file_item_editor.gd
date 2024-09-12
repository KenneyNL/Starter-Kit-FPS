@tool
extends Control

# TODO Can't preload because it causes the plugin to fail loading if assets aren't imported
#const HT_EmptyTexture = preload("../../icons/empty.png")
const EMPTY_TEXTURE_PATH = "res://addons/zylann.hterrain/tools/icons/empty.png"

signal load_pressed
signal clear_pressed


@onready var _label : Label = $Label
@onready var _texture_rect : TextureRect = $TextureRect

@onready var _buttons = [
	$LoadButton,
	$ClearButton
]

var _material : Material
var _is_empty := true


func set_label(text: String):
	_label.text = text


func set_texture(tex: Texture):
	if tex == null:
		_texture_rect.texture = load(EMPTY_TEXTURE_PATH)
		_texture_rect.material = null
		_is_empty = true
	else:
		_texture_rect.texture = tex
		_texture_rect.material = _material
		_is_empty = false


func set_texture_tooltip(msg: String):
	_texture_rect.tooltip_text = msg


func _on_LoadButton_pressed():
	load_pressed.emit()


func _on_ClearButton_pressed():
	clear_pressed.emit()


func set_material(mat: Material):
	_material = mat
	if not _is_empty:
		_texture_rect.material = _material


func set_enabled(enabled: bool):
	for b in _buttons:
		b.disabled = not enabled

