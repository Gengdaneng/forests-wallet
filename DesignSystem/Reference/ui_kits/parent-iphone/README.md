# UI kit · 爸爸的 iPhone（家长端，唯一写入者）

Design width **393×852** (iPhone 15/16). Denser type scale, 48px targets, bottom tab bar with the honey 记一笔 tab raised.

Screens
- **首页** (`HomeScreen.jsx`) — Forrest's balance, the three entry actions (加进来 / 花掉了 / 更正), the pending Sunday settlement, goal, latest records. Entry buttons disable when offline and say so out loud: V1 writes require the server.
- **记一笔** (`EntryFlow.jsx`) — amount → 确认记录 → optional reason/category, with a 都跳过，直接记 escape. The success screen states 已记录 and 没有任何真实资金移动, and shows the visible-cost line for spends.
- **本周看板** (`OtherScreens.jsx → ParentBoard`) — tappable tri-state cells, back-fillable any time.
- **周日结算** (`ParentSettle`) — per-item arithmetic, all-done bonus, one confirm that writes a single transaction; the rule names and amounts are snapshotted into it.
- **规则管理** (`ParentRules`) — add/edit items and amounts; editing warns that a change note appears on Forrest's side.
- **全部记录** (`ParentHistory`) — immutable list; the reversal chain is explained in words.
- **设置** (`ParentSettings`) — paired devices, revoke, add device (6-digit code, 10 min, single use), Sunday reminder, PIN for the child-view preview, re-pair.

Deliberately absent, per the PRD: in-app CSV export, Face ID, offline writes, child-initiated requests, transaction photos.
