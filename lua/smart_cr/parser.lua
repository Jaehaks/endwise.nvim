local M = {}
-- check current node under cursor is target_node
---@param targets string|table target node to check this region under cursor is the node
--- @return TSNode? Object of treesitter tree
M.is_node = function(targets)
	-- make type of targets to table
	if type(targets) == 'string' then
		targets = { targets }
	end

	local snode = vim.treesitter.get_node({ignore_injections = false})
	while snode do
		local node_name = snode:type()
		if vim.tbl_contains(targets, node_name) then
			return snode
		end
		snode = snode:parent()
	end

	return nil
end


---@return boolean Whether cursor is in brackets
M.is_brackets = function(bracket_pairs)
	local text = vim.api.nvim_get_current_line()  -- all text that includes '\t' or ' ' indent of current line
	local col = vim.api.nvim_win_get_cursor(0)[2] -- (row, col-1) index

	-- Check the characters before and after the cursor
	local before = text:sub(1, col)      -- get string before cursor
	local after = text:sub(col+1, #text) -- get string after cursor

	-- get bracket pattern to match
	local open_pattern = ''
	local close_pattern = ''
	for open, close in pairs(bracket_pairs) do
		open_pattern = open_pattern .. vim.pesc(open)
		close_pattern = close_pattern .. vim.pesc(close)
	end
	open_pattern = '([' .. open_pattern .. '])'
	close_pattern = '([' .. close_pattern .. '])'

	local before_bracket = before:match('.*' .. open_pattern) -- matched before bracket which is closed to cursor
	local after_bracket = after:match(close_pattern) -- matched after bracket which is closed to cursor

	-- Check open and closed parentheses pairs
	if before_bracket and after_bracket and after_bracket == bracket_pairs[before_bracket] then
		return true
	end

	return false
end






return M







