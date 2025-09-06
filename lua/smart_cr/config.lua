local M = {}

---@class smart_cr.config
---@field bracket_cr smart_cr.config.bracket_cr
---@field endwise_cr smart_cr.config.endwise_cr

---@class smart_cr.config.bracket_cr
---@field enabled boolean
---@field bracket_pairs table<string, string>

---@class smart_cr.config.endwise_cr
---@field enabled boolean on/off this function
---@field rules EndwiseRules

---@class EndwiseRules
---@field [string] EndwiseRule[]

---@class EndwiseRule
---@field [1] string pattern
---@field [2] string endword
---@field [3] string[] TSnode name at cursor

-- default configuration
---@type smart_cr.config
local default_config = {
	bracket_cr = {
		enabled = true,
		bracket_pairs = {
			['('] = ')',
			['['] = ']',
			['{'] = '}',
			['<'] = '>',
		}
	},
	endwise_cr = {
		enabled = true,
		rules = {
			lua = {
				-- do_statement can be endwised with 'end' or 'until'. Both case are not supported
				{'then%s*$',                'end', {'if_statement'}},
				{'do%s*$',                  'end', {'for_statement',
													'while_statement',
													'do_statement'}},
				{'function.*%(.*%)%s*$',    'end', {'function_definition',
											  		'local_function',
											  		'function_declaration'}},
			},
			matlab = {
				{'if%s+.+$',             'end', {'ERROR', 'if_statement'}},
				{'while%s+.+$',          'end', {'ERROR', 'while_statement'}},
				{'for%s+.+$',            'end', {'ERROR', 'while_statement'}},
				{'switch.*$',            'end', {'ERROR', 'switch_statement'}},
				{'try.*$',               'end', {'ERROR', 'try_statement'}},
				{'classdef%s+.+$',       'end', {'ERROR', 'class_definition'}},
				{'properties.*$',        'end', {'ERROR', 'properties'}},
				{'methods.*$',           'end', {'ERROR', 'methods'}},
				{'function%s+.*%(.*%)$', 'end', {'ERROR', 'function_definition',
												 'function_declaration',
												 'function_signature'}},
			},
			sh = {
				{'then$', 'fi', {'ERROR', 'if_statement'}},
				{'do$',   'done', {'ERROR', 'while_statement', 'for_statement', 'until_statement'}},
				{'in$',   'esac', {'ERROR', 'case_statement'}},
			},
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
