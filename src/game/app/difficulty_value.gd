class_name DifficultyValue
extends RefCounted

var for_novice: float
var for_apprentice: float
var for_expert: float
	
func _init(for_novice: float, for_apprentice: float, for_expert: float) -> void:
	self.for_novice = for_novice
	self.for_apprentice = for_apprentice
	self.for_expert = for_expert
		
func get_for(difficulty: Application.MissionDifficulty) -> float:
	match difficulty:
		Application.MissionDifficulty.Novice:
			return for_novice
		Application.MissionDifficulty.Apprentice:
			return for_apprentice
		Application.MissionDifficulty.Expert:
			return for_expert
			
	assert(1 == 0, "Unknown difficulty")
	return for_expert
