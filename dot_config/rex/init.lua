-- Rex configuration. Managed by chezmoi: edit this live file, then
-- `chezmoi re-add ~/.config/rex/init.lua`, then `rex config reload`.
--
-- The Rex SERVER reads this file, on the machine it runs on, and sends the
-- bindings to whichever app is attached. Keeping it in chezmoi gives every
-- host the same keys.

-- Keyboard shortcuts ----------------------------------------------------------
-- Moved here from the app's own shortcut settings (which win over this file,
-- so remove a key there before rebinding it here).
rex.bind("ctrl+shift+down", "client.tab.move.forward")
rex.bind("ctrl+shift+up", "client.tab.move.backward")
