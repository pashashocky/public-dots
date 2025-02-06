local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

--- Appearance
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

--- Performance
config.front_end = "WebGpu"
config.max_fps = 120
config.webgpu_power_preference = "HighPerformance"

-- Fonts
-- Ligatures Support: <= <- -> --> ---> => >= == != ->  ===
-- config.font = wezterm.font 'Wumpus Mono Pro'
-- config.font = wezterm.font 'Hermit'
config.font = wezterm.font('Liga Hack', { weight = 'Bold' })
config.font_size = 12

-- https://wezfurlong.org/wezterm/faq.html#multiple-characters-being-renderedcombined-as-one-character
-- config.harfbuzz_features = { 'calt=0' }
--------

-- Color Schemes
-- https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'flexoki-dark'
config.color_scheme = 'ferra'
config.colors = {
  background = '#262626' -- match helix
}
--------

-- Window Padding
config.window_padding = {
  left = 30,
  right = 30,
  top = 30,
  bottom = 30,
}
--------

--- QoL
config.set_environment_variables = {
  PATH = '/Users/pash/.cargo/bin:'
      .. '/Users/pash/.local/bin:'
      .. '/opt/homebrew/bin:'
      .. '/usr/local/bin:'
      .. os.getenv('PATH')
}

config.scrollback_lines = 100000
config.audible_bell = "Disabled"
config.unzoom_on_switch_pane = true
config.default_workspace = "root"

-- Honor kitty keyboard protocol: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
-- config.enable_kitty_keyboard = true

--------

