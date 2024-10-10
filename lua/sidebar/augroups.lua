local M = {}

M._state = {
  augroup_changed = nil,
  aucmd_changed = nil,
}

---@class Options
---@field buffer_change function
---@field buffer_entere function
---@field buffer_leave function

---@param opts Options
M.init = function(opts)
  if M._state.augroup_changed then
    vim.api.nvim_del_augroup_by_id(M._state.augroup_changed)
  end

  if M._state.aucmd_changed then
    vim.api.nvim_del_autocmd(M._state.aucmd_changed)
  end
  M._state.augroup_changed = vim.api.nvim_create_augroup("NvimSidebar", {
    clear = true,
  })

  M._state.aucmd_changed = vim.api.nvim_create_autocmd({
    "BufAdd",
    "BufDelete",
    "BufModifiedSet",
  }, {
    group = M._state.augroup_changed,
    callback = opts.buffer_change,
  })

  M._state.aucmd_buf_changed = vim.api.nvim_create_autocmd({
    "BufEnter",
  }, {
    group = M._state.augroup_changed,
    callback = opts.buffer_entere,
  })

  -- M._state.aucmd_buf_changed_internal = vim.api.nvim_create_autocmd({
  --   "BufEnter",
  --   "BufLeave",
  --   "WinLeave",
  --   "WinEnter"
  -- }, {
  --   pattern = { "*", "NvimSidebar" },
  --   group = M._state.augroup_changed,
  --   callback = opts.buffer_leave,
  -- })

  M._state.aucmd_buf_changed_internal = vim.api.nvim_create_autocmd({
    -- "BufEnter",
    "BufLeave",
    "BufWipeout",
  }, {
    pattern = { "NvimSidebar" },
    group = M._state.augroup_changed,
    callback = opts.buffer_leave,
  })
end

M.reload = function()
  M._state = {
    augroup_changed = nil,
    aucmd_changed = nil,
  }
end

return M
