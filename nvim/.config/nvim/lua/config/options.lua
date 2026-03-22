-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"
-- 基础换行
vim.opt.wrap = true

-- 换行显示位置（避免单词断裂）
vim.opt.linebreak = true

-- 换行缩进对齐（保持原有缩进）
vim.opt.breakindent = true

-- 换行时的视觉提示符（可选）
vim.opt.showbreak = "↳ " -- 或用 "⤷ " / "... "

-- 列宽提示（80/120 列，可选）
-- vim.opt.colorcolumn = "120"

-- 把东亚字符从拼写检查中排除
vim.opt.spell = true
vim.opt.spelllang = { "en", "cjk" }

vim.opt.mouse = "a"
