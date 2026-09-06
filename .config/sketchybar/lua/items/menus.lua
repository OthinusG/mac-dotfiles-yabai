local colors = require("colors")
local settings = require("settings")

local menu_watcher = sbar.add("item", {
  drawing = false,
  updates = false,
})
local space_menu_swap = sbar.add("item", {
  drawing = false,
  updates = true,
})
sbar.add("event", "swap_menus_and_spaces")

local max_items = 15
local menu_items = {}
for i = 1, max_items, 1 do
  local menu = sbar.add("item", "menu." .. i, {
    padding_left = 3,
    padding_right = 3,
    drawing = "off",
    icon = { drawing = "off" },
    label = {
      color = i == 1 and colors.black or colors.white,
      font = {
        family = "SF Pro",
        style = i == 1 and "Heavy" or "Semibold",
        size = 13.0,
      },
      padding_left = 6,
      padding_right = 6,
    },
    background = {
      drawing = i == 1 and "on" or "off",
      color = colors.white,
      corner_radius = 7,
      height = 19,
    },
    click_script = settings.menu_binary .. " -s " .. i,
  })

  menu:subscribe("mouse.entered", function(_)
    menu:set({
      label = { color = colors.black },
      background = { drawing = "on" },
    })
  end)

  menu:subscribe("mouse.exited", function(_)
    menu:set({
      label = { color = i == 1 and colors.black or colors.white },
      background = { drawing = i == 1 and "on" or "off" },
    })
  end)

  menu_items[i] = menu
end

local function update_menus(env)
  sbar.exec(settings.menu_binary .. " -l", function(menus)
    sbar.set('/menu\\..*/', { drawing = "off" })
    local id = 1
    for menu in string.gmatch(menus, '[^\r\n]+') do
      if id < max_items then
        menu_items[id]:set({
          label = menu,
          drawing = "on",
          background = { drawing = id == 1 and "on" or "off" }
        })
      else break end
      id = id + 1
    end
  end)
end

menu_watcher:subscribe("front_app_switched", update_menus)

space_menu_swap:subscribe("swap_menus_and_spaces", function(env)
  local drawing = menu_items[1]:query().geometry.drawing == "on"
  if drawing then
    menu_watcher:set( { updates = false })
    sbar.set("/menu\\..*/", { drawing = "off" })
    sbar.set("/space\\..*/", { drawing = "on" })
    sbar.set("front_app", { drawing = "on" })
  else
    menu_watcher:set( { updates = true })
    sbar.set("/space\\..*/", { drawing = "off" })
    sbar.set("front_app", { drawing = "off" })
    update_menus()
  end
end)

return menu_watcher
