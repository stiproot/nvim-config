-- Netrw (file explorer) configuration
local g = vim.g

-- Split behavior: keep netrw in current window, open files in new split
g.netrw_altv = 1  -- When pressing 'v', split to the RIGHT
g.netrw_alto = 1  -- When pressing 'o', split BELOW

-- Additional netrw settings for better UX
-- TODO: These settings improve the netrw UX (tree view, no banner, etc.) but cause
-- netrw to open on Neovim startup showing "NetrwTreeListing [RO]" without rendering
-- the tree properly. Need to investigate why this happens and fix before re-enabling.
-- NOTE: liststyle = 3 provides nice tree view where Enter expands dirs instead of navigating into them
-- g.netrw_banner = 0        -- Hide the banner (press I to toggle)
-- g.netrw_liststyle = 3     -- Tree view by default
-- g.netrw_winsize = 25      -- Netrw window size (percentage)
