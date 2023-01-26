
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")

------------------------------------------------------------------------------------
-- begin https://stackoverflow.com/a/43582076

-- gsplit: iterate over substrings in a string separated by a pattern
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
local function gsplit(text, pattern, plain)
  local splitStart, length = 1, #text
  return function ()
    if splitStart then
      local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
      local ret
      if not sepStart then
        ret = string.sub(text, splitStart)
        splitStart = nil
      elseif sepEnd < sepStart then
        -- Empty separator!
        ret = string.sub(text, splitStart, sepStart)
        if sepStart < length then
          splitStart = sepStart + 1
        else
          splitStart = nil
        end
      else
        ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
        splitStart = sepEnd + 1
      end
      return ret
    end
  end
end

-- split: split a string into substrings separated by a pattern.
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: table (a sequence table containing the substrings)
local function split(text, pattern, plain)
  local ret = {}
  for match in gsplit(text, pattern, plain) do
    table.insert(ret, match)
  end
  return ret
end

-- end https://stackoverflow.com/a/43582076
--------------------------------------------------------------------------------


local replace_command_string = [[awk -i inplace 'BEGIN { ROI = %s }; NR == ROI  { if ( $0 ~ " \\- \\[ \\] " ) { sub( " \\- \\[ \\]", " - [x]", $0 ); print $0 } else { gsub( " \\- \\[x\\]", " - [ ]", $0 ); print $0 } }; NR != ROI { print $0 }' %s]]

local todo_picker = function(opts)
    local command = {'grep', '-rHn', '\\- \\[[ x]\\]', opts.notes_home }
    return pickers.new(opts, {
        prompt_title = "Todo",
        finder = finders.new_oneshot_job(command, opts),
        sorter = sorters.get_generic_fuzzy_sorter(),

        attach_mappings = function(prompt_bufnr, map)
            local toggle_todo = function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selections = picker:get_multi_selection()
                if next(selections) == nil then
                    selections = {picker:get_selection()}
                end

                actions.close(prompt_bufnr)

                local tasks = {}
                for _, t in ipairs(selections) do
                    table.insert(tasks, t[1])
                    local tsk = split(t[1],':',true)
                    local replace_command = string.format(replace_command_string, tsk[2], tsk[1])
                    io.popen(replace_command)
                end
            end

            map('i', '<CR>', toggle_todo)
            map('n', '<CR>', toggle_todo)

            return true
        end,
    })
end

local find_todo = function(opts)
    opts = opts or {}
    local tk_conf = require("telekasten").Cfg
    -- opts.cwd = opts.cwd or vim.fn.getcwd()
    opts.notes_home = opts.notes_home or tk_conf.home

    local tdpicker = todo_picker(opts)
    tdpicker:find()
end

return require("telescope").register_extension {
    exports = {
        todo = function(opts)
            find_todo(opts)
        end
    }
}


