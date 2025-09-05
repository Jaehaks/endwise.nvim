local M = {}
local Config = require('smart_cr.config')
local Parser = require('smart_cr.parser')
local Utils = require('smart_cr.utils')

-- Check if the current cursor position is within the parentheses
---@type smart_cr.config.bracket_cr
local bracket_cr = {}
M.update_bracket_rules = function ()
	bracket_cr = Config.get().bracket_cr
end

--[[
	make bracket
	before => a = {|}
	after  => a = {
				  |
			  }
--]]
-- <CR> with indented cursor / new line
-- it would ignore any indentexpr process of ftplugin
---@return boolean Whether this function is executed
M.bracket_cr = function()
	-- get information under cursor
	local ctx = Utils.get_cursorinfo()

	-- do not any
	if not bracket_cr.enabled or not Parser.is_brackets(ctx, bracket_cr.bracket_pairs) then
		return false
	end

	-- make close_bracket with new indented line
	-- set 2 line contents to one line range (start, start+1) => insert these line contents
	vim.api.nvim_buf_set_lines(0, ctx.lnum-1, ctx.lnum, false, {
		ctx.before,
		ctx.cur_indent,
		ctx.prev_indent .. ctx.after,
	})
	vim.api.nvim_win_set_cursor(0, {ctx.lnum+1, ctx.cur_indent_count+1})

	return true
end




return M
