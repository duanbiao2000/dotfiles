return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        codebook = {
          mason = false,
          enabled = false,
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
      },
    },
  },
}
