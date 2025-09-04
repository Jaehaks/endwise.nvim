local M = {}

---@class smart_cr.config.bracket_cr
---@field enabled boolean
---@field bracket_pairs table<string, string>

-- default configuration
---@class smart_cr.config
---@field bracket_cr smart_cr.config.bracket_cr
local default_config = {
	bracket_cr = {
		enabled = true,
		bracket_pairs = {
			['('] = ')',
			['['] = ']',
			['{'] = '}',
			['<'] = '>',
		}
	}
}

local config = vim.deepcopy(default_config)

-- get configuration
M.get = function ()
	return config
end

-- set configuration
M.set = function (opts)
	config = vim.tbl_deep_extend('force', default_config, opts or {})
end


return M
