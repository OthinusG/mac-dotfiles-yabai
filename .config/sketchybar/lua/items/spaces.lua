local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local occupied_spaces = {}
local selected_spaces = {}
local switch_icons = { on = "􁏮", off = "􁏯" }

local function set_space_visibility(space_id, visible)
  spaces[space_id]:set({
    icon = { drawing = visible },
    label = { drawing = visible },
    padding_right = visible and 5 or 0,
    width = visible and "dynamic" or 0,
  })
end

for i = 1, 10, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    width = 0,
    icon = {
      drawing = false,
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 7,
      padding_right = 4,
      color = colors.white,
    },
    label = {
      drawing = false,
      padding_right = 7,
      color = colors.white,
      font = "sketchybar-app-font:Regular:13.0",
    },
    padding_left = 0,
    padding_right = 0,
    background = {
      drawing = false,
      color = colors.white,
      corner_radius = 7,
      height = 19,
    },
    popup = { background = { border_color = colors.black } }
  })

  spaces[i] = space
  local selected = false

  local function set_inverted(inverted)
    space:set({
      icon = { color = inverted and colors.black or colors.white },
      label = { color = inverted and colors.black or colors.white },
      background = { drawing = inverted and "on" or "off" }
    })
  end

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left= 5,
    padding_right= 0,
    background = {
      drawing = true,
      image = {
        corner_radius = 9,
        scale = 0.2
      }
    }
  })

  space:subscribe("space_change", function(env)
    selected = env.SELECTED == "true"
    selected_spaces[i] = selected
    set_inverted(selected)
    set_space_visibility(i, selected or occupied_spaces[i])
  end)

  space:subscribe("mouse.entered", function(_)
    set_inverted(true)
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      space_popup:set({ background = { image = "space." .. env.SID } })
      space:set({ popup = { drawing = "toggle" } })
    else
      local op = (env.BUTTON == "right") and "--destroy" or "--focus"
      sbar.exec("yabai -m space " .. op .. " " .. env.SID)
    end
  end)

  space:subscribe("mouse.exited", function(_)
    set_inverted(selected)
    space:set({ popup = { drawing = false } })
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

local spaces_indicator = sbar.add("item", "spaces_indicator", {
  padding_left = 0,
  padding_right = 5,
  icon = {
    font = { family = "SF Pro", style = "Semibold", size = 15.0 },
    padding_left = 4,
    padding_right = 7,
    color = colors.white,
    string = switch_icons.on,
  },
  label = {
    drawing = "off",
  },
  background = {
    drawing = "off",
    color = colors.white,
    corner_radius = 7,
    height = 19,
  }
})

space_window_observer:subscribe("space_windows_change", function(env)
  local icon_line = ""
  local no_app = true
  for app, count in pairs(env.INFO.apps) do
    no_app = false
    local lookup = app_icons[app]
    local icon = ((lookup == nil) and app_icons["Default"] or lookup)
    icon_line = icon_line .. icon .. "  "
  end

  local space_id = env.INFO.space
  occupied_spaces[space_id] = not no_app
  sbar.animate("tanh", 10, function()
    spaces[space_id]:set({ label = { string = icon_line } })
    set_space_visibility(space_id, occupied_spaces[space_id] or selected_spaces[space_id])
  end)
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(_)
  local showing_spaces = spaces_indicator:query().icon.value == switch_icons.on
  spaces_indicator:set({
    icon = { string = showing_spaces and switch_icons.off or switch_icons.on }
  })
end)

spaces_indicator:subscribe("mouse.entered", function(_)
  spaces_indicator:set({
    icon = { color = colors.black },
    background = { drawing = "on" }
  })
end)

spaces_indicator:subscribe("mouse.exited", function(_)
  spaces_indicator:set({
    icon = { color = colors.white },
    background = { drawing = "off" }
  })
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
