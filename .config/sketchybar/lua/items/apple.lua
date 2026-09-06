local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local apple = sbar.add("item", "apple", {
  icon = {
    font = { size = 16.0 },
    string = icons.apple,
    color = colors.black,
    padding_left = 7,
    padding_right = 7,
    y_offset = 2,
  },
  label = { drawing = false },
  background = {
    drawing = true,
    color = colors.white,
    corner_radius = 7,
    height = 19,
  },
  padding_left = 0,
  padding_right = 5,
  click_script = settings.menu_binary .. " -s 0"
})
