# Forrest's Wallet — Design System

A family **virtual pocket-money ledger** and money-literacy app for one 7-year-old (Forrest) and one parent (Dad).
It records numbers only. It never holds, moves, or custodies real money — and the interface says so out loud.

Two surfaces, two different products:

| | Forrest | 爸爸 |
|---|---|---|
| Device | his own **iPad**, regular landscape | his own **iPhone** |
| Role | **strictly read-only** (enforced server-side) | the only writer |
| Job | "how much do I have now, and why did it change?" | log every increase, spend, correction and rule in ≤15 seconds |
| Density | two type steps larger, 54px targets, 24px card radius | compact, 48px targets, 16px card radius |

**The core contract:** the balance in the app equals the pocket money he really has, 1:1, and the parent has no veto. That single promise drives every design decision below — the ledger is additive-only, the balance is always the sum of the ledger, and an un-logged check-in day says "爸爸还没记", never "✗".

## Sources

Everything here was derived from one source, a product requirements document:

- **GitHub — https://github.com/Gengdaneng/forests-wallet** (branch `main`) — the repo contains a single file, `README.md`: the PRD v2 dated 2026-09-02 (70 confirmed decisions across six interview rounds). There is **no source code, no Figma file, no prototype, and no asset of any kind** in the repo. §11 视觉与语言 supplied the four brand colours, the type direction, the corner radii and the accessibility floors; §9 supplied the screen inventory; §5–§8 and §10 supplied the interaction and copy rules.
- Explore that repository further before building anything new against this system — the PRD is the authority, and it explains *why* each rule exists, which matters more than the rule.

Because the source shipped no design files, **everything visual in this system is an interpretation of the PRD's written direction** ("自然观察手账，不是儿童银行"). The four named colours, the radii, the touch-target floors and all copy patterns are quoted from it; the ramps, spacing scale, elevation, motion and component inventory are ours. Treat the former as fixed and the latter as revisable.

### No logo
The source contains no logo or brand mark. **None was invented.** Wherever a mark would go, the name is set in type — `--font-rounded`, weight 900, honey on spruce ink or spruce on paper. See `guidelines/brand-wordmark.html`. The app icon is an open item in the PRD (§17) and is meant to be chosen by Forrest.

### Font substitution — needs your input
The PRD specifies **SF Pro Rounded** (headings/numbers) and **SF Pro Text / 苹方** (body). Neither is redistributable, so the tokens prefer the real Apple faces (`ui-rounded`, `-apple-system`) and fall back to the nearest Google Fonts matches: **Nunito** (rounded, similar rounded terminals and generous numerals) and **Noto Sans SC** (Han). On an actual iOS device the real faces render. **If you have licensed files, drop them in `assets/fonts/` and we'll write real `@font-face` rules.**

---

## CONTENT FUNDAMENTALS

The product speaks two dialects. Getting them right matters more than any pixel here: the copy *is* the trust mechanism.

**Forrest's dialect** — ~800-word vocabulary, spoken sentences, second person, present tense, no jargon, no numbers he can't verify.

- "你现在有 87 元" — not "可用余额 ¥87.00"
- "钱为什么变了" — not "交易明细"
- "爸爸还没记这一格" — not "未打卡"
- "离你的目标又远了 15 元" — not "本次消费影响储蓄进度"
- "你现在欠爸爸 20 元" — not "账户透支"
- "我们把金额改对了" — not "记录已更新"
- "你可以买了" — not "目标达成 🎉"
- "正在显示已保存的信息" — not "网络异常"

**Dad's dialect** — short, factual, operational. Same honesty, less hand-holding: "已记录 · 没有任何真实资金移动", "没有写入任何记录", "6 位数字 · 10 分钟过期 · 用一次即作废".

**Hard rules**
1. Confirmations say **已记录**. They never say 已转账, 到账, 提现, or anything that implies money moved.
2. Never blame him. The rule list states condition → status → result. An unmet item reads 还没记 until Sunday settlement, then 未达成 — never 失败.
3. Money is written in **whole yuan with a ¥ sign and no decimals**, always with the sign that matches the direction (+ / − / ±).
4. Progress is written out as well as drawn: `已攒 ¥87 / ¥400` beside every bar.
5. No estimates of time ("还要 16 周"). Four months reads as *never* to a 7-year-old.
6. **No gamified praise.** Nothing congratulates him for opening the app, for a streak, or for looking at the ledger. The only celebration is money actually arriving.
7. Casing: Chinese throughout the product UI; the wordmark is the only Latin string. No ALL CAPS, no exclamation marks stacked, one sentence per line.
8. **Emoji**: used in exactly one place — the six fixed spend categories (🍦 吃的 · 🧸 玩具 · 🎮 游戏 · 📚 书和文具 · 🎁 送人的礼物 · ❓ 其他). Nowhere else. No mascot, no emoji in headings, buttons, or celebration copy.

