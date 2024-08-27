local M = {}

local functions = require("markdown-todo.functions")

function M.setup(opts)
	local filetypes = opts.filetypes or { "markdown" }

	local default_keybindings = {
		toggle_checkbox = "<CR>",
		sort_by_priority = "<leader>ms",
		add_todo_line = "<tab>",
		add_low_priority = "<leader>m1",
		add_medium_priority = "<leader>m2",
		add_high_priority = "<leader>m3",
	}

	local keybindings = opts.keybindings or {}

	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = filetypes,
		callback = function(buf)
			vim.keymap.set(
				"n",
				keybindings.add_todo_line or default_keybindings.add_todo_line,
				functions.add_todo_line,
				{ buffer = buf.buf, desc = "Add todo" }
			)
			vim.keymap.set(
				"n",
				keybindings.sort_by_priority or default_keybindings.sort_by_priority,
				functions.sort_todos_by_priority,
				{ buffer = buf.buf, desc = "Sort todos by priority" }
			)
			vim.keymap.set(
				"n",
				keybindings.toggle_checkbox or default_keybindings.toggle_checkbox,
				functions.toggle_checkbox,
				{ buffer = buf.buf, desc = "Toggle checkbox" }
			)
			vim.keymap.set("n", keybindings.add_low_priority or default_keybindings.add_low_priority, function()
				functions.set_priority_tag("low")
			end, { buffer = buf.buf, desc = "LOW" })
			vim.keymap.set("n", keybindings.add_medium_priority or default_keybindings.add_medium_priority, function()
				functions.set_priority_tag("medium")
			end, { buffer = buf.buf, desc = "MEDIUM" })
			vim.keymap.set("n", keybindings.add_high_priority or default_keybindings.add_high_priority, function()
				functions.set_priority_tag("high")
			end, { buffer = buf.buf, desc = "HIGH" })
			vim.keymap.set("n", "<leader>mc", functions.clear_todos, { buffer = buf.buf, desc = "Clear Todos" })
		end,
		group = vim.api.nvim_create_augroup("markdown-todo", { clear = true }),
	})
end

return M
