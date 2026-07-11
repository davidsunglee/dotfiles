-- Unified theme follower for Neovim.
-- Reads ~/.config/theme/state (dark=/light=/pin=) + macOS appearance and applies
-- the matching colorscheme, staying in sync with the shell `theme` command:
--   pin set  -> that slug ; else dark mode -> `dark` slug ; light mode -> `light` slug
-- Running instances follow OS light/dark flips and slot changes via FocusGained
-- and a periodic poll. The slug -> colorscheme map mirrors ~/.config/theme/registry.zsh
-- (full colorscheme names force the variant regardless of each plugin's `auto` opt).

local M = {}
local uv = vim.uv or vim.loop
local state_path = vim.fn.expand("~/.config/theme/state")

-- slug -> { colorscheme, is_light }
M.map = {
  poimandres             = { "poimandres", false },
  nord                   = { "nord", false },
  ["rose-pine"]          = { "rose-pine", false },
  ["rose-pine-moon"]     = { "rose-pine-moon", false },
  ["rose-pine-dawn"]     = { "rose-pine-dawn", true },
  ["catppuccin-mocha"]     = { "catppuccin-mocha", false },
  ["catppuccin-macchiato"] = { "catppuccin-macchiato", false },
  ["catppuccin-frappe"]    = { "catppuccin-frappe", false },
  ["catppuccin-latte"]     = { "catppuccin-latte", true },
  ["tokyonight-night"]   = { "tokyonight-night", false },
  ["tokyonight-storm"]   = { "tokyonight-storm", false },
  ["tokyonight-moon"]    = { "tokyonight-moon", false },
  ["tokyonight-day"]     = { "tokyonight-day", true },
}

local appearance = nil -- "dark" | "light", seeded lazily

local function detect_sync()
  if vim.fn.has("mac") == 0 then return "dark" end
  local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  return (out and out:find("Dark")) and "dark" or "light"
end

local function read_state()
  local t = {}
  local f = io.open(state_path, "r")
  if not f then return t end
  for line in f:lines() do
    local k, v = line:match("^([%w_]+)=(.*)$")
    if k then t[k] = v end
  end
  f:close()
  return t
end

function M.resolve()
  if appearance == nil then appearance = detect_sync() end
  local s = read_state()
  if s.pin and s.pin ~= "" then return s.pin end
  return (appearance == "dark") and s.dark or s.light
end

local current = nil
local did_setup = false

function M.apply()
  if not did_setup then
    did_setup = true
    M.setup()
  end
  local slug = M.resolve()
  local entry = slug and M.map[slug]
  if not entry or slug == current then return end
  vim.o.background = entry[2] and "light" or "dark"
  if pcall(vim.cmd.colorscheme, entry[1]) then
    current = slug
  end
end

-- Async: refresh appearance from the OS, then apply if anything changed.
function M.sync()
  if vim.fn.has("mac") == 0 then
    M.apply()
    return
  end
  vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(res)
    local new = (res.stdout and res.stdout:find("Dark")) and "dark" or "light"
    vim.schedule(function()
      appearance = new
      M.apply()
    end)
  end)
end

function M.setup()
  local grp = vim.api.nvim_create_augroup("ThemeSync", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
    group = grp,
    callback = function() M.sync() end,
  })
  M._timer = uv.new_timer()
  if M._timer then
    M._timer:start(3000, 3000, vim.schedule_wrap(function() M.sync() end))
  end
end

return M
