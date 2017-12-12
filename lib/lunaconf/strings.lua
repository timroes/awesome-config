local strings = {}

function strings.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function strings.trim_start(str)
	return str:gsub("^%s*(.-)$", "%1")
end

function strings.starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

--- Pads the specified string to the given length with the given char from the left
function strings.lpad(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

return strings
