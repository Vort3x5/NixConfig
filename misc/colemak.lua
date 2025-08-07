-- Simple Colemak configuration for nvim

local M = {}

-- Store original keymaps so we can restore them
M.original_maps = {}

function M.setup()
    -- Clear any existing colemak mappings first
    M.disable()
    
    -- Core movement remapping (Colemak)
    -- m = left, n = down, e = up, i = right
    local movement_maps = {
        { {'n', 'x', 'o'}, 'm', 'h' },  -- left
        { {'n', 'x', 'o'}, 'n', 'j' },  -- down  
        { {'n', 'x', 'o'}, 'e', 'k' },  -- up
        { {'n', 'x', 'o'}, 'i', 'l' },  -- right
    }
    
    -- Insert mode remapping
    local insert_maps = {
        { 'n', 'u', 'i' },  -- u = insert
        { 'n', 'U', 'I' },  -- U = insert at beginning
    }
    
    -- Search remapping  
    local search_maps = {
        { {'n', 'x', 'o'}, 'k', 'n' },  -- k = next search
        { {'n', 'x', 'o'}, 'K', 'N' },  -- K = prev search
    }
    
    -- Undo remapping
    local undo_maps = {
        { 'n', 'l', 'u' },  -- l = undo
    }
    
    -- Page movement (dynamic)
    local page_maps = {
        { 'n', 'j', function() return (vim.api.nvim_win_get_height(0) - 1) .. '<C-u>' end, { expr = true } },
        { 'n', 'h', function() return (vim.api.nvim_win_get_height(0) - 1) .. '<C-d>' end, { expr = true } },
    }
    
    -- Visual mode line movement
    local visual_maps = {
        { 'v', 'N', ":m '>+1<CR>gv=gv" },  -- move selection down
        { 'v', 'E', ":m '<-2<CR>gv=gv" },  -- move selection up
    }
    
    -- Apply all mappings
    local all_maps = {}
    vim.list_extend(all_maps, movement_maps)
    vim.list_extend(all_maps, insert_maps) 
    vim.list_extend(all_maps, search_maps)
    vim.list_extend(all_maps, undo_maps)
    vim.list_extend(all_maps, page_maps)
    vim.list_extend(all_maps, visual_maps)
    
    for _, map in ipairs(all_maps) do
        local modes, lhs, rhs, opts = map[1], map[2], map[3], map[4] or {}
        
        -- Store original mapping for restoration
        for _, mode in ipairs(type(modes) == 'table' and modes or {modes}) do
            local key = mode .. ':' .. lhs
            if not M.original_maps[key] then
                local original = vim.fn.maparg(lhs, mode, false, true)
                M.original_maps[key] = original
            end
        end
        
        -- Set new mapping
        vim.keymap.set(modes, lhs, rhs, opts)
    end
    
    vim.notify("✓ Colemak mappings enabled", vim.log.levels.INFO)
end

function M.disable()
    -- Restore original mappings
    for key, original_map in pairs(M.original_maps) do
        local mode, lhs = key:match("([^:]+):(.+)")
        if mode and lhs then
            pcall(vim.keymap.del, mode, lhs)
            
            -- Restore original if it existed
            if original_map and original_map.lhs then
                vim.keymap.set(mode, original_map.lhs, original_map.rhs or original_map.callback, {
                    noremap = original_map.noremap == 1,
                    silent = original_map.silent == 1,
                    expr = original_map.expr == 1,
                    desc = original_map.desc,
                })
            end
        end
    end
    
    M.original_maps = {}
    vim.notify("✓ Colemak mappings disabled", vim.log.levels.INFO)
end

-- Auto-setup when required
M.setup()

return M
