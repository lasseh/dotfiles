return {
  -- Treesitter — parser installation (highlighting/indent are Neovim 0.12 built-ins)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ts = require("nvim-treesitter")
      if ts.install then
        ts.install({
          "go", "gomod", "gosum", "gowork",
          "typescript", "tsx", "javascript",
          "markdown", "markdown_inline",
          "lua", "json", "yaml", "dockerfile",
          "bash", "python", "toml",
          "diff", "gitcommit", "git_rebase",
        })
      end

      -- Enable treesitter highlighting and indentation for all installed parsers
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection keymaps (Neovim 0.12 built-in)
      vim.keymap.set("n", "<C-space>", function()
        vim.treesitter.select_parent(1)
      end, { desc = "Init treesitter selection" })
      vim.keymap.set("v", "<C-space>", function()
        vim.treesitter.select_parent(1)
      end, { desc = "Expand treesitter selection" })
      vim.keymap.set("v", "<bs>", function()
        vim.treesitter.select_child(1)
      end, { desc = "Shrink treesitter selection" })
    end,
  },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    ft = "markdown",
    opts = {},
  },
}
