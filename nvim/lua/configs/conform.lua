local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    python = { "isort", "black", "blank_line" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 5000,
    lsp_fallback = true,
  },
  formatters = {
    blank_line = {
      command = "awk",
      args = "'1; END{print \"\"}'",
      stdin = true,
    },
  },
}

return options
