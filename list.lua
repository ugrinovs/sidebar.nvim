local M = {}

local function is_buftype_valid(bufnr)
  return vim.api.nvim_get_option_value("buftype", {
    buf = bufnr,
  }) ~= "nofile"
end

M.get_buffers = function()
  local buffer_list = {}
  local buffers = vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):filter(is_buftype_valid)

  for bufnr in buffers do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      buffer_list[bufnr] = {
          bufnr = bufnr,
          name = name,
          basename = vim.fn.fnamemodify(name, ":t"),
          cwd = string.find(name, vim.fn.getcwd()),
          modified = vim.api.nvim_get_option_value("modified", {
            buf = bufnr,
          }),
      }
    end
  end

  return buffer_list
end

return M
