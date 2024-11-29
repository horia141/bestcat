class_name GameButton
extends TextureButton

@export var max_width: bool = false
@export var label: String = "Say Something":
	set (new_label):
		label = new_label
		__setup_everything(new_label, font_size)
@export var font_size: int = 20:
	set (new_font_size):
		font_size = new_font_size
		__setup_everything(label, new_font_size)

#region Construction

func _ready() -> void:
	__setup_everything(label, font_size)
	
#endregion

#region Game events

func _process(delta: float) -> void:
	__setup_everything(label, font_size)
		
func __setup_everything(new_label: String, new_font_size: int) -> void:
	if not has_node("Label"):
		return
	var font: Font = $Label.get_theme_font("font")
	$Label.text = new_label.substr(0, 12) if max_width else new_label
	$Label.add_theme_font_size_override("font_size", new_font_size)
	var the_size = font.get_multiline_string_size(label)
	the_size.x = min(200, the_size.x) if max_width else the_size.x
	$Label.size = the_size
	custom_minimum_size = $Label.size + Vector2(new_font_size, new_font_size)
	$Label.position = (size - $Label.size) / 2

#endregion