Vibe: a quiet nature journal kept by two people, in which the numbers happen to be money.

---

## VISUAL FOUNDATIONS

**Direction** — 自然观察手账 (a natural-observation notebook), not a children's bank. Muted plant colours, sturdy rounded type, line drawings and paper. Explicitly banned: mascots, simulated credit cards, neon gamification, and anything resembling a financial institution's dashboard.

**Colour** — four named brand colours (`guidelines/color-brand.html`), each extended into a small ramp: spruce ink `#173D35` (dark grounds, primary actions, headings), new-leaf `#D8EDD5` (income, rules, completed cells), pocket-money honey `#F3C968` (savings goal, the one accent action), journal paper `#FBF7ED` (the app background — never pure white). Two derived signal colours: clay `#8C6A50` for outgoing (quiet on purpose) and berry `#BE3E2B` for negative balance (loud on purpose), plus a muted slate for system/offline messages so status never borrows a money colour. **At most two background colours per screen.** Direction is never carried by hue alone — every money state also carries a glyph and a word.

**Type** — `--font-rounded` for every heading and every number; `--font-text` for prose; `--font-mono` only for the running-balance column, where digits must align. Two scales: the child scale runs two steps larger than the parent scale, with 20px as the child body floor. The balance figure is 96px / weight 900 / tracking −0.02em, tabular numerals, occupying the top third of Forrest's home screen.

**Spacing & layout** — 4px base scale (`--space-1`…`--space-12`). Forrest's content is capped at a 720px column so lines stay short; the iPad uses a fixed 280px spruce sidebar in regular landscape and switches to a bottom tab bar with a single column in compact/split width rather than scaling down. The iPhone uses a 16px gutter and a fixed bottom tab bar. Fixed elements are exactly two per surface: the nav (sidebar or tab bar) and, on the entry sheet, the confirm button pinned to the bottom.

**Backgrounds** — flat paper. No photography, no full-bleed imagery, no gradient grounds, no illustration set (the source ships none — see ICONOGRAPHY). The only gradients in the system are the `--fade-top` / `--fade-bottom` protection fades used where content scrolls under fixed chrome; scrim capsules are not used.

**Cards** — a card is: warm off-white ground, 1px `--paper-300` hairline, and a short warm-tinted shadow (`0 1px 0 rgba(23,61,53,.04), 0 2px 6px rgba(23,61,53,.05)`). Paper, not glass. Radius 24px for Forrest, 16px for Dad, 10px for board cells, pill for status. Five grounds only: paper, sunken, leaf, honey, ink.

**Depth & transparency** — shadows are short, low-opacity, and tinted with spruce rather than black. Blur is not used anywhere: no frosted panels, no translucent nav. Transparency appears only as `rgba(251,247,237,.14)` for the active row inside the dark sidebar.

**Motion** — gentle and short: 120ms press, 200ms toggles and cell flips, 320ms sheet/screen, 520ms balance and progress-bar growth, 900ms for the one celebration. Standard easing `cubic-bezier(.2,.8,.2,1)`; `--ease-bounce` is reserved for income. Fades are paired with small movement, never used alone. Everything collapses to 0ms under `prefers-reduced-motion`, and the celebration becomes a static panel.