--- Functions
local function startswith(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function extension(filename)
  return filename:match("%.([^.:/\\]+):%d+:%d+$")
end

local function extract_filename(uri)
  local start, match_end = uri:find("$EDITOR:");
  if start == 1 then
    return uri:sub(match_end + 1)
  end

  return nil
end


local function editable(filename)
  local ext = filename:match("%.([^.:/\\]+):%d+:%d+$")
  if ext then
    wezterm.log_info(string.format("extension is [%s]", ext))
    local text_extensions = {
      md = true,
      c = true,
      go = true,
      scm = true,
      rkt = true,
      rs = true,
    }
    if text_extensions[ext] then
      return true
    end
  end

  return false
end

local function open_with_hx(window, pane, url)
  local name = extract_filename(url)
  wezterm.log_info('name: ' .. url)
  if name and editable(name) then
    if extension(name) == "rs" then
      wezterm.log_info('get_current_working_dir=' .. pane:get_current_working_dir().file_path)
      local pwd = string.gsub(pane:get_current_working_dir().file_path, "file://.-(/.+)", "%1")
      name = pwd .. "/" .. name
    end

    local direction = 'Up'
    local hx_pane = pane:tab():get_pane_direction(direction)
    if hx_pane == nil then
      local action = wezterm.action {
        SplitPane = {
          direction = direction,
          command = { args = { 'hx', name } }
        },
      };
      window:perform_action(action, pane);
      pane:tab():get_pane_direction(direction).activate()
    elseif basename(hx_pane:get_foreground_process_name()) == "hx" then
      local action = wezterm.action.SendString(':open ' .. name .. '\r\n')
      window:perform_action(action, hx_pane);
      hx_pane:activate()
    else
      local action = wezterm.action.SendString('hx ' .. name .. '\r\n')
      window:perform_action(action, hx_pane);
      hx_pane:activate()
    end
    -- prevent the default action from opening in a browser
    return false
  end
  -- otherwise, by not specifying a return value, we allow later
  -- handlers and ultimately the default action to caused the
  -- URI to be opened in the browser
end

--------

--- Keys
config.keys = {
  {
    key = ',',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab {
      cwd = os.getenv('WEZTERM_CONFIG_DIR'),
      set_environment_variables = {
        TERM = 'screen-256color',
      },
      args = {
        'hx',
        os.getenv('WEZTERM_CONFIG_FILE'),
      },
    },
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    key = 'j',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = "g",
    mods = "CMD",
    action = wezterm.action { PaneSelect = { alphabet = "tnseriaogm" } }
  },
  {
    key = 'g',
    mods = 'CMD|SHIFT',
    action = act.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  {
    key = '[',
    mods = 'CMD',
    action = act.Multiple {
      act.ActivatePaneDirection 'Up',
      act.EmitEvent 'reload-helix',
    }
  },
  {
    key = ']',
    mods = 'CMD',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'n',
    mods = 'CMD',
    action = act.Multiple {
      act.ActivatePaneDirection 'Left',
      act.EmitEvent 'reload-helix',
    }
  },
  {
    key = 'e',
    mods = 'CMD',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'i',
    mods = 'CMD',
    action = act.Multiple {
      act.ActivatePaneDirection 'Up',
      act.EmitEvent 'reload-helix',
    }
  },
  {
    key = 'o',
    mods = 'CMD',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'n',
    mods = 'CMD|SHIFT',
    action = act.AdjustPaneSize { 'Left', 10 },
  },
  {
    key = 'e',
    mods = 'CMD|SHIFT',
    action = act.AdjustPaneSize { 'Down', 10 },
  },
  { key = 'i', mods = 'CMD|SHIFT', action = act.AdjustPaneSize { 'Up', 10 } },
  {
    key = 'o',
    mods = 'CMD|SHIFT',
    action = act.AdjustPaneSize { 'Right', 10 },
  },
  {
    key = 'z',
    mods = 'CMD',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = 'UpArrow',
    mods = 'SHIFT',
    action = act.ScrollToPrompt(-1),
  },
  {
    key = 'DownArrow',
    mods = 'SHIFT',
    action = act.ScrollToPrompt(1),
  },
  {
    key = 'Home',
    mods = 'SHIFT',
    action = act.ScrollToTop,
  },
  {
    key = 'End',
    mods = 'SHIFT',
    action = act.ScrollToBottom,
  },
  { key = 'l', mods = 'ALT',       action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = 'u',
    mods = 'ALT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
  {
    -- https://github.com/quantonganh/dotfiles/blob/main/.wezterm.lua
    key = 's',
    mods = 'CMD',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = {
        'https?://\\S+',
        '^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+',
        '[^\\s]+\\.rs:\\d+:\\d+',
        'rustc --explain E\\d+',
      },
      action = wezterm.action_callback(function(window, pane)
        local selection = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. selection)
        if startswith(selection, "http") then
          wezterm.open_with(selection)
        elseif startswith(selection, "rustc --explain") then
          local action = wezterm.action {
            SplitPane = {
              direction = 'Right',
              command = {
                args = {
                  '/bin/sh',
                  '-c',
                  'rustc --explain ' .. selection:match("(%S+)$") .. ' | mdcat -p',
                },
              },
            },
          };
          window:perform_action(action, pane);
        else
          selection = "$EDITOR:" .. selection
          return open_with_hx(window, pane, selection)
        end
      end),
    },
  },
}
--------

--- Events
wezterm.on('reload-helix', function(window, pane)
  local top_process = basename(pane:get_foreground_process_name())
  if top_process == 'hx' then
    local bottom_pane = pane:tab():get_pane_direction('Down')
    if bottom_pane ~= nil then
      local bottom_process = basename(bottom_pane:get_foreground_process_name())
      if bottom_process == 'lazygit' then
        local action = wezterm.action.SendString(':reload-all\r\n')
        window:perform_action(action, pane);
      end
    end
  end
end)

wezterm.on('open-uri', function(window, pane, uri)
  return open_with_hx(window, pane, uri)
end)

-- Persist window size
-- https://github.com/wez/wezterm/issues/256#issuecomment-1501101484
local cache_dir = os.getenv('HOME') .. '/.cache/wezterm/'
local window_size_cache_path = cache_dir .. 'window_size_cache.txt'

wezterm.on('gui-startup', function()
  os.execute('mkdir ' .. cache_dir)

  local window_size_cache_file = io.open(window_size_cache_path, 'r')
  if window_size_cache_file ~= nil then
    local _, _, width, height = string.find(window_size_cache_file:read(), '(%d+),(%d+)')
    mux.spawn_window { width = tonumber(width), height = tonumber(height) }
    window_size_cache_file:close()
  else
    local _, _, window = mux.spawn_window {}
    window:gui_window():maximize()
  end
end)

wezterm.on('window-resized', function(_, pane)
  local tab_size = pane:tab():get_size()
  local cols = tab_size['cols']
  local rows = tab_size['rows'] + 2 -- Without adding the 2 here, the window doesn't maximize
  local contents = string.format('%d,%d', cols, rows)
  local window_size_cache_file = assert(io.open(window_size_cache_path, 'w'))
  window_size_cache_file:write(contents)
  window_size_cache_file:close()
end)
--------

-- hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex = '^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+',
  format = '$EDITOR:$0',
})

table.insert(config.hyperlink_rules, {
  regex = '[^\\s]+\\.rs:\\d+:\\d+',
  format = '$EDITOR:$0',
})

-- and finally, return the configuration to wezterm
return config
