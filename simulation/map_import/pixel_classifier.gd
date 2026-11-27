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

## Darkest white paint can be, and how colourful it may get before it stops being white.
const WHITE_MIN_VALUE: int = 190
const WHITE_MAX_SATURATION: float = 0.25

## Yellow paint: bright red and green channels, with much less blue.
const YELLOW_MIN_RED: int = 170
const YELLOW_MIN_GREEN: int = 140
const YELLOW_MAX_BLUE_SHARE: float = 0.6


## Returns a mask with every pixel of [param image] that is of the given [param kind].
static func mask(image: Image, kind: Kind) -> BitMap:
	var pixels: Image = image
	if pixels.get_format() != Image.FORMAT_RGBA8:
		pixels = image.duplicate() as Image
		pixels.convert(Image.FORMAT_RGBA8)
	var width: int = pixels.get_width()
	var data: PackedByteArray = pixels.get_data()
	var result: BitMap = BitMap.new()
	result.create(pixels.get_size())
	for y: int in pixels.get_height():
		for x: int in width:
			var index: int = (y * width + x) * 4
			if matches(kind, data[index], data[index + 1], data[index + 2]):
				result.set_bit(x, y, true)
	return result


## Returns true if a pixel with these colour channels is of the given [param kind].
static func matches(kind: Kind, red: int, green: int, blue: int) -> bool:
	if kind == Kind.SURFACE:
		return is_surface(red, green, blue)
	return is_marking(red, green, blue)


## Returns true for the dull greys of tarmac.
static func is_surface(red: int, green: int, blue: int) -> bool:
	var value: int = maxi(red, maxi(green, blue))
	if value < SURFACE_MIN_VALUE or value > SURFACE_MAX_VALUE:
		return false
	return _saturation(red, green, blue) <= SURFACE_MAX_SATURATION


## Returns true for white or yellow road paint.
static func is_marking(red: int, green: int, blue: int) -> bool:
	var value: int = maxi(red, maxi(green, blue))
	var is_white: bool = (
		value >= WHITE_MIN_VALUE and _saturation(red, green, blue) <= WHITE_MAX_SATURATION
	)
	var is_yellow: bool = (
		red >= YELLOW_MIN_RED and green >= YELLOW_MIN_GREEN and blue <= red * YELLOW_MAX_BLUE_SHARE
	)
	return is_white or is_yellow


static func _saturation(red: int, green: int, blue: int) -> float:
	var value: int = maxi(red, maxi(green, blue))
	if value == 0:
		return 0.0
	return float(value - mini(red, mini(green, blue))) / value
