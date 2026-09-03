const { WeekBoard, SettlementSummary, RuleRow, ChangeNote, TransactionRow, Card, Button, NavHeader, Toggle, StatusBanner, Badge, TextField, Icon, AmountText, Celebration } = window.ForrestSWalletDesignSystem_2e3ae3;

/* Today is Thursday in the mock week: days 0–3 are loggable, 4–6 are still 未到. */
const TODAY = 3;
const freshDays = () => Array.from({ length: 7 }, (_, i) => (i <= TODAY ? 'unlogged' : 'future'));

/* Add / rename / delete a check-in item, and edit its weekly target and amount.
   Rules are editable by design (PRD §5.4) — the set grows as Forrest gets older.
   There is no rule versioning: settlement snapshots the name and amount into the
   transaction, and every change leaves a note on Forrest's side. */
function ItemEditor({ item, onSave, onDelete, onCancel }) {
  const [name, setName] = React.useState(item.name || '');
  const [goal, setGoal] = React.useState(String(item.goal ?? 5));
  const [yuan, setYuan] = React.useState(String(Math.round((item.rewardCents ?? 500) / 100)));
  const isNew = !item.name;
  const valid = name.trim() && parseInt(goal, 10) > 0 && parseInt(goal, 10) <= 7 && parseInt(yuan, 10) >= 0;
  return (
    <Card tone="sunken">
      <div style={{ display: 'grid', gap: 'var(--space-4)' }}>
        <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-head-size)' }}>{isNew ? '加一项打卡' : '改「' + item.name + '」'}</div>
        <TextField label="打卡项名称" placeholder="例如：练琴" value={name} onChange={setName} maxLength={6} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-4)' }}>
          <TextField label="每周目标次数" value={goal} onChange={(v) => setGoal(v.replace(/\D/g, '').slice(0, 1))} />
          <TextField label="做到给多少（元）" value={yuan} onChange={(v) => setYuan(v.replace(/\D/g, '').slice(0, 3))} />
        </div>
        <StatusBanner size="parent" kind="norealmoney" text={isNew ? '新加的项从这周开始算，Forrest 的规则页会出现一条记录' : '改完会在 Forrest 的规则页留一条变更记录'} />
        <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
          <Button tone="primary" block disabled={!valid} onClick={() => onSave({ name: name.trim(), goal: parseInt(goal, 10), rewardCents: parseInt(yuan, 10) * 100 })}>保存</Button>
          <div style={{ display: 'grid', gridTemplateColumns: onDelete ? '1fr 1fr' : '1fr', gap: 'var(--space-3)' }}>
            <Button tone="quiet" block onClick={onCancel}>取消</Button>
            {onDelete ? <Button tone="danger" icon="trash-2" block onClick={onDelete}>删掉这项</Button> : null}
          </div>
        </div>
      </div>
    </Card>
  );
}

