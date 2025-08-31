local M = {}

M.setup = function(opts)
	require("endwise.config").set(opts)
end

M.config = setmetatable({}, {
	__index = function(_, k)
		return require('endwise.config')[k]
	end
})

return M
