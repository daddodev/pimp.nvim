local M = {}

M.config = {
    run_on_start = true,
    watch = true,
    before_fn = nil,
    after_fn = nil
}

function M.setup(config)
    if config then
        M.config = vim.tbl_deep_extend("force", M.config, config)
    end

    if M.config.run_on_start or M.config.watch then
        vim.api.nvim_create_autocmd("UiEnter", {
            callback = function()
                if M.config.run_on_start then
                    M.apply_colors()
                end

                if M.config.watch then
                    require("pimp.file_watcher").watch(vim.fn.stdpath('config') .. "/pimp.conf", {
                        on_event = function()
                            vim.schedule(function()
                                M.apply_colors()
                            end)
                        end,
                    })
                end
            end,
        })
    end
end

local function parse_config(file_path)
    local config = {}
    local file = io.open(file_path, "r")

    if not file then
        vim.notify("pimp.conf not found in config directory", vim.log.levels.WARN)
        return config
    end

    for line in file:lines() do
        if line ~= "" then
            local key, value = line:match("([^=]+)%s*=%s*(.*)")


            if key and value then
                key = key:match("^%s*(.-)%s*$")
                value = value:match("^%s*(.-)%s*$")
                if value == "None" then
                    value = nil
                end

                local category, color_type = key:match("([^|]+)|(.*)")

                if category and color_type then
                    if not config[category] then
                        config[category] = {}
                    end

                    config[category][color_type] = value
                end
            end
        end
    end

    file:close()
    return config
end

local function set_highlights(config)
    for group, props in pairs(config) do
        vim.api.nvim_set_hl(0, group, props)
    end
end

function M.apply_colors()
    if M.config.before_fn then
        M.config.before_fn()
    end

    local config_path = vim.fn.stdpath("config") .. "/pimp.conf"
    local config = parse_config(config_path)
    set_highlights(config)

    if M.config.after_fn then
        M.config.after_fn()
    end

    vim.notify("pimp colors applied!", vim.log.levels.DEBUG)
end

vim.api.nvim_create_user_command("PimpReload", M.apply_colors, {})

return M
