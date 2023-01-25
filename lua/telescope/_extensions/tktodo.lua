local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local utils = require("telescope.utils")
local sorters = require("telescope.sorters")
local make_entry = require("telescope.make_entry")
local api = vim.api

local M = {}
local tk_conf = require("telekasten").Cfg


return require("telescope").register_extension {
    exports = {
        todo = function(opts)
            opts = opts or {}
            opts.cwd = opts.cwd or vim.fn.getcwd()
            opts.notes_home = opts.notes_home or tk_conf.home

            local command = {"LWD=$(pwd) cd ~/notes; find . -iname '*.md' -print0 | xargs -0 grep -Hn '\\- \\[[ x]\\]'; cd $LWD"}


            pickers.new(opts, {
                prompt_title = "Todo",
                finder = finders.new_oneshot_job(command, opts),
                sorter = sorters.get_generic_fuzzy_sorter(),
                attach_mappings = function(func, map)
                    return 1
                end,
            }):find()
        end
    }
}
