local function env_color(name, fallback)
  return tonumber(os.getenv(name)) or fallback
end

local colors = {
  black = env_color("BACKGROUND", 0xff1a1c26),
  white = env_color("ACCENT_COLOR", 0xffffffff),
  red = 0xfffc5d7c,
  grey = 0xff7f8490,
  transparent = 0x00000000,
  bg1 = env_color("ITEM_BG_COLOR", 0xff353c3f),
  bg2 = env_color("BACKGROUND", 0xff1a1c26),
}

function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return colors
