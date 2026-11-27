class_name PixelClassifier
extends RefCounted
## Sorts the pixels of a junction screenshot into tarmac and painted markings.
##
## Tuned for aerial photos, where roads are grey tarmac and lanes are marked
## in white or yellow paint. Colour channels are compared as 0-255 integers.

enum Kind { SURFACE, MARKING }

## Darkest and brightest a pixel can be and still count as tarmac.
const SURFACE_MIN_VALUE: int = 30
const SURFACE_MAX_VALUE: int = 170
## Most colourful tarmac can be: the spread between channels as a share of the brightest.
const SURFACE_MAX_SATURATION: float = 0.2

## White paint is judged against its surroundings, so worn lines still count:
## it must be this much brighter than the average of the area around it.
const WHITE_MIN_CONTRAST: int = 40
## Darkest white paint can be, however dark its surroundings, and how colourful
## it may get before it stops being white.
const WHITE_MIN_VALUE: int = 110
const WHITE_MAX_SATURATION: float = 0.25
## Width of the square the surrounding brightness is averaged over, in pixels.
const BACKGROUND_BLOCK: int = 8

## Yellow paint: bright red and green channels, with much less blue.
const YELLOW_MIN_RED: int = 170
const YELLOW_MIN_GREEN: int = 140
const YELLOW_MAX_BLUE_SHARE: float = 0.6


## Returns a mask with every pixel of [param image] that is of the given [param kind].
static func mask(image: Image, kind: Kind) -> BitMap:
	var pixels: Image = _as_rgba8(image)
	var width: int = pixels.get_width()
	var data: PackedByteArray = pixels.get_data()
	var background: PackedByteArray = PackedByteArray()
	if kind == Kind.MARKING:
		background = background_brightness(pixels)
	var result: BitMap = BitMap.new()
	result.create(pixels.get_size())
	for y: int in pixels.get_height():
		for x: int in width:
			var pixel: int = y * width + x
			var index: int = pixel * 4
			var red: int = data[index]
			var green: int = data[index + 1]
			var blue: int = data[index + 2]
			var found: bool = (
				is_surface(red, green, blue)
				if kind == Kind.SURFACE
				else is_marking(red, green, blue, background[pixel])
			)
			if found:
				result.set_bit(x, y, true)
	return result


## Returns true for the dull greys of tarmac.
static func is_surface(red: int, green: int, blue: int) -> bool:
	var value: int = maxi(red, maxi(green, blue))
	if value < SURFACE_MIN_VALUE or value > SURFACE_MAX_VALUE:
		return false
	return _saturation(red, green, blue) <= SURFACE_MAX_SATURATION


## Returns true for white or yellow road paint, given the average
## [param background] brightness of the area around the pixel.
static func is_marking(red: int, green: int, blue: int, background: int) -> bool:
	var value: int = maxi(red, maxi(green, blue))
	var is_white: bool = (
		value >= WHITE_MIN_VALUE
		and value >= background + WHITE_MIN_CONTRAST
		and _saturation(red, green, blue) <= WHITE_MAX_SATURATION
	)
	var is_yellow: bool = (
		red >= YELLOW_MIN_RED and green >= YELLOW_MIN_GREEN and blue <= red * YELLOW_MAX_BLUE_SHARE
	)
	return is_white or is_yellow


## Returns the average brightness around each pixel of [param pixels], one byte
## per pixel, from a blurred copy of the image.
static func background_brightness(pixels: Image) -> PackedByteArray:
	var blurred: Image = pixels.duplicate() as Image
	var size: Vector2i = pixels.get_size()
	var reduced: Vector2i = (size / BACKGROUND_BLOCK).max(Vector2i.ONE)
	blurred.resize(reduced.x, reduced.y, Image.INTERPOLATE_TRILINEAR)
	blurred.resize(size.x, size.y, Image.INTERPOLATE_BILINEAR)
	blurred.convert(Image.FORMAT_L8)
	return blurred.get_data()


static func _as_rgba8(image: Image) -> Image:
	if image.get_format() == Image.FORMAT_RGBA8:
		return image
	var copy: Image = image.duplicate() as Image
	copy.convert(Image.FORMAT_RGBA8)
	return copy


static func _saturation(red: int, green: int, blue: int) -> float:
	var value: int = maxi(red, maxi(green, blue))
	if value == 0:
		return 0.0
	return float(value - mini(red, mini(green, blue))) / value
