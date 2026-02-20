return {
  -- Treesitter — syntax highlighting, indentation, incremental selection
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "go", "gomod", "gosum", "gowork",
          "markdown", "markdown_inline",
          "lua", "json", "yaml", "dockerfile",
          "bash", "python", "toml",
          "diff", "gitcommit", "git_rebase",
        },
      })

      -- Incremental selection keymaps
      vim.keymap.set("n", "<C-space>", function()
        require("nvim-treesitter.incremental_selection").init_selection()
      end, { desc = "Init treesitter selection" })
      vim.keymap.set("v", "<C-space>", function()
        require("nvim-treesitter.incremental_selection").node_incremental()
      end, { desc = "Increment treesitter selection" })
      vim.keymap.set("v", "<bs>", function()
        require("nvim-treesitter.incremental_selection").node_decremental()
      end, { desc = "Decrement treesitter selection" })
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
