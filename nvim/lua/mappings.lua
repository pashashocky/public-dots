require "nvchad.mappings"

local map = vim.keymap.set
local map_del = vim.keymap.del

map("n", "<F5>", "<cmd> source <CR>", { desc = "Reload config" })

-- unbind from nvchad
map_del("n", "<leader>h")

--- helix vibes
-- movement
map({ "n", "o", "x" }, "gh", "0", { desc = "Goto line start" })
map({ "n", "o", "x" }, "gs", "^", { desc = "Goto first non blank on line" })
map({ "n", "o", "x" }, "gl", "$", { desc = "Goto line end" })
map({ "n", "v" }, "ge", "G", { desc = "Goto end of file" })
map({ "n", "v" }, "gb", "ge", { desc = "Goto end of previous word" })

map("n", "<A-d>", '"_dd', { desc = "Delete without cut" })
map("v", "<A-d>", '"_d', { desc = "Delete without cut" })

map("n", "<leader><tab>", '<cmd> call feedkeys("\\<Plug>(prev)") <CR>', { desc = "Goto last accessed buffer/file/tab" })
map("n", "ga", "<C-6>", { desc = "Goto last accessed buffer" })

map("n", "gn", function()
  require("nvchad.tabufline").next()
end, { desc = "Goto next buffer" })

map("n", "gp", function()
  require("nvchad.tabufline").prev()
end, { desc = "Goto previous buffer" })

map("n", "<leader>tx", function()
  if next(require("diffview.lib").views) ~= nil then
    vim.cmd "DiffviewClose"
  else
    vim.cmd "tabclose"
  end
end, { desc = "Tab close" })
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

-- map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
-- map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
local neoscroll = require "neoscroll"
local ns = require "configs.neoscroll"
local keymap = {
  ["<C-u>"] = function()
    ns.scroll_and_center(-vim.wo.scroll, 100)
  end,
  ["<C-d>"] = function()
    ns.scroll_and_center(vim.wo.scroll, 100)
  end,
  ["<C-y>"] = function()
    neoscroll.scroll(-0.1, { move_cursor = false, duration = 80 })
  end,
  ["<C-e>"] = function()
    neoscroll.scroll(0.1, { move_cursor = false, duration = 80 })
  end,
  ["zz"] = function()
    neoscroll.zz { half_win_duration = 100 }
  end,
}
local modes = { "n", "v", "x" }
for key, func in pairs(keymap) do
  map(modes, key, func)
end

map("v", "<leader>p", '"_dP', { desc = "Paste without copy" })
map("v", ">", ">gv", { desc = "indent left" })
map("v", "<", "<gv", { desc = "indent right" })
map({ "n", "x", "o" }, "mm", "%", { desc = "matching parenthesis", remap = true })
map("n", "mn", "m", { desc = "Create mark" })

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
map("n", "<leader>gr", "<cmd>Telescope git_branches<cr>", { desc = "Telescope git branches" })

map("n", "<leader>c?", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

-- LspSaga
map("n", "<leader>ca", "<cmd>:Lspsaga code_action<CR>", { desc = "LSP Code action" })
map("n", "<leader>ci", "<cmd>:Lspsaga incoming_calls<CR>", { desc = "LSP Incoming call hier" })
map("n", "<leader>co", "<cmd>:Lspsaga outgoing_calls<CR>", { desc = "LSP Outgoing call hier" })
map("n", "[d", "<cmd>:Lspsaga diagnostic_jump_prev<CR>", { desc = "Jump to previous diagnostic" })
map("n", "]d", "<cmd>:Lspsaga diagnostic_jump_next<CR>", { desc = "Jump to next diagnostic" })
map("n", "gr", "<cmd>:Lspsaga finder def+ref<CR>", { desc = "LSP Show references" })
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

-- harpoon
local harpoon = require "harpoon"
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table {
        results = file_paths,
      },
      previewer = conf.file_previewer {},
      sorter = conf.generic_sorter {},
    })
    :find()
end

