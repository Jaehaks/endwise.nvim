local M = {}
local config = require('smart_cr.config').get()

M.debug_print = function(str)
	if config.debug then
		vim.print(str)
	end
end

return M
