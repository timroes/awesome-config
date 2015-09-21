local cairo = {}

function cairo.circle(ctx, x, y, width, height)
	ctx:save()
	ctx:translate(x + width / 2.0, y + height / 2.0)
	ctx:scale(width / 2.0, height / 2.0)
	ctx:arc(0, 0, 1, 0, 2 * math.pi)
	ctx:restore()
end

function cairo.semicircle(ctx, x, y, width, height, rotation)
	ctx:save()
	ctx:translate(x + width / 2.0, y + height / 2.0)
	ctx:scale(width / 2.0, height / 2.0)
	ctx:rotate(rotation)
	ctx:arc(0, 0, 1, 0, math.pi)
	ctx:restore()
end

return cairo