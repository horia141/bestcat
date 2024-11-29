class_name PlayerWeapon
extends Sprite2D

var mode = Application.ConceptMode.InGame

#region Construction

func post_ready_prepare(mode: Application.ConceptMode) -> void:
	self.mode = mode

#endregion
