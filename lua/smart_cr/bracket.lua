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
	-- do not any
	if not bracket_cr.enabled or not Parser.is_brackets(bracket_cr.bracket_pairs) then
		return false
	end

	-- get cursor / indent information
	local lnum, col         = unpack(vim.api.nvim_win_get_cursor(0))
	local prev_indent_count = vim.fn.indent(lnum)
	local prev_indent       = Utils.create_indent(prev_indent_count)
	local cur_indent_count  = prev_indent_count + vim.bo.shiftwidth
	local cur_indent        = Utils.create_indent(cur_indent_count)

	-- split text before/after cursor
	local text   = vim.api.nvim_get_current_line()
	local before = text:sub(1, col) -- get string after cursor
	local after  = text:sub(col+1) -- get string after cursor

	-- make close_bracket with new indented line
	-- set 2 line contents to one line range (start, start+1) => insert these line contents
	vim.api.nvim_buf_set_lines(0, lnum-1, lnum, false, {
		before,
		cur_indent,
		prev_indent .. after,
	})
	vim.api.nvim_win_set_cursor(0, {lnum+1, cur_indent_count+1})

	return true
end




return M
