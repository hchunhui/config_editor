local nk = require('nk.core')

--enum nk_heading
nk.UP = 0
nk.RIGHT = 1
nk.DOWN = 2
nk.LEFT = 3

--enum nk_button_behavior
nk.BUTTON_DEFAULT = 0
nk.BUTTON_REPEATER = 1

--enum nk_modify
nk.FIXED = 0
nk.MODIFIABLE = 1

--enum nk_orientation
nk.VERTICAL = 0
nk.HORIZONTAL = 1

--enum nk_collapse_states
nk.MINIMIZED = 0
nk.MAXIMIZED = 1

--enum nk_show_states
nk.HIDDEN = 0
nk.SHOWN = 1

--enum nk_chart_type
nk.CHART_LINES = 0
nk.CHART_COLUMN = 1
nk.CHART_MAX = 2

--enum nk_chart_event
nk.CHART_HOVERING = 0x01
nk.CHART_CLICKED = 0x02

--enum nk_color_format
nk.RGB = 0
nk.RGBA = 1

--enum nk_popup_type
nk.POPUP_STATIC = 0
nk.POPUP_DYNAMIC = 1

--enum nk_layout_format
nk.DYNAMIC = 0
nk.STATIC = 1

--enum nk_tree_type
nk.TREE_NODE = 0
nk.TREE_TAB = 1

--enum nk_symbol_type
nk.SYMBOL_NONE = 0
nk.SYMBOL_X = 1
nk.SYMBOL_UNDERSCORE = 2
nk.SYMBOL_CIRCLE_SOLID = 3
nk.SYMBOL_CIRCLE_OUTLINE = 4
nk.SYMBOL_RECT_SOLID = 5
nk.SYMBOL_RECT_OUTLINE = 6
nk.SYMBOL_TRIANGLE_UP = 7
nk.SYMBOL_TRIANGLE_DOWN = 8
nk.SYMBOL_TRIANGLE_LEFT = 9
nk.SYMBOL_TRIANGLE_RIGHT = 10
nk.SYMBOL_PLUS = 11
nk.SYMBOL_MINUS = 12
nk.SYMBOL_MAX = 13

--enum nk_text_align
nk.TEXT_ALIGN_LEFT        = 0x01
nk.TEXT_ALIGN_CENTERED    = 0x02
nk.TEXT_ALIGN_RIGHT       = 0x04
nk.TEXT_ALIGN_TOP         = 0x08
nk.TEXT_ALIGN_MIDDLE      = 0x10
nk.TEXT_ALIGN_BOTTOM      = 0x20

--enum nk_text_alignment
nk.TEXT_LEFT        = nk.TEXT_ALIGN_MIDDLE|nk.TEXT_ALIGN_LEFT
nk.TEXT_CENTERED    = nk.TEXT_ALIGN_MIDDLE|nk.TEXT_ALIGN_CENTERED
nk.TEXT_RIGHT       = nk.TEXT_ALIGN_MIDDLE|nk.TEXT_ALIGN_RIGHT

return nk
