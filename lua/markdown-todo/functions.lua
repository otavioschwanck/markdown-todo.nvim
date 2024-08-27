local M = {}

local function save()
	vim.cmd("w!")
end

function M.add_todo_line()
	vim.cmd("normal! o- [ ]  ")
	vim.cmd("startinsert")
end

function M.toggle_checkbox()
	local line = vim.api.nvim_get_current_line()

	if string.match(line, "^- %[%s%]") then
		line = string.gsub(line, "^- %[%s%]", "- [x]")
	elseif string.match(line, "^- %[x%]") then
		line = string.gsub(line, "^- %[x%]", "- [?]")
	elseif string.match(line, "^- %[%?%]") then
		line = string.gsub(line, "^- %[%?%]", "- [ ]")
	end

	vim.api.nvim_set_current_line(line)

	save()
end

function M.set_priority_tag(tag)
	local line = vim.api.nvim_get_current_line()

	line = string.gsub(line, "%s%[%#%a+%]$", "")

	line = line .. " [#" .. tag .. "]"

	vim.api.nvim_set_current_line(line)

	save()
end

function M.clear_todos()
	vim.cmd("g/^ *- \\[x\\]/d")

	save()
end

function M.sort_todos_by_priority()
	-- Pega todas as linhas do buffer atual
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Listas para armazenar os blocos de TODOs e outras linhas
	local todo_blocks = {}
	local other_lines = {}
	local current_block = nil

	-- Classificar as linhas em blocos de TODOs e outras linhas
	for _, line in ipairs(lines) do
		if string.match(line, "^- %[.-%]") then
			-- Inicia um novo bloco de TODOs
			if current_block then
				table.insert(todo_blocks, current_block)
			end
			current_block = { line }
		elseif current_block then
			-- Continua adicionando linhas ao bloco atual
			table.insert(current_block, line)
		else
			-- Linhas que não fazem parte de um bloco de TODO
			table.insert(other_lines, line)
		end
	end
	-- Adiciona o último bloco se houver
	if current_block then
		table.insert(todo_blocks, current_block)
	end

	-- Separar os blocos de TODOs por prioridade
	local high_priority = {}
	local medium_priority = {}
	local low_priority = {}
	local no_priority = {}

	for _, block in ipairs(todo_blocks) do
		local first_line = block[1]
		if string.match(first_line, "%[%#high%]$") then
			table.insert(high_priority, block)
		elseif string.match(first_line, "%[%#medium%]$") then
			table.insert(medium_priority, block)
		elseif string.match(first_line, "%[%#low%]$") then
			table.insert(low_priority, block)
		else
			table.insert(no_priority, block)
		end
	end

	-- Combinar os blocos de TODOs ordenados
	local sorted_todo_blocks = {}
	for _, block in ipairs(high_priority) do
		for _, line in ipairs(block) do
			table.insert(sorted_todo_blocks, line)
		end
	end
	for _, block in ipairs(medium_priority) do
		for _, line in ipairs(block) do
			table.insert(sorted_todo_blocks, line)
		end
	end
	for _, block in ipairs(low_priority) do
		for _, line in ipairs(block) do
			table.insert(sorted_todo_blocks, line)
		end
	end
	for _, block in ipairs(no_priority) do
		for _, line in ipairs(block) do
			table.insert(sorted_todo_blocks, line)
		end
	end

	-- Combinar as outras linhas com os TODOs ordenados
	local final_lines = {}
	local todo_index = 1
	local in_todo_block = false

	for _, line in ipairs(lines) do
		if string.match(line, "^- %[.-%]") then
			-- Insere a linha do bloco de TODO na ordem
			table.insert(final_lines, sorted_todo_blocks[todo_index])
			todo_index = todo_index + 1
			in_todo_block = true
		elseif in_todo_block and todo_index <= #sorted_todo_blocks and sorted_todo_blocks[todo_index] then
			-- Continua inserindo as linhas subsequentes do bloco de TODO
			table.insert(final_lines, sorted_todo_blocks[todo_index])
			todo_index = todo_index + 1
		else
			-- Insere as linhas que não fazem parte de um bloco de TODO
			table.insert(final_lines, line)
			in_todo_block = false
		end
	end

	-- Atualizar o buffer com as linhas finais ordenadas
	vim.api.nvim_buf_set_lines(0, 0, -1, false, final_lines)

	save()
end

return M
