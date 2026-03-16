extends Node

const tile_prefab = preload("res://scenes/components/tile.tscn")

var tiles = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in range(-10, 10):
		tiles.append([])
		for m in range(-10, 10):
			var tile: Tile = tile_prefab.instantiate()
			
			tile.position.x = 2*m 
			tile.position.z = 2*n 
			
			tiles[-1].append(tile)
			add_child(tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
