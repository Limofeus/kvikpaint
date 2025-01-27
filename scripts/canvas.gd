extends TextureRect
class_name Canvas

const MAX_UNDO_COUNT = 64

@export var canvas_dragger : CanvasDrag = null

@export var rasterizer_texture : ViewportTexture = null
var canvas_image : Image = null
var canvas_texture : ImageTexture = null

var drawing_line = false

var blur_mask : Image = null
var undo_buffer : Array[Image] = []

func _ready():
	canvas_image = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
	canvas_image.fill(Color.WHITE)
	#canvas_image.generate_mipmaps() #Leave that out until zoom is implemented
	canvas_texture = ImageTexture.create_from_image(canvas_image)
	texture = canvas_texture

	blur_mask = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
	blur_mask.fill(Color(0.1, 0.1, 0.1, 0.1))

func get_canvas_coordinates(point : Vector2):
	return canvas_dragger.get_canvas_coordinates(point)

func clear_canvas():
	save_to_undo_buffer()
	canvas_image.fill(Color.WHITE)
	canvas_texture.update(canvas_image)

func save_to_undo_buffer():
	undo_buffer.append(canvas_image.duplicate())
	if undo_buffer.size() > MAX_UNDO_COUNT:
		undo_buffer.remove_at(0)

func undo_last_draw():
	if undo_buffer.size() > 0:
		canvas_image = undo_buffer.pop_back()
		canvas_texture.update(canvas_image)

func set_image(image : Image):
	canvas_image = image
	canvas_texture.update(canvas_image)

func get_image() -> Image:
	return canvas_image.duplicate()

func apply_buffer(blur_edges : bool = false):
	save_to_undo_buffer()

	var rasterized_image = rasterizer_texture.get_image()
	canvas_image.blend_rect(rasterized_image, Rect2(0, 0, 1600, 900), Vector2i.ZERO) #Change Rect2 dimensions to allow different size images
	#canvas_image.generate_mipmaps()
	if blur_edges:
		pass #Cant find a good solution ;_;
	canvas_texture.update(canvas_image)
