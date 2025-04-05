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
        "bash",
        "c",
        "css",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "toml",
        "tsx",
        "typescript",
        "vim",
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

  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    opts = function()
      dofile(vim.g.base46_cache .. "whichkey")
      return { preset = "helix" }
    end,
  },

  -------------------------------- custom plugins -------------------------------

  --- movement / editing
  { -- bracket surround
    "tpope/vim-surround",
    lazy = false,
    dependencies = { "tpope/vim-repeat" },
  },

  { -- % match `'`, `"`, backtick and pipe
    "airblade/vim-matchquote",
    lazy = false,
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

  { -- mini.ai for inside and around text objects
    "echasnovski/mini.ai",
    lazy = false,
    version = false,
    config = function()
      require("mini.ai").setup()
    end,
  },

  { -- harpoon
    "ThePrimeagen/harpoon",
    lazy = false,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require "harpoon"
      local harpoon_extensions = require "harpoon.extensions"
      harpoon.setup { settings = { save_on_toggle = true } }
      harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
      harpoon:extend {
        UI_CREATE = function(cx)
          vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item { vsplit = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-s>", function()
            harpoon.ui:select_menu_item { split = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-t>", function()
            harpoon.ui:select_menu_item { tabedit = true }
          end, { buffer = cx.bufnr })
        end,
      }
    end,
  },

  { -- rabbit
    "voxelprismatic/rabbit.nvim",
    lazy = false,
    config = function()
      require("rabbit").setup {
        window = { float = "center" },
        default_keys = {
          close = { "<Esc>", "q", "<leader>" },
          select = { "<CR>" },
          open = { "<C-r>" },
          file_add = { "a" },
          file_del = { "<Del>" },
          group = { "A" },
          group_up = { "-" },
        },
      }
    end,
  },

  ---

  { -- dim inactive windows
    "miversen33/sunglasses.nvim",
    lazy = false,
    config = function()
      require("sunglasses").setup {
        -- filter_type = "NOSYNTAX",
        filter_type = "SHADE",
        filter_percent = 0.25,
        exclude_filetypes = { "NvimTree" },
      }
    end,
  },

  -- mini.misc for zoom
  {
    "echasnovski/mini.misc",
    lazy = false,
    version = false,
    config = function()
      require("mini.misc").setup()
    end,
  },

  -- direnv
  { "direnv/direnv.vim", lazy = false },

  { -- git neogit
    "NeogitOrg/neogit",
    lazy = false,
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
        diagnostic = {
          diagnostic_only_current = true,
        },
      }
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },

  { -- vim slime
    "jpalardy/vim-slime",
    lazy = false,
    init = function()
      vim.g.slime_target = "neovim"
      -- vim.g.slime_target = "tmux"
      vim.g.slime_no_mappings = true
    end,
    config = function()
      vim.g.slime_python_ipython = 1
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = false
    end,
  },

  { -- projects
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup {
        manual_mode = true,
      }
    end,
  },
  { -- telescope
    "nvim-telescope/telescope.nvim",
    opts = function()
      local teleg = require "telescope-live-grep-args.actions"
      local defaults = require "nvchad.configs.telescope"
      local actions = require "telescope.actions"
      return vim.tbl_deep_extend("force", defaults, {
        extensions_list = { "fzf", "terms", "nerdy", "media", "live_grep_args", "projects" },

        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = { width = 0.5, preview_height = 0.65 },
          },
        },
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
        pickers = {
          buffers = {
            mappings = {
              i = { ["<CR>"] = actions.select_drop, ["<Tab>"] = actions.select_tab_drop },
            },
            find_files = {
              i = { ["<CR>"] = actions.select_drop, ["<Tab>"] = actions.select_tab_drop },
            },
            git_files = {
              i = { ["<CR>"] = actions.select_drop, ["<Tab>"] = actions.select_tab_drop },
            },
            old_files = {
              i = { ["<CR>"] = actions.select_drop, ["<Tab>"] = actions.select_tab_drop },
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