map("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Harpoon add to list" })
map("n", "<leader>hh", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon show list" })
vim.keymap.set("n", "<leader>fn", function()
  toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

map("n", "<C-A-n>", function()
  harpoon:list():select(1)
end)
map("n", "<C-A-e>", function()
  harpoon:list():select(2)
end)
map("n", "<C-A-i>", function()
  harpoon:list():select(3)
end)
map("n", "<C-A-o>", function()
  harpoon:list():select(4)
end)
map("n", "<C-A-b>", function()
  harpoon:list():prev()
end)
map("n", "<C-A-f>", function()
  harpoon:list():next()
end)

-- conform
map({ "n", "v" }, "<leader>fmt", function()
  require("conform").format { async = true, lsp_fallback = true }
end, { desc = "general format file" })

map({ "n", "v" }, "<leader>fmt", function()
  require("conform").format { async = true, lsp_fallback = true }
end, { desc = "general format file" })

-- git
map("n", "<leader>gn", "<cmd>Neogit<CR>", { desc = "Neogit home" })
map("n", "<leader>gf", "<cmd>Neogit kind=floating<CR>", { desc = "Neogit home" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diff view open" })
map("n", "<leader>gb", "<cmd>G blame<CR>", { desc = "Git blame" })

-- git actions
local gs = require "gitsigns"
map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<cr>", { desc = "Stage hunk" })
map({ "n", "v" }, "<leader>hr", ":Gitsigns stage_hunk<cr>", { desc = "Reset hunk" })
map("n", "<leader>hx", "<cmd>wincmd p | q<cr>", { desc = "Exit diff view" })
map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
map("n", "<leader>ha", gs.stage_hunk, { desc = "Stage hunk" })
map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Git toggle current line blame" })
map("n", "<leader>hd", gs.diffthis, { desc = "Git diff this" })
map("n", "<leader>hD", function()
  gs.diffthis "~"
end, { desc = "Git diff this ~" })
map("n", "<leader>hb", function()
  gs.blame_line { full = true }
end, { desc = "Show line blame" })
map("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    gs.next_hunk()
  end)
  return "<Ignore>"
end, { desc = "Select next hunk" })
map("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    gs.prev_hunk()
  end)
  return "<Ignore>"
end, { desc = "Select previous hunk" })
map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<cr>", { desc = "Select hunk" })

-- slime
map("n", "gz", "<Plug>SlimeMotionSend", { desc = "Slime send motion", remap = true, silent = false })
map("n", "gzz", "<Plug>SlimeLineSend", { desc = "Slime send line", remap = true, silent = false })
map("n", "gzc", "<Plug>SlimeConfig", { desc = "Slime config", remap = true, silent = false })
map("x", "gz", "<Plug>SlimeRegionSend", { desc = "Slime send region", remap = true, silent = false })

-- smart-splits
-- recommended mappings
-- resizing splits
-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
map("n", "<A-Left>", require("smart-splits").resize_left)
map("n", "<A-Down>", require("smart-splits").resize_down)
map("n", "<A-Up>", require("smart-splits").resize_up)
map("n", "<A-Right>", require("smart-splits").resize_right)
-- moving between splits
map("n", "<A-n>", require("smart-splits").move_cursor_left) -- tmux
map("n", "<A-e>", require("smart-splits").move_cursor_down)
map("n", "<A-i>", require("smart-splits").move_cursor_up)
map("n", "<A-o>", require("smart-splits").move_cursor_right)
map("n", "<A-S-n>", require("smart-splits").move_cursor_left) -- wezterm
map("n", "<A-S-e>", require("smart-splits").move_cursor_down)
map("n", "<A-S-i>", require("smart-splits").move_cursor_up)
map("n", "<A-S-o>", require("smart-splits").move_cursor_right)
map("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- swapping buffers between windows
map("n", "<leader><leader>n", require("smart-splits").swap_buf_left, { desc = "Swap buf left" })
map("n", "<leader><leader>e", require("smart-splits").swap_buf_down, { desc = "Swap buf down" })
map("n", "<leader><leader>i", require("smart-splits").swap_buf_up, { desc = "Swap buf up" })
map("n", "<leader><leader>o", require("smart-splits").swap_buf_right, { desc = "Swap buf right" })

-- mini
map("n", "<leader>z", '<cmd>lua require("mini.misc").zoom()<cr>', { desc = "Full screen buffer" })

-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Escape terminal mode" })
map({ "n", "t" }, "<A-f>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating term" })
map({ "n", "t" }, "<A-`>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle horizontal term" })
map("n", "<leader>st", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "New horizontal term" })

-- fun
map("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "make it rain" })
map("n", "<Bslash>", "<cmd>SunglassesToggle<cr>", { desc = "Toggle sunglasses" })
