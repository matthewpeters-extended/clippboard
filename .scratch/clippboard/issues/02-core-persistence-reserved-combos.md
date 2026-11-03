# 02: Core: saving to a local file and system-Combo warning

**What to build:** Bindings survive quitting and restarting, stored in one local file with no network access. Combos the system already uses, such as Command+V and Command+C, are flagged so the UI can warn without blocking.

**Blocked by:** 01: Core: Bindings, Pause and duplicate rejection.

**Status:** done

- [ ] Bindings survive a save and reload (tested with the in-memory store)
- [ ] The file-backed store writes and reads one local file
- [ ] A system-reserved Combo is flagged but still allowed
- [ ] Nothing in the module touches the network
