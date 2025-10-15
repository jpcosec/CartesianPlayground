-- config.lua
local config = {}

-- Colors (RGB normalized 0-1 in LOVE, not 0-255)
config.COLOR_WHITE = {1, 1, 1}
config.COLOR_BLACK = {0, 0, 0}
config.COLOR_DARK_GRAY = {0.27, 0.27, 0.27}
config.COLOR_LIGHT_GRAY = {0.78, 0.78, 0.78}
config.COLOR_BLUE = {0, 0, 1}
config.COLOR_RED = {1, 0, 0}
config.COLOR_CYAN = {0, 1, 1}

config.COLOR_FONT = {0, 0, 0}
config.SIZE_DISPLAY = {1200, 800}
config.SCREEN_WIDTH = 1200
config.SCREEN_HEIGHT = 800

-- Header
config.COLOR_BACKGROUND = {1, 1, 1}
config.COLOR_HEADER = {0.08, 0.08, 0.08}
config.HEADER_SIZE = 40
config.COLOR_BUTTON_HOVERED = config.COLOR_RED
config.COLOR_BUTTON_ACTIVE = config.COLOR_DARK_GRAY
config.COLOR_BUTTON_PASIVE = config.COLOR_LIGHT_GRAY

-- Grid
config.FONT_SIZE = 25
config.CELL_SIZE = 20

-- Sidebar
config.SIDEBAR_WIDTH = 200
config.SIDEBAR_COLOR = {0.95, 0.95, 0.95}
config.SIDEBAR_BORDER_COLOR = {0.5, 0.5, 0.5}

return config
