local M = {}

-- Create an indented white spaces, if 8, 8 spaces if expandtab, or 2 tabs if notexpandtab with 4 shift-width
---@param level integer the number of spaces to set indent before text
---@return string string includes indented characters
M.create_indent = function(level)
	local indent_char = vim.bo.expandtab and ' ' or '\t'
	local indent_size = vim.bo.expandtab and level or level/vim.bo.shiftwidth
	return string.rep(indent_char, indent_size)
end

-- get information under cursor
---@return smart_cr.ctx
M.get_cursorinfo = function ()
	-- get cursor / indent information
	local lnum, col         = unpack(vim.api.nvim_win_get_cursor(0))
	local prev_indent_count = vim.fn.indent(lnum)
	local prev_indent       = M.create_indent(prev_indent_count)
	local cur_indent_count  = prev_indent_count + vim.bo.shiftwidth
	local cur_indent        = M.create_indent(cur_indent_count)

	-- split text before/after cursor
	local line   = vim.api.nvim_get_current_line()
	local before = line:sub(1, col) -- get string after cursor
	local after  = line:sub(col+1) -- get string after cursor

	---@class smart_cr.ctx
	---@field lnum number line number 0-index
	---@field col number col number 0-index
	---@field prev_indent_count number number of spaces of indent under cursor line before <CR>
	---@field prev_indent string characters to represent indentation
	---@field cur_indent_count number number of spaces of indent under cursor line after <CR>
	---@field cur_indent string characters to represent indentation
	---@field line string contents of the line under cursor
	---@field before string contents of the line before cursor
	---@field after string contents of the line after cursor
	return {
		lnum              = lnum,
		col               = col,
		prev_indent_count = prev_indent_count,
		prev_indent       = prev_indent,
		cur_indent_count  = cur_indent_count,
		cur_indent        = cur_indent,
		line              = line,
		before            = before,
		after             = after,
	}
end

return M
