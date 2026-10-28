# iPhone and iPad compatibility

Kitchen Curator's native SwiftUI app targets **iOS/iPadOS 17+**.

## Platform requirements
- One universal iOS target with supported device families **iPhone and iPad** (Xcode `TARGETED_DEVICE_FAMILY = "1,2"`).
- iPhone: compact tab navigation, single-column recipe cards and cooking steps.
- iPad: sidebar + detail navigation, two-column recipe browser and spacious cooking mode.
- Dynamic Type, VoiceOver labels, portrait and landscape layouts, keyboard support on iPad.
- Local-first recipe storage with the same schema and import/export format on both platforms.

## Acceptance tests
- [ ] iPhone SE-sized simulator: no clipped controls or horizontal scrolling.
- [ ] Standard iPhone simulator: recipe create/edit/delete, ingredient checklist, shopping list.
- [ ] iPhone Pro Max simulator: portrait and landscape layouts.
- [ ] iPad mini simulator: sidebar navigation and recipe editing.
- [ ] iPad Air/Pro simulator: split-view and multitasking/resizable window behavior.
- [ ] Accessibility: largest text sizes, VoiceOver, high contrast.
- [ ] Import/export round-trip preserves recipe identifiers and ingredients.
- [ ] No feature is iPad-only or iPhone-only without an explicit reason.

These are **requirements**, not completed tests. The native app has not been built yet.