function ParentBoard({ items, setItems, bonusCents, setBonusCents }) {
  const [editing, setEditing] = React.useState(null); // index, or 'new'
  const [bonusEdit, setBonusEdit] = React.useState(false);
  const [bonusDraft, setBonusDraft] = React.useState(String(Math.round(bonusCents / 100)));
  const toggle = (r, c) => setItems((b) => b.map((row, i) => i !== r ? row : ({ ...row, days: row.days.map((s, j) => j !== c ? s : s === 'done' ? 'unlogged' : 'done') })));
  const total = items.reduce((s, it) => s + (it.days.filter((d) => d === 'done').length >= it.goal ? it.rewardCents : 0), 0);

  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <h1 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>本周看板</h1>
        <Button size="small" tone="accent" icon="plus" onClick={() => setEditing('new')}>加一项</Button>
      </div>

      <Card><WeekBoard size="parent" items={items} onToggle={toggle} weekLabel="10月1日 – 10月7日" /></Card>
      <StatusBanner size="parent" kind="norealmoney" text="随时可以补勾 · 只有周日结算才会算成未达成" />

      <Card>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 'var(--space-3)' }}>
          <h2 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-head-size)' }}>这些项目和金额</h2>
          <Badge tone="neutral" icon="pencil-line">可以改</Badge>
        </div>
        {items.map((it, i) => (
          <RuleRow key={it.name + i} size="parent" name={it.name} detail={'每周 ' + it.goal + ' 次 · 已做到 ' + it.days.filter((d) => d === 'done').length + ' 次'}
            rewardCents={it.rewardCents} onClick={() => setEditing(i)} />
        ))}
        <div onClick={() => setBonusEdit(true)} style={{ display: 'flex', alignItems: 'center', gap: 12, minHeight: 'var(--touch-parent)', cursor: 'pointer' }}>
          <Icon name="gift" size={18} color="var(--honey-700)" />
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-body-size)' }}>全部达成奖励</div>
            <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{items.length} 项都做到才有</div>
          </div>
          <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontVariantNumeric: 'tabular-nums', fontSize: 'var(--type-amount-sm-size)', color: 'var(--honey-700)' }}>¥{Math.round(bonusCents / 100)}</span>
          <Icon name="chevron-right" size={18} color="var(--text-faint)" />
        </div>
        <div style={{ marginTop: 'var(--space-4)', paddingTop: 'var(--space-4)', borderTop: '2px solid var(--spruce-700)', display: 'flex', alignItems: 'baseline', gap: 10 }}>
          <span style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: 'var(--type-head-size)' }}>按现在的进度，本周</span>
          <AmountText cents={total} direction="in" />
        </div>
      </Card>

      {editing === 'new' ? (
        <ItemEditor item={{}} onCancel={() => setEditing(null)}
          onSave={(v) => { setItems((b) => [...b, { ...v, days: freshDays() }]); setEditing(null); }} />
      ) : editing !== null ? (
        <ItemEditor item={items[editing]} onCancel={() => setEditing(null)}
          onSave={(v) => { setItems((b) => b.map((row, i) => i !== editing ? row : { ...row, ...v })); setEditing(null); }}
          onDelete={() => { setItems((b) => b.filter((_, i) => i !== editing)); setEditing(null); }} />
      ) : null}

      {bonusEdit ? (
        <Card tone="sunken">
          <div style={{ display: 'grid', gap: 'var(--space-4)' }}>
            <TextField label="全部达成奖励（元）" value={bonusDraft} onChange={(v) => setBonusDraft(v.replace(/\D/g, '').slice(0, 3))} />
            <StatusBanner size="parent" kind="norealmoney" text="分项计分 + 全勤奖：漏一项不会归零，坚持到底另有价值" />
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-3)' }}>
              <Button tone="quiet" block onClick={() => setBonusEdit(false)}>取消</Button>
              <Button tone="primary" block onClick={() => { setBonusCents((parseInt(bonusDraft, 10) || 0) * 100); setBonusEdit(false); }}>保存</Button>
            </div>
          </div>
        </Card>
      ) : null}
    </div>
  );
}

function ParentSettle({ onConfirm, done, items, bonusCents }) {
  const lines = items.map((it) => {
    const doneCount = it.days.filter((d) => d === 'done').length;
    return { name: it.name, goal: it.goal, doneCount, rewardCents: it.rewardCents, met: doneCount >= it.goal };
  });
  const bonusMet = lines.length > 0 && lines.every((l) => l.met);
  const total = lines.reduce((s, l) => s + (l.met ? l.rewardCents : 0), 0) + (bonusMet ? bonusCents : 0);
  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>周日结算</h1>
      {done ? <Celebration cents={total} reason="本周基础零花钱 · 已入账" /> : null}
      <Card><SettlementSummary size="parent" lines={lines} bonus={{ rewardCents: bonusCents, met: bonusMet }} /></Card>
      <Card tone="sunken">
        <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)', lineHeight: 1.5 }}>
          规则名和金额会照现在的样子存进这笔交易里，以后改规则也不会改写这一周的历史。
        </div>
      </Card>
      <Button tone="accent" icon="check" block disabled={done} onClick={onConfirm}>{done ? '本周已入账' : '确认，记入 +¥' + Math.round(total / 100)}</Button>
    </div>
  );
}

