local strings = {}

function strings.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function strings.trim_start(str)
	return str:gsub("^%s*(.-)$", "%1")
end

function strings.split(str, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function strings.starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

return strings
