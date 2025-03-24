return {
  -------------------------------- default plugins -------------------------------

  { -- formatting
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  { -- lsp
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  { -- syntax highlighting
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "html",
        "css",
        "javascript",
        "json",
        "toml",
        "markdown",
        "c",
        "bash",
        "lua",
        "tsx",
        "typescript",
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gin",
          node_incremental = "<TAB>",
          scope_incremental = "<CR>",
          node_decremental = "<S-TAB>",
        },
      },
    },

    dependencies = {
      {
        "windwp/nvim-ts-autotag",
        config = function()
          require("nvim-ts-autotag").setup()
        end,
      },
    },
  },

  { -- commenting
    "numToStr/Comment.nvim",
    lazy = false,
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

  -------------------------------- custom plugins -------------------------------

  --- movement / editing
  { -- bracket surround
    "tpope/vim-surround",
    event = "BufReadPost",
    dependencies = { "tpope/vim-repeat" },
  },

  { -- % match `'`, `"`, backtick and pipe
    "airblade/vim-matchquote",
    event = "BufReadPost",
  },

  { -- smooth scroll
    "karb94/neoscroll.nvim",
    keys = { "<C-d>", "<C-u>", "<C-f>", "<C-b>", "zz", "n", "N", "<C-y>", "<C-e>" },
    config = function()
      require("neoscroll").setup()
    end,
  },

  { -- multicursor editing inside visual
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
  },

  { -- leap around buffers with hints
    "ggandor/leap.nvim",
    lazy = false, -- documentation says not to lazy load, as lazy loads self
    config = function()
      local leap = require "leap"
      leap.setup {
        labels = { "t", "n", "s", "e", "r", "i", "a", "o", "g", "m", "h", "d", "c", "v", "k" },
        safe_labels = { "t", "n", "s", "e", "r", "i", "a", "o", "g", "m", "h", "d", "c", "v", "k" },
      }
      -- leap.add_default_mappings()
    end,
    setup = function()
      require("core.lazy_load").on_file_open "leap.nvim"
      require("core.utils").load_mappings "leap"
    end,
    dependencies = { "tpope/vim-repeat" },
  },

  { -- leap motions for fFtT
    "ggandor/flit.nvim",
    lazy = false,
    config = function()
      require("flit").setup {}
    end,
    setup = function()
      require("core.lazy_load").on_file_open "flit.nvim"
    end,
  },

  ---

  { -- dim inactive windows
    "andreadev-it/shade.nvim",
    lazy = false,
    config = function()
      require("shade").setup {
        overlay_opacity = 75,
        exclude_filetypes = { "NvimTree" },
      }
    end,
    setup = function()
      require("shade").toggle()
    end,
  },

  { -- git neogit
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "echasnovski/mini.pick", -- optional
    },
    config = true,
    cmd = "Neogit",
  },

  { -- pretty diagnostics panel
    "folke/trouble.nvim",
    cmd = { "Trouble", "TodoTrouble" },
    dependencies = {
      {
        "folke/todo-comments.nvim",
        opts = {},
      },
    },
    config = function()
      require("trouble").setup()
    end,
  },

  { -- lsp improvements
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup {
        ui = {
          code_action = "",
        },
      }
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },

  { -- projects
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup()
    end,
  },
  { -- telescope
    "nvim-telescope/telescope.nvim",
    opts = function()
      local teleg = require "telescope-live-grep-args.actions"
      local defaults = require "nvchad.configs.telescope"
      return vim.tbl_deep_extend("force", defaults, {
        extensions_list = { "fzf", "terms", "nerdy", "media", "live_grep_args", "projects" },

        extensions = {
          media = {
            backend = "ueberzug",
          },
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            mappings = { -- extend mappings
              i = {
                ["<C-k>"] = teleg.quote_prompt(),
                ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " --iglob " },
              },
            },
          },
        },
      })
    end,

    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "2kabhishek/nerdy.nvim",
      "dharmx/telescope-media.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
  },
  "NvChad/nvcommunity",
  { import = "nvcommunity.editor.telescope-undo" },

  { -- tmux TODO: replace with smart-splits
    "aserowy/tmux.nvim",
    config = function()
      return require("tmux").setup()
    end,
  },

  { -- fun
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
}
