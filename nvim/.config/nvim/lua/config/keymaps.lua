-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any addital keymaps here

local keymap = vim.keymap.set

-- 切换居中显示
keymap("n", "<leader>zz", function()
  local scrolloff = vim.opt.scrolloff:get()
  if scrolloff == 0 then
    vim.opt.scrolloff = 999
    vim.notify("居中显示 ON", vim.log.levels.INFO)
  else
    vim.opt.scrolloff = 0
    vim.notify("居中显示 OFF", vim.log.levels.INFO)
  end
end, { noremap = true, silent = true, desc = "Toggle center scroll" })
