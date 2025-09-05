local M = {}

-- check current node under cursor is target_node
---@param targets table target node to check this region under cursor is the node
---@return TSNode? Object of treesitter tree
M.is_node = function(targets)
	-- use get_parser():parse() to update treesitter result manually.
	local parser = vim.treesitter.get_parser()
	if not parser then -- if treesitter is not existed in this language
		return nil
	end
	parser:parse() -- update parse

	-- get current node
	local snode = vim.treesitter.get_node({ignore_injections = false})
	if not snode then
		return nil
	end

	-- get current cursor position
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[1] = cursor[1] - 1

	-- check current node is worth checking,
	-- if line is not start node, don't add endwise, like comment / comment block / wrong endwise
	local start_row = snode:range()
	if start_row ~= cursor[1] then
		return nil
	end

	if vim.tbl_contains(targets, snode:type()) then
		return snode
	end

	return nil
end

---@param snode TSNode start node
---@param endword string rule.endword
---@param endwordlist EndwordList endword list of current filetype
---@return string? endword of snode
M.is_endwised = function(snode, endword, endwordlist)

	local range_snode = {snode:range()}

	-- add endword for ERROR node
	local _endwordlist = endwordlist
	_endwordlist['ERROR'] = endword

	-- check current node has wrong end
	local pnode = snode:parent()
	while pnode do
		-- if endword is not existed
		local endword_snode = vim.treesitter.get_node_text(snode, 0)
		local has_endword = vim.endswith(endword_snode, endword) -- don't use word from vim.inspect
		if not has_endword then
			return endword
		end

		if _endwordlist[pnode:type()] then
			local range_pnode = {pnode:range()}

			vim.print('(snode)' .. snode:type() .. ' : ' .. '{' .. range_snode[1] .. ' ' .. range_snode[2] .. ' ' .. range_snode[3] .. ' ' .. range_snode[4] .. '}')
			-- vim.print('(snode) : ' .. vim.inspect(vim.treesitter.get_node_text(snode, 0)))
			vim.print('(snode) : ' .. tostring(snode:end_()))
			vim.print('(pnode)' .. pnode:type() .. ' : ' .. '{' .. range_pnode[1] .. ' ' .. range_pnode[2] .. ' ' .. range_pnode[3] .. ' ' .. range_pnode[4] .. '}')
			-- vim.print('(pnode) : ' .. vim.inspect(vim.treesitter.get_node_text(pnode, 0)))
			vim.print('(pnode) : ' .. tostring(pnode:end_()))

			if (range_pnode[3] == range_snode[3]) then -- if two node has same row at end
				return endword
			end
			snode = pnode
		end
		pnode = pnode:parent()
	end

	-- -- get lower node at cursor line
	-- local lower = nil
	-- for child in snode:iter_children() do
	-- 	range = {child:range()}
	-- 	if (range[1] <= cursor[1] and range[3] >= cursor[1]) and
	-- 	   (range[2] <= cursor[2] and range[4] >= cursor[2]) then
	--
	-- 	   -- vim.print(child:type() .. ' ' .. cursor[1] .. ' ' .. cursor[2])
	-- 	   --
	-- 	   lower = child
	-- 	   break
	--    end
	-- end

	return nil
end

-- check the cursor is inside of brackets
---@param ctx smart_cr.ctx
---@param bracket_pairs table<string, string> check smart_cr.config.bracket_cr
---@return boolean Whether cursor is in brackets
M.is_brackets = function(ctx, bracket_pairs)

	-- get bracket pattern to match
	local open_pattern = ''
	local close_pattern = ''
	for open, close in pairs(bracket_pairs) do
		open_pattern = open_pattern .. vim.pesc(open)
		close_pattern = close_pattern .. vim.pesc(close)
	end
	open_pattern = '([' .. open_pattern .. '])%s*$'
	close_pattern = '^%s*([' .. close_pattern .. '])'

	local before_bracket = ctx.before:match('.*' .. open_pattern) -- matched before bracket which is closed to cursor
	local after_bracket = ctx.after:match(close_pattern) -- matched after bracket which is closed to cursor

	-- Check open and closed parentheses pairs
	if before_bracket and after_bracket and after_bracket == bracket_pairs[before_bracket] then
		return true
	end

	return false
end






return M







