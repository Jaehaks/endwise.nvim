local M = {}

-- Create an indented white spaces, if 8, 8 spaces if expandtab, or 2 tabs if notexpandtab with 4 shift-width
---@param level integer the number of spaces to set indent before text
---@return string string includes indented characters
M.create_indent = function(level)
	local indent_char = vim.bo.expandtab and ' ' or '\t'
	local indent_size = vim.bo.expandtab and level or level/vim.bo.shiftwidth
	return string.rep(indent_char, indent_size)
end

return M
