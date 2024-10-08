local Split = require('nui.split')

local M = {}


M._split = nil
M._is_open = false
M._state = {
  is_open = false,
  buffer = nil,
  winnr = nil
}


M.create_split = function(opts)
  return Split(opts)
end

M.init = function (opts)
  M._split = M.create_split(opts)
  M._split:mount()
  M._state.is_open = true
  M._state.buffer = M._split.bufnr
  M._state.namespace = M._split.ns_id
  M._state.winnr = M._split.winid
end

M.toggle = function()
  if M._split and M._state.is_open then
    M._split:hide()
    M._state.is_open = false
    M._state.winnr = nil

  elseif M._split and not M._state.is_open then
    M._split:show()
    M._state.is_open = true
    M._state.winnr = M._split.winid
  end

  return M._state.is_open
end

return M
