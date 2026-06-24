class_name StaticUtility

class ExpressionContext:
	var dict : Dictionary = {}

	func val(key : String):
		if !dict.has(key):
			return null
		return dict[key]

	func _init(initial_dictionary : Dictionary):
		dict = initial_dictionary

static func lerp_dampen(a : Variant, b : Variant, lambda : float, delta_time : float) -> Variant:
	return lerp(a, b, 1 - exp(-lambda * delta_time))

static func sample_sigmoid(x : float) -> float:
	return 1.0 / (1.0 + exp(-x))

static func sample_sigmoid_zero_one(x : float) -> float:
	return sample_sigmoid(x) * 2 - 1

static func rotate_towards(current : Vector3, target : Vector3, rotation_speed : float) -> Vector3:
	var cur_norm = current.normalized()
	var tar_norm = target.normalized()

	var cross = cur_norm.cross(tar_norm).normalized()
	var dot = cur_norm.dot(tar_norm)

	if cross.length() == 0.0:
		return current

	var angle = clamp(acos(dot), -rotation_speed, rotation_speed)

	return current.rotated(cross, angle) #Notice, this does not change the length of the vector

static func set_node_array_process_mode(node_array : Array[Node], new_process_mode) -> void:
	for node in node_array:
		node.process_mode = new_process_mode

static func get_all_file_paths(path: String) -> Array[String]: #Got this somewhere from reddit, idk how well this works
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths

static func merge_arrays(merge_left : Array, merge_right : Array) -> Array:
	var merged_array : Array = merge_left.duplicate()
	for element in merge_right:
		if !merged_array.has(element):
			merged_array.append(element)
	return merged_array

static func get_dict_value_if_present(dict : Dictionary, key : String) -> Variant:
	if dict.has(key):
		return dict[key]
	else:
		return null

static func expression_on_dict(dict : Dictionary, expression_string : String, show_error : bool = false) -> Variant:
	var expression := Expression.new()
	var expression_context := ExpressionContext.new(dict)
	var error := expression.parse(expression_string)

	if error != OK:
		push_error("Error parsing expression: " + expression_string)
		return null

	var result = expression.execute([], expression_context, show_error)

	if expression.has_execute_failed():
		return null

	return result