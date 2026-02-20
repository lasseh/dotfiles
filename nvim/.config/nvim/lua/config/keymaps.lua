-- Key mappings (ported from .vimrc)
local keymap = vim.keymap.set

-- Neo-tree toggle (was NERDTree)
keymap("n", "<C-n>", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Function keys
keymap("n", "<F5>", ":set paste<CR>", { desc = "Set paste mode" })
keymap("n", "<F7>", ":set invnumber<CR>", { desc = "Toggle line numbers" })

-- Leader key mappings
keymap("n", "<leader>ev", ":vsplit $MYVIMRC<CR>", { desc = "Edit vimrc" })
keymap("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Source vimrc" })
keymap("n", "<leader>n", ":lnext<CR>", { desc = "Next location" })
keymap("n", "<leader>E", ":lclose<CR>", { desc = "Close location list" })
keymap("n", "<leader>p", ":lprev<CR>", { desc = "Previous location" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>qq", ":q!<CR>", { desc = "Force quit" })
keymap("n", "<leader>wa", ":wa<CR>", { desc = "Write all" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Write" })
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Insert mode mappings
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Command aliases
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})
