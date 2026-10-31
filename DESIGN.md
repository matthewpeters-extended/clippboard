# Paste: design style

Used by the landing site (`docs/`) and any future marketing material. The app itself follows macOS 26 conventions; this file is about how Paste presents itself.

## Idea

Paste is quiet, local and exact. It sits in the menu bar, does one thing, and gets out of the way. The look is **paper and ink with a single typing-caret accent**: calm and trustworthy, with one bright mark that echoes the thing the product does (text appearing at a cursor).

## Colour

One accent, used sparingly. Everything else is neutral and warm.

| Token | Light | Dark | Use |
|---|---|---|---|
| `--paper` | `#F6F3EC` | `#121214` | Page background |
| `--surface` | `#FFFFFF` | `#1B1B1F` | Cards, window mockups |
| `--ink` | `#16151A` | `#F2EFE8` | Headings, body text |
| `--ink-soft` | `#5E5B66` | `#A5A2AD` | Secondary text |
| `--line` | `#E1DCCF` | `#2B2B31` | Borders, dividers |
| `--caret` | `#FF5A1F` | `#FF7A45` | The accent: caret, primary button, key highlights |
| `--caret-ink` | `#FFFFFF` | `#16151A` | Text on the accent |
| `--keycap` | `#EDE8DB` | `#26262B` | Keycap face |

Rules:
- The accent appears at most a few times per screen: the caret, the primary button, links on hover, the active keycap.
- No purple and no decorative gradients. The one exception is the keyboard panel's faint grid lines (two linear-gradients on a warm tint: `#FFE2C2` light, `#6A4B2E` dark). Depth comes from borders and soft shadows, not colour.
- Text on `--paper` meets WCAG AA (`--ink` is about 16:1, `--ink-soft` about 5.6:1).
- Light and dark both ship; they follow the system setting.

## Typography

System fonts only. This matches the native feel, loads instantly, and means the site makes no requests to third parties, which fits a product whose promise is that it never touches the network.

- Display and body: `-apple-system, "SF Pro Display", "Inter", system-ui, sans-serif`
- Keys and code: `ui-monospace, "SF Mono", Menlo, monospace`
- Headline: 700, tight tracking (`-0.03em`), `clamp(2.4rem, 6vw, 4.5rem)`
- Body: 400, `1.0625rem` / 1.6
- Labels and eyebrows: mono, 600, uppercase, `0.75rem`, wide tracking

## Shape and space

- Radius: 10px small, 16px cards, 22px large panels. Nested corners get smaller as they go inward (concentric, like the macOS 26 popover).
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 80, 120.
- Content width 1040px; reading width 62ch. At least 20px side gutter at every width.
- Borders are 1px `--line`. Shadows are soft and low: `0 1px 2px` plus `0 12px 32px -12px`, both at low opacity.

## Signature elements

- **Keycap.** Combos are always drawn as keycaps: mono text, `--keycap` face, 1px border, a 2px darker bottom edge. This is the visual identity.
- **Caret.** A blinking 2px bar in `--caret`. It follows typed text in the hero demo and works as the logo mark's idea.
- **MacBook keyboard demo.** The hero centrepiece. A five-row keyboard (function row to arrows) built in JS inside a bordered tray, about 800px wide, sitting on the full-width grid panel. Keys light in `--caret` while a Combo is pressed. Input fields are stacked in one column beside the headline, outside the panel.
- **Header.** Brand, nav links (How it works, Who it's for, Privacy, Install), an orange Open Source link with the GitHub mark, Sign in, and a pill Download button with the Apple mark and a "D" keycap hint. Pill buttons throughout.
- **Window mockups.** Menu bar and popover drawn in CSS, not screenshots, so they stay sharp and match the theme. Swap in real screenshots later if wanted.

## Voice

- Plain and short. Say what it does, then stop.
- Use the product vocabulary from `CONTEXT.md`: **Binding**, **Combo**, **Text**, **Pause**. Avoid "shortcut", "hotkey", "snippet", "macro".
- Claims must be true today and checkable in the code: local file, no network, no clipboard use, one permission (Accessibility), no typing into password fields.
- No social proof (user counts, logos, testimonials) until it exists.

## Motion

- One piece of motion that matters: the hero demo. A field gains focus and a blinking orange caret, the Combo keys light, then the Text appears all at once (pasted, not typed) and the keys release before the next field. Keep it slow and unhurried.
- Respect `prefers-reduced-motion`: show the finished state, no blinking or typing.
