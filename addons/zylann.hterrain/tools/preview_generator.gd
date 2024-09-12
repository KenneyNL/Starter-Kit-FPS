@tool
extends EditorResourcePreviewGenerator

const HTerrainData = preload("../hterrain_data.gd")
const HT_Errors = preload("../util/errors.gd")
const HT_Logger = preload("../util/logger.gd")

var _logger = HT_Logger.get_for(self)


func _generate(res: Resource, size: Vector2i, metadata: Dictionary) -> Texture2D:
	if res == null or not (res is HTerrainData):
		return null
	var normalmap = res.get_image(HTerrainData.CHANNEL_NORMAL)
	if normalmap == null:
		return null
	return _generate_internal(normalmap, size)


func _generate_from_path(path: String, size: Vector2i, metadata: Dictionary) -> Texture2D:
	if not path.ends_with("." + HTerrainData.META_EXTENSION):
		return null
	var data_dir := path.get_base_dir()
	var normals_fname := str(HTerrainData.get_channel_name(HTerrainData.CHANNEL_NORMAL), ".png")
	var normals_path := data_dir.path_join(normals_fname)
	var normals := Image.new()
	var err := normals.load(normals_path)
	if err != OK:
		_logger.error("Could not load '{0}', error {1}" \
			.format([normals_path, HT_Errors.get_message(err)]))
		return null
	return _generate_internal(normals, size)


func _handles(type: String) -> bool:
	return type == "Resource"


static func _generate_internal(normals: Image, size: Vector2) -> Texture2D:
	var im := Image.create(size.x, size.y, false, Image.FORMAT_RGB8)

	var light_dir := Vector3(-1, -0.5, -1).normalized()

	for y in im.get_height():
		for x in im.get_width():

			var fx := float(x) / float(im.get_width())
			var fy := float(im.get_height() - y - 1) / float(im.get_height())
			var mx := int(fx * normals.get_width())
			var my := int(fy * normals.get_height())

			var n := _decode_normal(normals.get_pixel(mx, my))

			var ndot := -n.dot(light_dir)
			var gs := clampf(0.5 * ndot + 0.5, 0.0, 1.0)
			var col := Color(gs, gs, gs, 1.0)

			im.set_pixel(x, y, col)

	var tex := ImageTexture.create_from_image(im)
	return tex


static func _decode_normal(c: Color) -> Vector3:
	return Vector3(2.0 * c.r - 1.0, 2.0 * c.b - 1.0, 2.0 * c.g - 1.0)
