/* Shared mock ledger for both UI kits. Cents in, whole yuan out. */
window.FWData = {
  goal: { title: '乐高赛车', targetCents: 40000 },
  balanceCents: 8700,
  tx: [
    { id: 9, reason: '本周基础零花钱', cents: 1000, direction: 'in',  date: '10月5日', balanceAfter: 8700 },
    { id: 8, reason: '帮忙搬水',      cents: 200,  direction: 'in',  date: '10月4日', balanceAfter: 7700 },
    { id: 7, reason: '买冰淇淋',      cents: 1500, direction: 'out', date: '10月3日', category: 'food', balanceAfter: 7500 },
    { id: 6, reason: '更正：记错了',   cents: 300,  direction: 'fix', date: '10月2日', balanceAfter: 9000 },
    { id: 5, reason: '乐高小车',      cents: 1400, direction: 'out', date: '10月2日', category: 'toy', balanceAfter: 8700, reversed: true },
    { id: 4, reason: '画笔',          cents: 900,  direction: 'out', date: '9月30日', category: 'book', balanceAfter: 10100 },
    { id: 3, reason: '上周基础零花钱', cents: 1500, direction: 'in',  date: '9月28日', balanceAfter: 11000 },
    { id: 2, reason: '送同学生日礼物', cents: 2000, direction: 'out', date: '9月26日', category: 'gift', balanceAfter: 9500 },
    { id: 1, reason: '期初余额',      cents: 11500,direction: 'in',  date: '9月20日', balanceAfter: 11500 },
  ],
  board: [
    { name: '跳绳',     goal: 5, rewardCents: 500, days: ['done','done','done','unlogged','future','future','future'] },
    { name: '喝牛奶',   goal: 7, rewardCents: 500, days: ['done','done','unlogged','future','future','future','future'] },
    { name: '上学全勤', goal: 5, rewardCents: 500, days: ['done','done','done','unlogged','future','future','future'] },
  ],
  rules: [
    { name: '跳绳',   detail: '每周 5 次', rewardCents: 500, kind: 'base' },
    { name: '喝牛奶', detail: '每周 7 次', rewardCents: 500, kind: 'base' },
    { name: '上学全勤', detail: '每周 5 天', rewardCents: 500, kind: 'base' },
    { name: '三项全达成奖励', detail: '三项都做到才有', rewardCents: 300, kind: 'base' },
  ],
  adhoc: [
    { name: '帮忙搬水',     detail: '10月4日 · 商量好的', rewardCents: 200, kind: 'adhoc' },
    { name: '主动整理书桌', detail: '9月29日 · 商量好的', rewardCents: 300, kind: 'adhoc' },
    { name: '帮妈妈拿快递', detail: '9月24日 · 商量好的', rewardCents: 100, kind: 'adhoc' },
  ],
  changes: [
    { text: '从 10 月 1 日起，跳绳从 5 元变成 3 元', date: '10月1日 · 和爸爸一起决定的' },
    { text: '加了新的一项：上学全勤，做到有 5 元',   date: '9月21日 · 和爸爸一起决定的' },
  ],
  wishes: [
    { title: '恐龙拼图',   cents: 6800,  date: '8月17日 攒到' },
    { title: '水彩笔一套', cents: 4500,  date: '7月2日 攒到' },
  ],
};
