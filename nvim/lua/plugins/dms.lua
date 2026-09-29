-- DankMaterialShell theme integration
-- DMS regenerates `colors/dms.lua` (and the lualine theme) from the wallpaper,
-- and the colorscheme hot-reloads on change. It needs AvengeMedia/base46.

---@type LazySpec
return {
  { "AvengeMedia/base46", lazy = true, opts = {} },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = function(_, opts)
      -- fall back to AstroNvim's default theme if DMS hasn't generated one
      if vim.uv.fs_stat(vim.fn.stdpath "config" .. "/colors/dms.lua") then opts.colorscheme = "dms" end
    end,
  },
}
