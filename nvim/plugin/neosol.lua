local status_cb, cb = pcall(require, 'colorbuddy.init')
if not status_cb then
  vim.notify("colorbuddy not found, falling back to basic neosolarized", vim.log.levels.WARN)
  vim.cmd("silent! colorscheme neosolarized")
  return
end

local status_neo, n = pcall(require, "neosolarized")
if not status_neo then 
  vim.notify("neosolarized not found", vim.log.levels.ERROR)
  return 
end

n.setup({
  comment_italics = true,
  background_set = false
})

local Color = cb.Color
local colors = cb.colors
local Group = cb.Group
local groups = cb.groups
local styles = cb.styles

Color.new('white', '#ffffff')
Color.new('black', '#000000')

Group.new('Normal', colors.base1, colors.NONE, styles.NONE)
Group.new('CursorLine', colors.none, colors.base03, styles.NONE, colors.base1)
Group.new('CursorLineNr', colors.yellow, colors.black, styles.NONE, colors.base1)
Group.new('Visual', colors.none, colors.base03, styles.reverse)

vim.cmd("colorscheme neosolarized")
