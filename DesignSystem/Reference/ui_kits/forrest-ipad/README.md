# UI kit · Forrest 的 iPad（儿童端，严格只读）

Design width **1194×834** (11" iPad, regular landscape → sidebar navigation). In compact/split width the product switches to `TabBar` + single column instead of scaling this down (PRD §11).

Screens
- **我的钱 / Home** (`HomeScreen.jsx`) — balance hero (96px figure, top third), goal progress with the figures written out, last 5 ledger lines each showing the balance after, trust banner.
- **本周看板** (`DetailScreens.jsx → ChildBoard`) — tri-state grid plus the Sunday arithmetic he can add up himself.
- **规则** (`ChildRules`) — fixed weekly rules, "商量好的" ad-hoc list abbreviated to the latest 3, and the visible rule-change log.
- **全部流水** (`ChildLedger`) — full immutable ledger; reversed records stay, struck through.
- **已实现的心愿** (`ChildWishes`) — archived goals as real achievements, not badges.

Interaction notes
- The two buttons in the sidebar footer (offline / income) exist only to demo states. **The real child app has no controls, no sign-out, and no notifications.**
- The celebration plays for income only, and degrades to a static panel under `prefers-reduced-motion`.

Not built (absent from the source PRD): the pairing welcome page copy is described but not laid out; 阅读阶段分级 is an open item in §17.
