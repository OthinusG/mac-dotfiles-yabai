local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = { drawing = false },
  label = {
    color = colors.black,
    padding_left = 7,
    padding_right = 7,
    font = {
      style = settings.font.style_map["Black"],
      size = 13.0,
    },
  },
  padding_left = 0,
  padding_right = 5,
  background = {
    drawing = true,
    color = colors.white,
    corner_radius = 7,
    height = 19,
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)

front_app:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
