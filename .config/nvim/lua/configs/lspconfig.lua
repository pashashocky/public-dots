local M = {}
local map = vim.keymap.set
local lspconfig = require "lspconfig"

-- export on_attach & capabilities
M.on_attach = function(_, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "gii", vim.lsp.buf.implementation, opts "Go to implementation")
  map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")

  map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")

  -- map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action") -- NvChad/NvChad #3228
  -- map("n", "gr", vim.lsp.buf.references, opts "Show references") -- in LspSaga mappings.lua
end

-- disable semanticTokens
M.on_init = function(client, _)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

M.defaults = function()
  dofile(vim.g.base46_cache .. "lsp")
  require("nvchad.lsp").diagnostic_config()

  require("lspconfig").lua_ls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,

    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            vim.fn.expand "$VIMRUNTIME/lua",
            vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
            vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
            vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
            "${3rd}/luv/library",
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  }
end

M.defaults()

local servers = {
  html = {},
  cssls = {},
  awk_ls = {},
  bashls = {},

  basedpyright = {
    settings = {
      python = {
        pythonPath = vim.fn.exepath "python",
      },
    },
  },
  ruff = {},
  -- pylsp = {
  --   settings = {
  --     pylsp = {
  --       plugins = {
  --         pycodestyle = {
  --           ignore = {
  --             "W391", -- line eof
  --             "W503", -- line break before binary operator
  --             "E203", -- whitespace before ':'
  --           },
  --           maxLineLength = 88,
  --         },
  --       },
  --     },
  --   },
  -- },
}

for name, opts in pairs(servers) do
  opts.on_init = M.on_init
  opts.on_attach = M.on_attach
  opts.capabilities = M.capabilities

  lspconfig[name].setup(opts)
end

vim.diagnostic.config { virtual_lines = { current_line = true }, virtual_text = false }
