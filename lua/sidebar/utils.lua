
local M = {

}
function M.is_nvim_sidebar_buf(bufnr)
  if bufnr == nil then
    bufnr = 0
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.fnamemodify(bufname, ":t"):match("NvimSidebar") then
      if vim.bo[bufnr].filetype == "NvimSidebar" then
        return true
      elseif vim.fn.filereadable(bufname) == 0 then
        return true
      end
    end
  end
  return false
end

return M
