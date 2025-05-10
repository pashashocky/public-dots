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

  { import = "nvchad.blink.lazyspec" }, -- completion
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      -- completion = {
      --   ghost_text = {
      --     enabled = false,
      --   },
      -- },
    },
    sources = {
      defualt = { "lsp", "buffer", "snippets", "path" },
      -- per_filetype = { sql = { "dadbod" } },
      -- providers = {
      --   dadbod = { module = "vim_dadbod_completion.blink" },
      -- },
    },
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
        "yaml",
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
  --- ui
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    config = function()
      require("noice").setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
      "hrsh7th/nvim-cmp",
    },
  },

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
    lazy = false,
    config = function()
      local neoscroll = require "neoscroll"
      neoscroll.setup {
        mappings = { "<C-b>", "<C-f>", "zt", "zb" },
        ---@diagnostic disable-next-line: different-requires
        post_hook = require("configs.neoscroll").post_hook,
      }
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

  {
    "leath-dub/snipe.nvim",
    lazy = false,
    opts = {
      ui = { position = "cursor" },
      hints = { dictionary = "arstneiogmdhcvk" },
      navigate = {
        -- When the list is too long it is split into pages
        -- `[next|prev]_page` options allow you to navigate
        -- this list
        next_page = "<c-f>",
        prev_page = "<c-b>",

        -- You can also just use normal navigation to go to the item you want
        -- this option just sets the keybind for selecting the item under the
        -- cursor
        under_cursor = "<cr>",

        -- In case you changed your mind, provide a keybind that lets you
        -- cancel the snipe and close the window.
        ---@type string|string[]
        cancel_snipe = { "q", "<esc>" },

        -- Close the buffer under the cursor
        -- Remove "j" and "k" from your dictionary to navigate easier to delete
        -- NOTE: Make sure you don't use the character below on your dictionary
        close_buffer = "D",

        -- Open buffer in vertical split
        open_vsplit = "V",

        -- Open buffer in split, based on `vim.opt.splitbelow`
        open_split = "X",

        -- Change tag manually
        change_tag = "C",
      },
    },
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

  -- zoxide
  {
    "nanotee/zoxide.vim",
    lazy = false,
  },

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
        lazy = false,
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
          diagnostic_only_current = false,
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
  { -- session restoring
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      auto_restore = false,
      suppressed_dirs = { "~/", "~/code", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
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
            vertical = { width = 0.7, preview_height = 0.65 },
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
              i = { ["<Tab>"] = actions.select_drop, ["<A-Tab>"] = actions.select_tab_drop },
            },
            find_files = {
              i = { ["<Tab>"] = actions.select_drop, ["<A-Tab>"] = actions.select_tab_drop },
            },
            git_files = {
              i = { ["<Tab>"] = actions.select_drop, ["<A-Tab>"] = actions.select_tab_drop },
            },
            old_files = {
              i = { ["<Tab>"] = actions.select_drop, ["<A-Tab>"] = actions.select_tab_drop },
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

  { -- file explorer
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      -- check the installation instructions at
      -- https://github.com/folke/snacks.nvim
      "folke/snacks.nvim",
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      floating_window_scaling_factor = 0.6,
      keymaps = {
        show_help = "<f1>",
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      -- vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },

  {
    "MagicDuck/grug-far.nvim",
    -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
    -- additional lazy config to defer loading is not really needed...
    lazy = false,
    config = function()
      -- optional setup call to override plugin options
      -- alternatively you can set options with vim.g.grug_far = { ... }
      require("grug-far").setup {
        -- options, see Configuration section below
        -- there are no required options atm
      }
    end,
  },

  { -- smart-splits
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup {
        ignored_filetypes = {
          "NvimTree",
        },
        default_amount = 5, -- default number of lines to resize by
        resize_mode = {
          quit_key = "<ESC>", -- key to exit persistent resize mode
          resize_keys = { "n", "e", "i", "o" }, -- keys to use for moving in resize mode
        },
      }
    end,
  },

  { -- fun
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
}
