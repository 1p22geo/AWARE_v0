extends CanvasLayer

var _dismissed := false

func _ready() -> void:
	layer = 90
	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.02, 0.05, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_bottom", 60)
	margin.add_theme_constant_override("margin_left", 120)
	margin.add_theme_constant_override("margin_right", 120)
	overlay.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	margin.add_child(vbox)

	# --- Title ---
	var title := Label.new()
	title.text = "A.W.A.R.E."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Prototype — Testing Instructions"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	vbox.add_child(subtitle)

	_add_spacer(vbox, 8)

	# --- Objective ---
	var obj_title := _make_heading("OBJECTIVE")
	vbox.add_child(obj_title)

	var obj_text := _make_body(
		"Explore the map and collect 2 components.\n" +
		"Once both are collected, a glowing pink door will appear near the pink cube at the end of the map.\n" +
		"Walk through the door to complete the level."
	)
	vbox.add_child(obj_text)

	_add_spacer(vbox, 4)

	# --- Controls ---
	var ctrl_title := _make_heading("CONTROLS")
	vbox.add_child(ctrl_title)

	var controls_center := HBoxContainer.new()
	controls_center.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(controls_center)

	var controls_grid := GridContainer.new()
	controls_grid.columns = 2
	controls_grid.add_theme_constant_override("h_separation", 32)
	controls_grid.add_theme_constant_override("v_separation", 8)
	controls_center.add_child(controls_grid)

	_add_key_row(controls_grid, "W A S D", "Move")
	_add_key_row(controls_grid, "SPACE", "Jump")
	_add_key_row(controls_grid, "LMB", "Attack (requires Laser Cannon)")
	_add_key_row(controls_grid, "E", "Open / Close Inventory")
	_add_key_row(controls_grid, "SCROLL", "Navigate UI screens")
	_add_key_row(controls_grid, "ESC", "Pause")
	_add_key_row(controls_grid, "TAB", "Toggle Map")

	_add_spacer(vbox, 4)

	# --- Tips ---
	var tips_title := _make_heading("TIPS")
	vbox.add_child(tips_title)

	var tips := _make_body(
		"• Components give stat bonuses (HP, Armor, Speed, Damage, etc.).\n" +
		"• Open Inventory [E] to see collected components and your component graph.\n" +
		"• Scroll through the UI to view Stats, Codex, and more.\n" +
		"• Falling off the map deals damage and teleports you back.\n" +
		"• Enemies patrol the map — avoid or fight them."
	)
	vbox.add_child(tips)

	_add_spacer(vbox, 16)

	# --- Dismiss hint ---
	var hint := Label.new()
	hint.text = "[ Press any key to start ]"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(1, 0.4, 0.7))
	vbox.add_child(hint)

	# Pulse the hint
	var t := create_tween().set_loops()
	t.tween_property(hint, "modulate:a", 0.3, 0.8)
	t.tween_property(hint, "modulate:a", 1.0, 0.8)

	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if _dismissed:
		return
	if event.is_pressed() and not event.is_echo():
		_dismiss()

func _dismiss() -> void:
	_dismissed = true
	get_tree().paused = false
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(get_child(0), "modulate:a", 0.0, 0.3)
	t.tween_callback(queue_free)

# --- helpers ---

func _make_heading(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 26)
	l.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
	return l

func _make_body(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color(0.82, 0.84, 0.88))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _add_key_row(grid: GridContainer, key: String, action: String) -> void:
	var k := Label.new()
	k.text = "[ " + key + " ]"
	k.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	k.add_theme_font_size_override("font_size", 18)
	k.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	grid.add_child(k)

	var a := Label.new()
	a.text = action
	a.add_theme_font_size_override("font_size", 18)
	a.add_theme_color_override("font_color", Color(0.82, 0.84, 0.88))
	grid.add_child(a)

func _add_spacer(parent: Control, height: float) -> void:
	var s := Control.new()
	s.custom_minimum_size.y = height
	parent.add_child(s)
