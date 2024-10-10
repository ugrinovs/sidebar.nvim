---@alias nui_split_option_relative_type 'editor'|'win'
---@alias nui_split_option_relative { type: nui_split_option_relative_type, winid?: number }
---@alias nui_split_option_position "'top'"|"'right'"|"'bottom'"|"'left'"
---@alias nui_split_option_size { height?: number|string }|{ width?: number|string }
---@alias _nui_split_internal_relative { type: nui_split_option_relative_type, win: number }
---@alias _nui_split_internal_win_config { height?: number, width?: number, position: nui_split_option_position, relative: nui_split_option_relative, win?: integer, pending_changes: table<'position'|'size', boolean> }

---
---@class NuiSplitOptions
---@field ns_id? string|integer
---@field relative? nui_split_option_relative_type|nui_split_option_relative
---@field position? nui_split_option_position
---@field size? number|string|nui_split_option_size
---@field enter? boolean
---@field buf_options? table<string, any>
---@field win_options? table<string, any>

---@alias Mount fun(): nil
---@alias Show fun(): nil
---@alias Hide fun(): nil

---@class NuiSplit
---@field bufnr integer
---@field ns_id integer
---@field winid number
---@field mount Mount
---@field show Show
---@field hide Hide
