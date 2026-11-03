# 01: Core: Bindings, Pause and duplicate rejection

**What to build:** the `ClippboardCore` module with no macOS code in it. Given a pressed Combo, it returns the Text to type, or nothing. A Binding that is switched off returns nothing. While Paused, every Combo returns nothing. Adding a Binding with a Combo that another Binding already uses is rejected.

**Blocked by:** None (can start immediately).

**Status:** done

- [ ] A bound Combo returns its Text
- [ ] A switched-off Binding returns nothing
- [ ] While Paused, every Combo returns nothing
- [ ] A duplicate Combo is rejected
- [ ] Tests check behavior through the core's public interface only
