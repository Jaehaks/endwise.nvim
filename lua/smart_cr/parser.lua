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
	-- vim.print(snode:type())
	if not snode then
		return nil
	end

	-- get current cursor position
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[1] = cursor[1] - 1

	-- check current node is worth checking,
	-- if line is not start node, don't add endwise, like comment / comment block / wrong endwise
	-- get root node at where cursor is
	---@type TSNode?
	local pnode = snode
	while pnode do
		local start_row = pnode:range()
		if start_row ~= cursor[1] then
			break
		end
		if vim.tbl_contains(targets, pnode:type()) then
			snode = pnode -- remember if the node is valid to use endwise
			-- some superior node is enclosed by (block)
		end
		pnode = pnode:parent()
	end

	-- vim.print(snode:type())
	-- vim.print({snode:range()})
	if vim.tbl_contains(targets, snode:type()) then
		return snode
	end

	return nil
end

---@param root TSNode
---@param endwordlist EndwordList endword list of current filetype
local function bfs(root, endwordlist)
	local endword = endwordlist['currentnode']
	local queue = {{node = root, depth = 0, parent = ''}} -- start node
	local front = 1 -- bfs using index, no table.remove
	local back = 1

	local endwise_nodes = {}
	local end_rows = {} -- list about line number of end of region
	while front <= back do


		-- go to next node
		local current = queue[front]
		front = front + 1

		-- TODO: what you want to do
		-- consider only endwise node
		if endwordlist[current.node:type()] then

			-- 1) check each node has proper endword
			local endword_snode = vim.treesitter.get_node_text(current.node, 0)
			local has_endword = vim.endswith(endword_snode, endword) -- don't use word from vim.inspect
			if not has_endword then
				-- vim.print('-----------------------------' .. current.node:type() .. ' not has endword')
				return endword
			end

			-- 2) check node's end row is duplicated
			local end_row = current.node:end_()
			if vim.tbl_contains(end_rows, end_row) then
				-- vim.print('----------------------------- duplicated end row')
				return endword
			end
			table.insert(end_rows, end_row)
			table.insert(endwise_nodes, current.node)

			-- check
			-- local range = {current.node:range()}
			-- vim.print('[' .. current.depth .. '-' .. current.parent .. ']  ' .. current.node:type() .. ' -- ' .. range[1] .. ' ' .. range[3] .. '//' .. tostring(current.node:named()) .. '//' .. tostring(has_endword))
		end

		-- add only node, not field. (ex, class_definition(O), classdef(X) )
		for _, child in ipairs(current.node:named_children()) do
			back = back+1
			queue[back] = {node = child, depth = current.depth + 1, parent = current.node:type()}
		end
	end

	return nil
end



---@param snode TSNode start node
---@param endwordlist EndwordList endword list of current filetype
---@return string? endword of snode
M.is_endwised = function(snode, endwordlist)

	-- add endword for ERROR node
	local _endwordlist = endwordlist
	_endwordlist['ERROR'] = _endwordlist['currentnode']

	-- get root node which has endwise structure from cursor region
	---@type TSNode?
	local pnode, root = snode, snode
	while pnode do
		if _endwordlist[pnode:type()] then
			root = pnode
		end
		pnode = pnode:parent()
	end
	-- vim.print('root -- ' .. root:type())

	-- check all children nodes have wrong end
	local endword = bfs(root, _endwordlist)
	-- vim.print('result is --' .. tostring(endword))

	-- check current node has wrong end
	-- pnode = snode:parent()
	-- while pnode do
	-- 	-- if endword is not existed
	-- 	local endword_snode = vim.treesitter.get_node_text(snode, 0)
	-- 	local has_endword = vim.endswith(endword_snode, endword) -- don't use word from vim.inspect
	-- 	if not has_endword then
	-- 		return endword
	-- 	end
	--
	-- 	if _endwordlist[pnode:type()] then
	-- 		local range_pnode = {pnode:range()}
	--
	-- 		vim.print('(snode)' .. snode:type() .. ' : ' .. '{' .. range_snode[1] .. ' ' .. range_snode[2] .. ' ' .. range_snode[3] .. ' ' .. range_snode[4] .. '}')
	-- 		-- vim.print('(snode) : ' .. vim.inspect(vim.treesitter.get_node_text(snode, 0)))
	-- 		vim.print('(snode) : ' .. tostring(snode:end_()))
	-- 		vim.print('(pnode)' .. pnode:type() .. ' : ' .. '{' .. range_pnode[1] .. ' ' .. range_pnode[2] .. ' ' .. range_pnode[3] .. ' ' .. range_pnode[4] .. '}')
	-- 		-- vim.print('(pnode) : ' .. vim.inspect(vim.treesitter.get_node_text(pnode, 0)))
	-- 		vim.print('(pnode) : ' .. tostring(pnode:end_()))
	--
	-- 		if (range_pnode[3] == range_snode[3]) then -- if two node has same row at end
	-- 			return endword
	-- 		end
	-- 		snode = pnode
	-- 	end
	-- 	pnode = pnode:parent()
	-- end

	return endword
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
