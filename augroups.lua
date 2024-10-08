
local M = {
}

M._state = {
  augroup_changed = nil,
  aucmd_changed = nil
}

M.init = function(cb_aucmd, cb_buf_aucmd)
  if M._state.augroup_changed then
    vim.api.nvim_del_augroup_by_id(M._state.augroup_changed)
  end

  if M._state.aucmd_changed then
    vim.api.nvim_del_autocmd(M._state.aucmd_changed)
  end
  M._state.augroup_changed = vim.api.nvim_create_augroup("sidebar_nvim", {
    clear= true
  })

  M._state.aucmd_changed = vim.api.nvim_create_autocmd({
    "BufAdd",
    "BufDelete",
    "BufModifiedSet",
  }, {
      group = M._state.augroup_changed,
      callback = cb_aucmd
    })

  M._state.aucmd_buf_changed = vim.api.nvim_create_autocmd({
    "BufEnter",
  }, {
      group = M._state.augroup_changed,
      callback = cb_buf_aucmd
    })

end

return M
