extends Node

signal save_written(slot: String)
signal save_loaded(slot: String)
signal save_failed(slot: String, message: String)

const SCHEMA_VERSION := 1
const CONTENT_VERSION := "ch01-slice7"
const SAVE_DIRECTORY := "user://saves"
const AUTO_SLOT := "autosave"
const MANUAL_SLOTS := ["manual_1", "manual_2", "manual_3"]


func is_valid_slot(slot: String) -> bool:
	return slot == AUTO_SLOT or MANUAL_SLOTS.has(slot)


func has_slot(slot: String) -> bool:
	return is_valid_slot(slot) and FileAccess.file_exists(_slot_path(slot))


func save_slot(slot: String) -> bool:
	if not is_valid_slot(slot):
		save_failed.emit(slot, "Unknown save slot.")
		return false

	var state := get_node_or_null("/root/GameState")
	if state == null:
		save_failed.emit(slot, "GameState is unavailable.")
		return false

	var router := get_node_or_null("/root/SceneRouter")
	if router != null and router.has_method("sync_current_room_state"):
		router.call("sync_current_room_state")

	var document := build_document(state.call("to_serializable_state"))
	var ok := write_document_to_path(_slot_path(slot), document)
	if ok:
		save_written.emit(slot)
	else:
		save_failed.emit(slot, "Could not write save data.")
	return ok


func auto_save() -> bool:
	return save_slot(AUTO_SLOT)


func load_slot(slot: String) -> bool:
	if not is_valid_slot(slot):
		save_failed.emit(slot, "Unknown save slot.")
		return false

	var result := read_document_from_path(_slot_path(slot))
	if not bool(result.get("ok", false)):
		save_failed.emit(slot, String(result.get("error", "Could not read save data.")))
		return false

	var state := get_node_or_null("/root/GameState")
	if state == null:
		save_failed.emit(slot, "GameState is unavailable.")
		return false

	var document: Dictionary = result["document"]
	if not bool(state.call("apply_serializable_state", document["state"])):
		save_failed.emit(slot, "Save state is invalid.")
		return false

	var router := get_node_or_null("/root/SceneRouter")
	if router != null and router.has_method("restore_from_state"):
		if not bool(router.call("restore_from_state")):
			save_failed.emit(slot, "Saved room could not be restored.")
			return false

	save_loaded.emit(slot)
	return true


func build_document(state: Dictionary) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"content_version": CONTENT_VERSION,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"state": state.duplicate(true),
	}


func encode_document(document: Dictionary) -> String:
	return JSON.stringify(document)


func decode_document(raw_text: String) -> Dictionary:
	var json := JSON.new()
	var parse_error := json.parse(raw_text)
	if parse_error != OK or not json.data is Dictionary:
		return {"ok": false, "error": "Save file is not valid JSON data."}
	return validate_and_migrate(json.data)


func validate_and_migrate(raw_document: Dictionary) -> Dictionary:
	var document := raw_document.duplicate(true)
	if not document.has("schema_version"):
		return {"ok": false, "error": "Save schema version is missing."}

	var schema_version := int(document["schema_version"])
	if schema_version < 0:
		return {"ok": false, "error": "Save schema version is invalid."}
	if schema_version > SCHEMA_VERSION:
		return {"ok": false, "error": "Save was created by a newer game version."}

	while schema_version < SCHEMA_VERSION:
		if schema_version == 0:
			document = _migrate_v0_to_v1(document)
			schema_version = 1
		else:
			return {"ok": false, "error": "No migration path exists for this save."}

	if not document.has("state") or not document["state"] is Dictionary:
		return {"ok": false, "error": "Save state payload is missing."}

	document["schema_version"] = SCHEMA_VERSION
	if not document.has("content_version"):
		document["content_version"] = "unknown"
	if not document.has("saved_at_unix"):
		document["saved_at_unix"] = 0

	return {"ok": true, "document": document}


func write_document_to_path(path: String, document: Dictionary) -> bool:
	var base_dir := path.get_base_dir()
	if not base_dir.is_empty():
		var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_dir))
		if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
			return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(encode_document(document))
	file.flush()
	file.close()
	return true


func read_document_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "No save exists in this slot."}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "Save file could not be opened."}

	var raw_text := file.get_as_text()
	file.close()
	return decode_document(raw_text)


func delete_slot(slot: String) -> bool:
	if not is_valid_slot(slot):
		return false
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK


func _slot_path(slot: String) -> String:
	return "%s/%s.json" % [SAVE_DIRECTORY, slot]


func _migrate_v0_to_v1(document: Dictionary) -> Dictionary:
	var legacy_state: Dictionary = {}
	if document.get("state", {}) is Dictionary:
		legacy_state = (document.get("state", {}) as Dictionary).duplicate(true)

	if legacy_state.has("room") and not legacy_state.has("current_room_path"):
		legacy_state["current_room_path"] = legacy_state["room"]
	if legacy_state.has("room_id") and not legacy_state.has("current_room_id"):
		legacy_state["current_room_id"] = legacy_state["room_id"]
	if legacy_state.has("player_foot") and not legacy_state.has("current_player_foot"):
		legacy_state["current_player_foot"] = legacy_state["player_foot"]
	if legacy_state.has("flags") and not legacy_state.has("chapter_flags"):
		legacy_state["chapter_flags"] = legacy_state["flags"]

	legacy_state.erase("room")
	legacy_state.erase("room_id")
	legacy_state.erase("player_foot")
	legacy_state.erase("flags")

	return {
		"schema_version": 1,
		"content_version": String(document.get("content_version", "legacy")),
		"saved_at_unix": int(document.get("saved_at_unix", 0)),
		"state": legacy_state,
	}
