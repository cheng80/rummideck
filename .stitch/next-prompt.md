---
page: game_mvp
---
Create the core MVP gameplay screen for a portrait mobile roguelike score-building game inspired by rummikub combinations and balatro-style scaling. This is the most important screen in the product and must feel playable, readable, and strategically dense without becoming visually messy.

**DESIGN SYSTEM (REQUIRED):**
- Platform: Mobile, portrait-first game UI
- Theme: cosmic arcade, high-contrast tactical HUD, readable roguelike score-building interface
- Background: layered deep-space gradient using Deep Space Navy (#08111F) and Void Blue (#10233A)
- Primary Accent: Electric Cyan (#3CAEE0) for main actions, selected state, and active controls
- Secondary Accent: Signal Violet (#7E57C2) for secondary actions and utility controls
- Score Accent: Score Gold (#FFD54F) for current score, target score, and high-value feedback
- Warning Accent: Danger Coral (#FF6B6B) for low resources and failure pressure
- Success Accent: Success Mint (#63E6BE) for valid combo and positive state
- Surfaces: dark translucent glass panels with soft highlights and generous rounded corners
- Buttons: large thumb-friendly capsule or rounded rectangle buttons with bold labels
- Tiles: highly readable ivory tile surfaces with strong number and color contrast
- Anomaly Slots: energy-core-like modules, more premium and mechanical than regular tiles
- Typography: bold arcade display for titles and key numbers, clean sans-serif for support text
- Layout: fixed top HUD, central anomaly/combo zone, bottom hand and action zone
- Mood: strategic, readable, energetic, slightly retro, never cluttered

**Game Rules Context:**
- Hand size is always 8 tiles
- Core combos are Triple, Straight, Quad, Color Straight, Long Straight
- Player has 3 anomaly slots
- Score is built from Chips, Mult, and XMult
- This screen should communicate current run state, not a menu

**Page Structure:**
1. **Top HUD:** Stage number, current score, target score, plays left, discards left, gold, and current seed string.
2. **Anomaly Zone:** Three anomaly modules in the middle upper area, each looking like a passive build engine rather than a simple card.
3. **Combo Preview Panel:** Show currently selected combo name, a small chips/mult/xmult breakdown, and expected score preview.
4. **Playfield Information Layer:** Add subtle secondary information such as current build direction, example tags like `Straight Build` or `Triple Engine`, and status indicators for valid selection.
5. **Hand Zone:** Eight clearly readable tile buttons near the bottom. Use color plus number notation such as `R7`, `B5`, `Y10`, `K3`. Make them easy to tap and easy to scan.
6. **Action Row:** A strong primary `Submit` button and a secondary `Discard` button in the thumb zone. Make their roles immediately distinguishable.

**Important Constraints:**
- Do not design this like a generic fantasy card battler
- Do not use horizontal desktop dashboard patterns
- Avoid clutter and tiny text
- Keep the score hierarchy extremely clear
- Make the hand of 8 tiles feel like the main input surface
- The middle of the screen should help the player understand build direction and score scaling
