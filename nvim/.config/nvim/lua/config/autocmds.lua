-- Filetype configurations
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.junos",
  command = "set filetype=junos",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*/configs/*",
  command = "set filetype=junos",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.py",
  command = "set filetype=python",
})

-- Systemd files
local systemd_patterns = {
  "*.automount", "*.mount", "*.path", "*.service",
  "*.socket", "*.swap", "*.target", "*.timer",
}
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = systemd_patterns,
  command = "set filetype=systemd",
})

-- Nginx files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "/opt/nginx/*", "/etc/nginx/*", "/usr/local/nginx/conf/*", "/usr/local/nginx/conf.d/*" },
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.filetype = "nginx"
    end
  end,
})

-- Ansible files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*/playbooks/*.yml",
  command = "set filetype=ansible",
})

-- Open file at last edited position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end,
})

-- Auto-detect indentation style
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local has_leading_tabs = vim.fn.search("^\\t", "nw") ~= 0
    local has_leading_spaces = vim.fn.search("^ \\{2,}", "nw") ~= 0

    if has_leading_tabs and not has_leading_spaces then
      vim.bo.expandtab = false
    elseif has_leading_spaces and not has_leading_tabs then
      local spaces_line = vim.fn.getline(vim.fn.search("^ \\+", "nw"))
      local spaces = vim.fn.matchstr(spaces_line, "^ \\+")
      if #spaces > 0 then
        vim.bo.shiftwidth = #spaces
        vim.bo.softtabstop = #spaces
      end
      vim.bo.expandtab = true
    end
  end,
})

-- Set paste toggle (deprecated in nvim, but keeping for compatibility)
if vim.fn.has("nvim-0.8") == 0 then
  vim.opt.pastetoggle = "<F5>"
end
