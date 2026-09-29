-- Start screen: username header on top, shortcuts below with a random Pokemon beside them.
-- Very narrow terminals get a compact header.

local big_header = {
  "██╗   ██╗ █████╗ ██╗   ██╗ █████╗  █████╗ ██╗   ██╗ █████╗ ██╗   ██╗ █████╗  █████╗ ",
  "██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██╗██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██╗",
  "██║   ██║╚█████╔╝██║   ██║╚█████╔╝╚█████╔╝██║   ██║╚█████╔╝██║   ██║╚█████╔╝╚█████╔╝",
  "╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗",
  " ╚████╔╝ ╚█████╔╝ ╚████╔╝ ╚█████╔╝╚█████╔╝ ╚████╔╝ ╚█████╔╝ ╚████╔╝ ╚█████╔╝╚█████╔╝",
  "  ╚═══╝   ╚════╝   ╚═══╝   ╚════╝  ╚════╝   ╚═══╝   ╚════╝   ╚═══╝   ╚════╝  ╚════╝ ",
}

local small_header = {
  "▌ ▌▞▀▖▌ ▌▞▀▖▞▀▖▌ ▌▞▀▖▌ ▌▞▀▖▞▀▖",
  "▚▗▘▚▄▘▚▗▘▚▄▘▚▄▘▚▗▘▚▄▘▚▗▘▚▄▘▚▄▘",
  "▝▞ ▌ ▌▝▞ ▌ ▌▌ ▌▝▞ ▌ ▌▝▞ ▌ ▌▌ ▌",
  " ▘ ▝▀  ▘ ▝▀ ▝▀  ▘ ▝▀  ▘ ▝▀ ▝▀ ",
}

-- Pokemon sprites from pokemon-colorscripts. We cat a sprite ourselves (instead of `-r`) so we
-- can pick one whose size fits the space left on screen.
local sprite_dir = vim.fn.expand "~/.local/opt/pokemon-colorscripts/colorscripts/small/regular"
---@alias Sprite {file:string, h:integer, w:integer}
local sprites ---@type Sprite[]?
local pick ---@type Sprite?

-- sprite sizes, indexed once into the cache (reading all 1300+ sprites each launch is slow)
local function load_sprites()
  if sprites then return sprites end
  sprites = {}
  local index = vim.fn.stdpath "cache" .. "/pokemon-sizes.txt"
  if vim.uv.fs_stat(index) then
    for line in io.lines(index) do
      local file, h, w = line:match "^(.*)\t(%d+)\t(%d+)$"
      if file then sprites[#sprites + 1] = { file = file, h = tonumber(h), w = tonumber(w) } end
    end
  end
  if #sprites == 0 then
    local out = {}
    for _, file in ipairs(vim.fn.glob(sprite_dir .. "/*", false, true)) do
      local h, w = 0, 0
      for line in io.lines(file) do
        h = h + 1
        w = math.max(w, vim.fn.strdisplaywidth((line:gsub("\27%[[%d;]*m", ""))))
      end
      sprites[#sprites + 1] = { file = file, h = h, w = w }
      out[#out + 1] = ("%s\t%d\t%d"):format(file, h, w)
    end
    if #out > 0 then vim.fn.writefile(out, index) end
  end
  return sprites
end

-- keep the same Pokemon across redraws unless it no longer fits
local function choose_sprite(max_h, max_w)
  if pick and pick.h <= max_h and pick.w <= max_w then return pick end
  local fits = vim.tbl_filter(function(s) return s.h <= max_h and s.w <= max_w end, load_sprites())
  pick = #fits > 0 and fits[math.random(#fits)] or nil
  return pick
end

-- Layout: header on top; shortcuts below it on the left with the Pokemon beside them,
-- centered in the space to their right.
local KEYS_WIDTH = 24 -- shortcut column incl. a gap before the Pokemon
local KEYS_ROWS = 6 + 5 + 2 -- 6 shortcuts, 5 gaps, 2 padding

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    local big = vim.o.columns >= 88
    local header = big and big_header or small_header
    opts.dashboard.preset.header = table.concat(header, "\n")
    local width = big and 86 or 60
    opts.dashboard.width = width
    -- column where the (centered) header starts, so everything below lines up with it
    local left = math.floor((width - vim.fn.strdisplaywidth(header[1])) / 2)

    -- show each shortcut beside its icon rather than pinned to the far edge of the pane
    opts.dashboard.formats = vim.tbl_extend("force", opts.dashboard.formats or {}, {
      key = function() return { "" } end,
      icon = function(item)
        return { { item.key and (item.key .. "   ") or "", hl = "key" }, { item.icon, width = 2, hl = "icon" } }
      end,
    })

    local has_sprites = vim.fn.isdirectory(sprite_dir) == 1
    local shown ---@type Sprite? the Pokemon placed in the current render

    opts.dashboard.sections = {
      { section = "header", padding = 1 },
      -- The Pokemon. Evaluated on every redraw (snacks re-renders on resize, and a tiling WM can
      -- grow the window after launch). Its float overlays the rows beside the shortcuts, so it
      -- only reserves this one blank row.
      function(self)
        shown = nil
        if has_sprites then
          local area = width - left - KEYS_WIDTH
          local max_h = math.min(28, vim.o.lines - vim.o.cmdheight - #header - 3)
          shown = choose_sprite(max_h, area)
        end
        if not shown then return { text = "" } end
        local item = require("snacks").dashboard.sections.terminal {
          -- keep running so no "[Process exited]" line shows; snacks stops it when the dashboard closes
          cmd = "cat " .. vim.fn.shellescape(shown.file) .. "; sleep infinity",
          ttl = 0,
          indent = left + KEYS_WIDTH + math.floor((width - left - KEYS_WIDTH - shown.w) / 2),
          width = shown.w + 1,
          height = shown.h,
        }(self)
        item.text = ""
        return item
      end,
      { section = "keys", gap = 1, padding = 2, indent = left },
      function() -- snacks hardcodes the startup line as centered
        local item = require("snacks").dashboard.sections.startup {}
        item.align, item.indent = "left", left
        return item
      end,
      -- make room below when the Pokemon is taller than the shortcuts, so centering accounts for it
      function()
        local extra = shown and shown.h - (1 + KEYS_ROWS + 1) or 0
        return extra > 0 and { text = ("\n"):rep(extra - 1) } or {}
      end,
    }
  end,
}
