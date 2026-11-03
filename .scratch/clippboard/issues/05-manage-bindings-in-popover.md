# 05: Manage Bindings in the popover

**What to build:** from the popover I can add, edit and delete a Binding (label, Combo, Text). Each Binding has its own on/off switch, and there is a Pause switch. The menu bar icon looks different while Paused. Duplicate-Combo rejections and system-Combo warnings show inline. Bindings persist across restarts.

**Blocked by:** 02: Core: saving to a local file and system-Combo warning; 04: Key recorder field.

**Status:** done

- [ ] Add, edit and delete a Binding with label, Combo and Text
- [ ] Per-Binding on/off switch
- [ ] Pause switch, with the icon showing the Paused state
- [ ] A duplicate Combo shows a clear message and is not saved
- [ ] A system-reserved Combo shows a warning but can still be saved
- [ ] Bindings are still there after quitting and reopening