function ParentRules({ data, items, bonusCents }) {
  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>规则清单</h1>
      <Card>
        <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-head-size)', marginBottom: 'var(--space-2)' }}>每周都有的</div>
        {items.map((r, i) => <RuleRow key={r.name + i} size="parent" name={r.name} detail={'每周 ' + r.goal + ' 次'} rewardCents={r.rewardCents} kind="base" />)}
        <RuleRow size="parent" name="全部达成奖励" detail={items.length + ' 项都做到才有'} rewardCents={bonusCents} kind="base" />
      </Card>
      <StatusBanner size="parent" kind="norealmoney" text="项目和金额在「本周看板」里改 · 改完这里和 Forrest 的规则页同步" />
      <Card>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 'var(--space-2)' }}>
          <div style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-head-size)' }}>商量好的</div>
          <span style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)' }}>一事一议，直接记账</span>
        </div>
        {data.adhoc.map((r) => <RuleRow key={r.name} size="parent" {...r} />)}
      </Card>
      <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
        {data.changes.map((c) => <ChangeNote key={c.text} size="parent" {...c} />)}
      </div>
    </div>
  );
}

function ParentHistory({ data }) {
  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <h1 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>全部记录</h1>
        <Badge tone="neutral" icon="lock">不可删除</Badge>
      </div>
      <Card>{data.tx.map((t) => <TransactionRow key={t.id} size="parent" {...t} onClick={() => {}} />)}</Card>
      <Card tone="sunken">
        <div style={{ display: 'flex', gap: 10 }}>
          <Icon name="link" size={18} color="var(--money-fix)" />
          <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)', lineHeight: 1.5 }}>
            10月2日「乐高小车 −¥14」已被冲正，并写入正确的一笔。原记录、冲正、正确记录三条互相关联，都留在流水里。
          </div>
        </div>
      </Card>
    </div>
  );
}

function ParentSettings() {
  const [remind, setRemind] = React.useState(true);
  const [pin, setPin] = React.useState(true);
  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>设置</h1>
      <Card>
        <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-head-size)', marginBottom: 'var(--space-3)' }}>已配对的设备</div>
        {[['Forrest 的 iPad', '儿童 · 只读', 'tablet'], ['爸爸的 iPhone', '家长 · 可写入（本机）', 'smartphone']].map(([n, r, ic]) => (
          <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 12, minHeight: 'var(--touch-parent)', borderBottom: '1px solid var(--border-hair)' }}>
            <Icon name={ic} size={20} color="var(--spruce-600)" />
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600 }}>{n}</div>
              <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{r}</div>
            </div>
            <Button size="small" tone="quiet">撤销</Button>
          </div>
        ))}
        <div style={{ marginTop: 'var(--space-4)', display: 'grid', gap: 'var(--space-3)' }}>
          <Button tone="primary" icon="plus" block>添加设备（生成配对码）</Button>
          <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)' }}>6 位数字 · 10 分钟过期 · 用一次即作废</div>
        </div>
      </Card>
      <Card>
        <Toggle label="周日结算提醒" hint="只发给爸爸。Forrest 的 iPad 上一条通知都不会有。" checked={remind} onChange={setRemind} />
        <Toggle label="预览儿童视图需要 PIN" hint="PIN 只保护这个入口，权限仍由服务端强制" checked={pin} onChange={setPin} />
      </Card>
      <Card tone="sunken">
        <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
          <Button tone="outline" icon="eye" block>预览 Forrest 看到的画面</Button>
          <Button tone="outline" icon="repeat" block>重新配对</Button>
        </div>
      </Card>
      <StatusBanner size="parent" kind="norealmoney" text="这个 App 只记录数字，不接触银行卡、也不转移现金" />
    </div>
  );
}
Object.assign(window, { ParentBoard, ParentSettle, ParentRules, ParentHistory, ParentSettings, ItemEditor });
