# Distribute as plain folders, not as a Claude Code plugin

Matt's repo ships as a Claude Code plugin (`.claude-plugin/plugin.json`) installable via `npx skills@latest add mattpocock/skills`. We don't. The warehouse is a **directory tree** the user copies, symlinks, or `cp -r`s from. More hackable, no plugin boilerplate, fits the "everything is files" library philosophy, and the user is the only consumer for now. The cost: no one-line installer, no plugin auto-update path. If multi-user distribution becomes a goal later, wrapping the same folders into a plugin is straightforward.
