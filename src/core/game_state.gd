extends Node

signal component_collected(total: int)
signal level_completed

const REQUIRED_COMPONENTS := 2

var collected_components: int = 0

func collect_component() -> void:
	collected_components += 1
	component_collected.emit(collected_components)

func has_enough_components() -> bool:
	return collected_components >= REQUIRED_COMPONENTS

func complete_level() -> void:
	level_completed.emit()

func reset() -> void:
	collected_components = 0
