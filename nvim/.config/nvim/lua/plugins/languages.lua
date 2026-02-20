return {
  -- Language pack
  { "sheerun/vim-polyglot" },

  -- JSON support
  { "elzr/vim-json" },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    opts = {},
  },
}