**Interaction states** — press: scale to 0.97 (0.95 on Forrest's side) plus one darker ramp step; hover (iPad pointer / desktop preview only): one ramp step darker, no hue change and no shadow lift; focus: 3px honey ring `--shadow-focus`; disabled: `--paper-300` ground with faint text and the reason stated in words next to it, never a bare greyed control.

**Borders** — hairlines are `--paper-300` at 1px; interactive borders are 1.5px so they survive the rounded shapes; the settlement total rule is a 2px spruce line, the one heavy line in the system. The un-logged board cell is the only dashed element — deliberately, so "empty" reads as unfinished rather than failed.

**Imagery colour vibe** — if imagery is ever introduced: warm, matte, low-contrast, daylight, slightly desaturated, no grain effects, no cool blue casts. Nothing has been added, because the source has none.

---

## ICONOGRAPHY

The source repository contains **no icons, no icon font, no sprite, and no SVG** — there is nothing to copy in. So the system standardises on **Lucide** (CDN, MIT), the closest match to the PRD's 线描 (line-drawing) direction, and this is a **flagged substitution**: swap it for the real set the moment one exists.

- Load: `<script src="https://unpkg.com/lucide@0.544.0/dist/umd/lucide.js"></script>`, then use the `Icon` component (or `data-lucide="name"` + `lucide.createIcons()` in plain HTML).
- Style: 2px stroke (2.4px for an active tab), `currentColor`, 24px default, 20px inline, 40px in empty states. No filled icons, no duotone, no shadowed icons.
- **Icons always carry text.** The one exception is navigation chrome (back/close), where `IconButton` requires an accessible `label`.
- Common names in use: `wallet`, `calendar-check`, `scroll-text`, `list`, `sparkles`, `target`, `arrow-down-left` (in), `arrow-up-right` (out), `rotate-ccw` (correction), `alert-triangle` (debt), `cloud-off` (offline), `shield-check` (no real money), `settings`, `tablet`, `smartphone`. See `guidelines/brand-icons.html`.
- **Emoji** are an icon system here, but only for the six spend categories, where a concrete glyph beats an abstract one for a 7-year-old. Unicode symbols are not used as icons; `+ − ±` appear only as part of money strings.
- No illustrations are included. The PRD asks for 线描与纸片插画 — none exist yet. **Do not draw them; request them.**

---

## Index

Root
- `styles.css` — the single entry point consumers link. `@import` lines only.
- `tokens/` — `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `radius.css`, `elevation.css`, `motion.css`, `base.css`
- `thumbnail.html` — homepage tile · `github.md` — upstream source record · `SKILL.md` — Agent Skills wrapper
- `guidelines/` — 25 specimen cards (Colors · Type · Spacing · Shape · Motion · Brand)

Components (`components/<group>/`, each with `.jsx`, `.d.ts`, `.prompt.md`, and one `@dsCard` HTML per group)
- **core** — `Icon`, `Button`, `IconButton`, `Card`, `Badge`, `Tag` (+ the exported `CATEGORIES` list)
- **money** — `AmountText` (+ `formatYuan`), `BalanceHero`, `TransactionRow`, `GoalProgress`, `CostHint`
- **ledger** — `WeekBoard` (+ `BoardCell`), `RuleRow`, `ChangeNote`, `SettlementSummary`
- **forms** — `NumberPad`, `AmountField`, `TextField`, `CategoryPicker`, `Toggle`
- **feedback** — `StatusBanner`, `EmptyState`, `Celebration`
- **navigation** — `NavHeader`, `Sidebar`, `TabBar`

UI kits (`ui_kits/`)
- `forrest-ipad/` — 1194×834, five read-only screens · `parent-iphone/` — 393×852, seven screens incl. the 3-tap entry flow · `data.js` — shared mock ledger

Templates (`templates/`) — the starting points consuming projects can copy
- `child-ipad/ChildIPad.dc.html` — Forrest's iPad home (balance, goal, recent ledger), tweakable balance / goal / offline state
- `parent-iphone/ParentIPhone.dc.html` — Dad's iPhone home (balance, three entry actions, goal, latest records)

**Component inventory rationale.** The source defines no component library, so this set was authored from the PRD's screen inventory (§9) and mechanics (§5–§8). Every component maps to something the PRD requires; there is no Toast, Avatar, Tabs, Modal or Tooltip, because nothing in the product needs one. Notable product-specific pieces: `WeekBoard` (tri-state, §5.3), `SettlementSummary` (§5.1), `CostHint` (§8.1), `ChangeNote` (§5.4), `Celebration` (income-only, §10), `StatusBanner` (trust states, §9.1).

**Intentional additions** (not named in the source): `Icon` — a wrapper around the substituted Lucide set so the stroke weight and pairing rule live in one place; `AmountText`/`formatYuan` — one place that enforces "cents in, whole yuan out"; `AmountField` — the display half of the keypad, implied by the entry flow but not specified.

No slide template was provided, so no sample slides were created.
