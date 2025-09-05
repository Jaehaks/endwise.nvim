local M = {}

M.setup = function(opts)
	require("smart_cr.config").set(opts)
	require('smart_cr.bracket').update_bracket_rules()
	require('smart_cr.endwise').update_endwise_rules()
end

M.config = setmetatable({}, {
	__index = function(_, k)
		return require('smart_cr.config')[k]
	end
})

M.bracket = setmetatable({}, {
	__index = function(_, k)
		return require('smart_cr.bracket')[k]
	end
})

M.endwise = setmetatable({}, {
	__index = function(_, k)
		return require('smart_cr.endwise')[k]
	end
})

return M
