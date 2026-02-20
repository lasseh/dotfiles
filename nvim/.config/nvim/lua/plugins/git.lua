return {
  -- Git gutter signs
  {
    "airblade/vim-gitgutter",
    config = function()
      vim.g.gitgutter_sign_added = "∙"
      vim.g.gitgutter_sign_modified = "∙"
      vim.g.gitgutter_sign_removed = "∙"
      vim.g.gitgutter_sign_modified_removed = "∙"
      vim.g.gitgutter_realtime = 0
      vim.g.gitgutter_eager = 0
      vim.g.gitgutter_map_keys = 0
      vim.g.gitgutter_max_signs = 500
      vim.opt.signcolumn = "yes"
    end,
  },

  -- NeoGit
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit kind=floating<cr>", desc = "Show Neogit UI" },
    },
  },
}
