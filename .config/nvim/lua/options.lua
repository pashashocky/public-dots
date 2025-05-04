require "nvchad.options"

local o = vim.o

local options = {
  relativenumber = true, -- relative line numbers
  -- lazyredraw = true, -- no redraw while executing macros
  confirm = true, -- Confirm quitting unsaved, rather than error

  ignorecase = true, -- Case incensitive searches
  smartcase = true, -- Override ignorecase if uppercase typed
  incsearch = true, -- Incremental search while typing

  fileencoding = "utf-8", -- the encoding written to a file
  scrolloff = 12, -- Vertical scroll boundary
  sidescroll = 12, -- Horizontal scroll boundary

  cursorlineopt = "both", -- to enable cursorline!
  backspace = "indent,eol,start",

  colorcolumn = "88",

  laststatus = 2, -- status in every split
}

for k, v in pairs(options) do
  o[k] = v
end
