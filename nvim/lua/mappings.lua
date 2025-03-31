require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<F5>", "<cmd> source <CR>", { desc = "Reload config" })

--- helix vibes
-- movement
map({ "n", "v" }, "gh", "0", { desc = "Goto line start" })
map({ "n", "v" }, "gs", "^", { desc = "Goto first non blank on line" })
map({ "n", "v" }, "gl", "$", { desc = "Goto line end" })
map({ "n", "v" }, "ge", "G", { desc = "Goto end of file" })
map({ "n", "v" }, "gb", "ge", { desc = "Goto end of previous word" })

map("n", "<A-d>", '"_dd', { desc = "Delete without cut" })
map("v", "<A-d>", '"_d', { desc = "Delete without cut" })

map("n", "<leader><tab>", '<cmd> call feedkeys("\\<Plug>(prev)") <CR>', { desc = "Goto last accessed buffer/file/tab" })
map("n", "ga", '<cmd> call feedkeys("\\<Plug>(prev)") <CR>', { desc = "Goto last accessed buffer/file/tab" })

map("n", "gn", function()
  require("nvchad.tabufline").next()
end, { desc = "Goto next buffer" })

map("n", "gp", function()
  require("nvchad.tabufline").prev()
end, { desc = "Goto previous buffer" })

map("n", "gx", function()
  require("nvchad.tabufline").close_buffer()
end, {
  desc = "Close buffer",
})

-- changes
map("n", "U", "<C-r>", { desc = "Redo change" })
---

-- multicursor
map({ "n", "v" }, "mc", "<cmd>MCstart<cr>", { desc = "Create a selection for selected text or word under the cursor" })
map("n", "ms", "<cmd>MCunderCursor<cr>", { desc = "Create a selection for the char under cursor" })
map("v", "s", "<esc><cmd>MCvisualPattern<cr>", { desc = "Create a selection for inputted pattern" })

-- vim general
map("n", "n", "nzz", { desc = "Goto next search result" })
map("n", "N", "nzz", { desc = "Goto previous search result" })
map("n", "<leader>fs", "<cmd> w <cr>", { desc = "Save" })
map("n", "<leader>cc", "gcc", { desc = "Comment", remap = true })
map("v", "<leader>cc", "gc", { desc = "Comment", remap = true })
map("v", ">", ">gv", { desc = "indent left" })
map("v", "<", "<gv", { desc = "indent right" })
map({ "n", "x", "o" }, "mm", "%", { desc = "matching parenthesis", remap = true })

-- Telescope
local builtin = require "telescope.builtin"
local utils = require "telescope.utils"
map(
  "n",
  "<leader>fw",
  ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
  { desc = "Telescope live grep" }
)
map("n", "<leader>'", "<cmd>Telescope resume<CR>", { desc = "Open last telescope picker" })
map("n", "<leader>fk", "<cmd> Telescope keymaps<CR>", { desc = "Telescope keymap" })
map("n", "<leader>fp", "<cmd> Telescope projects<CR>", { desc = "Telescope projects" })
map("n", "<leader>fcp", function()
  local root = string.gsub(vim.fn.system "git rev-parse --show-toplevel", "\n", "")
  if vim.v.shell_error == 0 then
    builtin.find_files { cwd = root }
  else
    builtin.find_files()
  end
end, { desc = "Telescope find in current project" })
map("n", "<leader>fcc", function()
  builtin.find_files { cwd = utils.buffer_dir() }
end, { desc = "Telescope find in current buffer dir" })

map("n", "<leader>c?", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

-- LspSaga
map("n", "<leader>ca", "<cmd>:Lspsaga code_action<CR>", { desc = "LSP Code action" })
map("n", "<leader>ci", "<cmd>:Lspsaga incoming_calls<CR>", { desc = "LSP Incoming call hier" })
map("n", "<leader>co", "<cmd>:Lspsaga outgoing_calls<CR>", { desc = "LSP Outgoing call hier" })
map("n", "[d", "<cmd>:Lspsaga diagnostic_jump_prev<CR>", { desc = "Jump to previous diagnostic" })
map("n", "]d", "<cmd>:Lspsaga diagnostic_jump_next<CR>", { desc = "Jump to next diagnostic" })
map("n", "gr", "<cmd>:Lspsaga finder ref<CR>", { desc = "LSP Show references" })
map("n", "<leader>gr", "<cmd>:Lspsaga finder def+ref+imp<CR>", { desc = "LSP Show def/ref/imp" })
map("n", "<leader>k", "<cmd>:Lspsaga hover_doc<CR>", { desc = "LSP Hover documentation" })
map("n", "<leader>K", "<cmd>:Lspsaga hover_doc ++keep<CR>", { desc = "LSP Hover documentation (pin)" })
map("n", "<leader>re", "<cmd>:Lspsaga rename ++project<CR>", { desc = "LSP Rename in project" })

-- leap (space/backspace - move to next suggestion group), after keybind:
-- {char1}{char2}
-- {char}{space} - last char of line
-- {space}{space} - actual end of line
-- {enter} - repeat previous match
-- {char}{enter} - multiline fFtT
map("n", "s", "<Plug>(leap-forward)", { desc = "Leap forward" }) -- don't bind visual - multicursor
map("n", "S", "<Plug>(leap-backward)", { desc = "Leap backward" }) -- don't bind visual - surround
map({ "n", "x", "o" }, "gw", "<Plug>(leap)", { desc = "Leap window" })
map({ "n", "x", "o" }, "<leader>sl", "<Plug>(leap-anywhere)", { desc = "Leap anywhere" })

-- conform
map({ "n", "v" }, "<leader>fmt", function()
  require("conform").format { async = true, lsp_fallback = true }
end, { desc = "general format file" })

-- git
map("n", "<leader>gn", "<cmd>Neogit<CR>", { desc = "Neogit home" })

-- slime
map("n", "gz", "<Plug>SlimeMotionSend", { desc = "Slime send motion", remap = true, silent = false })
map("n", "gzz", "<Plug>SlimeLineSend", { desc = "Slime send line", remap = true, silent = false })
map("n", "gzc", "<Plug>SlimeConfig", { desc = "Slime config", remap = true, silent = false })
map("x", "gz", "<Plug>SlimeRegionSend", { desc = "Slime send region", remap = true, silent = false })

-- tmux
map("n", "<C-h>", '<cmd>lua require("tmux").move_left()<cr>', { desc = "switch window left" })
map("n", "<C-l>", '<cmd>lua require("tmux").move_right()<cr>', { desc = "switch window right" })
map("n", "<C-j>", '<cmd>lua require("tmux").move_bottom()<cr>', { desc = "switch window down" })
map("n", "<C-k>", '<cmd>lua require("tmux").move_top()<cr>', { desc = "switch window up" })

-- mini
map("n", "<leader>z", '<cmd>lua require("mini.misc").zoom()<cr>', { desc = "Full screen buffer" })

-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
map({ "n", "t" }, "<A-f>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating term" })
map({ "n", "t" }, "<A-`>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggle horizontal term" })
map("n", "<leader>s", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "terminal new horizontal term" })

-- fun
map("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "make it rain" })
map("n", "<Bslash>", function()
  require("shade").toggle()
end, { desc = "Toggle shade.nvim" })
