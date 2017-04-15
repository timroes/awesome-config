local lfs = require('lfs')

-- Split strings
function split(str, sep)
	local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
