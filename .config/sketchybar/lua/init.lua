local config_dir = assert(os.getenv("CONFIG_DIR"), "CONFIG_DIR is not set")

package.path = config_dir .. "/lua/?.lua;"
  .. config_dir .. "/lua/?/init.lua;"
  .. package.path
package.cpath = package.cpath
  .. ";/Users/"
  .. assert(os.getenv("USER"), "USER is not set")
  .. "/.local/share/sketchybar_lua/?.so"

sbar = require("sketchybar")

sbar.begin_config()
require("items.apple")
require("items.menus")
require("items.spaces")
require("items.front_app")
sbar.end_config()

local left_items = {
  "apple",
}
for i = 1, 15 do table.insert(left_items, "menu." .. i) end
for i = 1, 10 do
  table.insert(left_items, "space." .. i)
end
table.insert(left_items, "spaces_indicator")
table.insert(left_items, "front_app")

local moves = {}
for _, name in ipairs(left_items) do
  table.insert(moves, " --move " .. name .. " before weather")
end
sbar.exec("sketchybar" .. table.concat(moves))

sbar.event_loop()
