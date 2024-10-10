local utils = require "sidebar.utils"
local Split = require "nui.split"
local M = {}

---@type NuiSplit
M._split = nil
M._is_open = false
M._did_mount = false
M._opts = {}
M._state = {
  is_open = false,
  buffer = nil,
  winnr = nil,
  keymaps = {},
}

---@param opts NuiSplitOptions
M.create_split = function(opts)
  return Split(opts)
end

M.reset_state = function()
  M._state = {
    is_open = false,
    buffer = nil,
    winnr = nil,
    keymaps = {},
  }
  M._did_mount = false
  if M._split then
    M._split:unmount()
    M._split = nil
  end

  M._is_open = false
end

M.reload = function()
  M.reset_state()
end

---@param opts NuiSplitOptions
---@param keymaps table
M.init = function(opts, keymaps)
  M._opts = opts
  M._split = M.create_split(opts)
  M._state.keymaps = keymaps
end

M.initial_draw = function()
  M._split:mount()
  M._did_mount = true
  M._state.namespace = M._split.ns_id
  M._state.winnr = M._split.winid
  M._state.buffer = M._split.bufnr
  vim.api.nvim_set_option_value("number", false, {
    scope = "local",
  })
  vim.api.nvim_buf_set_name(M._split.bufnr, "NvimSidebar")

  for keymap, val in pairs(M._state.keymaps.n) do
    local keymap_opts = val
    M._split:map("n", keymap, keymap_opts.rhs, keymap_opts.options)
  end
end

M.toggle = function()
  if M._split and M._state.is_open then
    if not utils.is_nvim_sidebar_buf(0) then
      vim.api.nvim_set_current_win(M._state.winnr)
      vim.api.nvim_set_current_buf(M._state.buffer)
      return
    end
    M._split:hide()
    M._state.is_open = false
    M._state.winnr = nil
  elseif M._split and not M._state.is_open then
    if not M._did_mount then
      M.initial_draw()
    end
    M._split:show()
    M._state.is_open = true
    M._state.winnr = M._split.winid
  end

  return M._state.is_open
end

return M
