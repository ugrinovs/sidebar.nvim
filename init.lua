local ui = require "personal.buffer-list.ui"

local augroups = require "personal.buffer-list.augroups"

local list = require "personal.buffer-list.list"
local M = {}

M._state = {
  buf_list = {},
  first_draw = false,
  current_win = nil,
}
local default_opts = {
  relative = "editor",
  position = "left",
  size = "10%",
}

M.setup = function(opts)
  M._state.current_win = vim.api.nvim_get_current_win()
  if ui._state.buffer then
    return
  end

  local options = vim.tbl_extend("force", default_opts, opts or {})
  ui.init(options)
  augroups.init(M.on_event, M.on_buf_event)


  M.draw()
  M._state.first_draw = true

  -- TODO add keymaps and option to change keymaps
  vim.keymap.set(
    "n",
    "<leader>l",
    M.toggle,
    -- '<cmd>lua require("personal.buffer-list").toggle()<CR>',
    { noremap = true, silent = true}
  )

  vim.keymap.set(
    "n",
    "<CR>",
    function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local bufnr = vim.iter(M._state.buf_list)
      :find(function(_, v)
        return v.line == cursor_line
      end)
      print('win', ui._state.winnr, M._state.current_win)

      if vim.api.nvim_win_is_valid(M._state.current_win) then
        vim.api.nvim_set_current_win(M._state.current_win)
      else
        vim.command("vs")
        M._state.current_win = vim.api.nvim_get_current_win()
      end
      vim.api.nvim_set_current_buf(bufnr)
    end,
    { noremap = true, silent = true, buffer = ui._state.buffer }
  )

    vim.keymap.set(
    "n",
    "d",
    function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local bufnr = vim.iter(M._state.buf_list)
      :find(function(_, v)
        return v.line == cursor_line
      end)
      vim.api.nvim_buf_delete(bufnr, {})
    end,
    { noremap = true, silent = true, buffer = ui._state.buffer }
  )

end

M.draw = function()
  M._state.buf_list = list.get_buffers()
  local bufnr_table = {}
  local bufname_table = {}
  local buf_modified_table = {}

  for key in pairs(M._state.buf_list) do
    table.insert(bufnr_table, tostring(key))

    table.insert(bufname_table, vim.fs.basename(M._state.buf_list[key].name))

    table.insert(buf_modified_table, M._state.buf_list[key].modified and " ●" or "")
  end

  local key_column_width = M.get_column_width(bufnr_table)
  local name_column_width = M.get_column_width(bufname_table)
  local modified_column_width = M.get_column_width(buf_modified_table)

  local line_table = {}
  local hl_table = {}
  for i = 1, #bufnr_table do
    M._state.buf_list[tonumber(bufnr_table[i])].line = i
    local key = bufnr_table[i]
    local name = bufname_table[i]
    local modified = buf_modified_table[i]
    local key_padding = string.rep(" ", key_column_width - #key)
    local name_padding = string.rep(" ", name_column_width - #name)
    local modified_str = modified ~= "" and ("  " .. modified) or ""
    local modified_padding = string.rep(" ", modified_column_width - #modified_str + 3)
    local path = vim.fn.join(
      vim
        .iter(vim.fn.split(M._state.buf_list[tonumber(key)].name, "/"))
        :filter(function(v)
          return v ~= ""
        end):rev()
        :totable(),
      "/"
    )
    local line = key_padding .. key .. " " .. name .. name_padding .. modified_str .. modified_padding .. " " .. path

    local mod_path = modified_str .. modified_padding .. " " .. path

    local modified_pos = modified ~= "" and (vim.fn.strlen(line) - vim.fn.strlen(mod_path) + 3) or nil
    local path_pos = vim.fn.strlen(line) - vim.fn.strlen(path)

    if modified_pos then
      table.insert(hl_table, {
        line = i - 1,
        col_start = modified_pos,
        col_end = modified_pos + 1,
        hl_group = "Character",
      })
    end

    table.insert(hl_table, {
      line = i - 1,
      col_start = path_pos,
      col_end = -1,
      hl_group = "ModeMsg",
    })

    table.insert(line_table, line)
  end

  if ui._state.is_open then
    vim.api.nvim_set_option_value("wrap", false, {
      scope = "local",
    })
    vim.api.nvim_set_option_value("modifiable", true, {
      buf = ui._state.buffer,
    })
    vim.api.nvim_buf_set_lines(ui._state.buffer, 0, -1, false, line_table)

    vim.api.nvim_buf_clear_namespace(ui._state.buffer, ui._state.namespace, 0, -1)
    for _, hl in pairs(hl_table) do
      vim.api.nvim_buf_add_highlight(
        ui._state.buffer,
        ui._state.namespace,
        hl.hl_group,
        hl.line,
        hl.col_start,
        hl.col_end
      )
    end

    vim.api.nvim_set_option_value("modifiable", false, {
      buf = ui._state.buffer,
    })
  end
end

M.highlight_line = function(bufnr)
  if ui._state.is_open and bufnr ~= ui._state.buffer then
    local buf_line = M._state.buf_list[bufnr].line
    if not buf_line or not ui._state.winnr then
      return
    end

    -- vim.api.nvim_win_set_buf
    vim.api.nvim_win_set_cursor(ui._state.winnr, { M._state.buf_list[bufnr].line, 0 })
    -- vim.api.nvim_set_current_buf(bufnr)
  end
end

M.get_column_width = function(keys)
  local max = 0
  for _, key in pairs(keys) do
    if #key > max then
      max = #key
    end
  end
  return max
end

M.toggle = function()
  local is_open = ui.toggle()
  if is_open then
    M.draw()
  end
end

M.on_event = function(event)
  local is_valid_file = vim.api.nvim_get_option_value("buftype", {
    buf = event.buf,
  }) ~= "nofile"

  if ui._state.is_open and vim.api.nvim_buf_is_loaded(event.buf) and is_valid_file then
    vim.schedule(function()
      M.draw()
    end)
  end
end

M.on_buf_event = function(event)
  local is_valid_file = vim.api.nvim_get_option_value("buftype", {
    buf = event.buf,
  }) ~= "nofile"

  local exists = M._state.buf_list[event.buf] ~= nil
  if not exists then
    M.draw()
  end

  exists = M._state.buf_list[event.buf] ~= nil
  if ui._state.is_open and vim.api.nvim_buf_is_loaded(event.buf) and is_valid_file and exists then
    vim.schedule(function()
      M.highlight_line(event.buf)
    end)
  end
end

return M
