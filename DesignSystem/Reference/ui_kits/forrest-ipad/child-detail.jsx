const { WeekBoard, RuleRow, ChangeNote, TransactionRow, Card, NavHeader, Badge, EmptyState, SettlementSummary, AmountText, CostHint, Icon } = window.ForrestSWalletDesignSystem_2e3ae3;

function ChildBoard({ data }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-title-size)' }}>本周看板</h1>
      <Card variant="child"><WeekBoard items={data.board} weekLabel="10月1日 – 10月7日" /></Card>
      <Card variant="child" tone="leaf">
        <h2 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-head-size)', marginBottom: 'var(--space-4)' }}>周日一起算算看</h2>
        <SettlementSummary size="child" lines={[
          { name: '跳绳', goal: 5, doneCount: 3, rewardCents: 500, met: false },
          { name: '喝牛奶', goal: 7, doneCount: 2, rewardCents: 500, met: false },
          { name: '上学全勤', goal: 5, doneCount: 3, rewardCents: 500, met: false },
        ]} bonus={{ rewardCents: 300, met: false }} />
        <div style={{ marginTop: 'var(--space-5)', fontSize: 'var(--type-child-body-size)', color: 'var(--spruce-600)' }}>
          现在还没到周日，空着的格子只是爸爸还没记。
        </div>
      </Card>
    </div>
  );
}

function ChildRules({ data }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-title-size)' }}>规则</h1>
      <Card variant="child">
        <h2 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-head-size)', marginBottom: 'var(--space-3)' }}>每周都有的</h2>
        {data.rules.map((r) => <RuleRow key={r.name} {...r} met={r.name === '跳绳' ? false : undefined} />)}
      </Card>
      <Card variant="child">
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 'var(--space-3)' }}>
          <h2 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-head-size)' }}>商量好的</h2>
          <span style={{ fontSize: 'var(--type-child-label-size)', color: 'var(--text-muted)' }}>一共 12 条，下面是最近 3 条</span>
        </div>
        {data.adhoc.map((r) => <RuleRow key={r.name} {...r} />)}
      </Card>
      <div>
        <h2 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-head-size)', marginBottom: 'var(--space-4)' }}>规则改过哪些</h2>
        <div style={{ display: 'grid', gap: 'var(--space-4)' }}>
          {data.changes.map((c) => <ChangeNote key={c.text} {...c} />)}
        </div>
      </div>
    </div>
  );
}

function ChildLedger({ data }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-6)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-title-size)' }}>全部流水</h1>
      <CostHint cents={1500} goalTitle={data.goal.title} />
      <Card variant="child">
        <div style={{ display: 'grid' }}>
          {data.tx.map((t) => <TransactionRow key={t.id} {...t} />)}
        </div>
      </Card>
    </div>
  );
}

function ChildWishes({ data }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
      <h1 style={{ fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-title-size)' }}>已实现的心愿</h1>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-5)' }}>
        {data.wishes.map((w) => (
          <Card key={w.title} variant="child" tone="honey">
            <Icon name="party-popper" size={30} color="var(--honey-700)" />
            <div style={{ marginTop: 'var(--space-4)', fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: 'var(--type-child-head-size)' }}>{w.title}</div>
            <div style={{ marginTop: 'var(--space-2)' }}><AmountText cents={w.cents} direction="flat" showSign={false} /></div>
            <div style={{ marginTop: 'var(--space-2)', fontSize: 'var(--type-child-label-size)', color: 'var(--honey-700)' }}>{w.date}</div>
          </Card>
        ))}
      </div>
      <Card variant="child" tone="sunken" style={{ padding: 0 }}>
        <EmptyState icon="target" title="下一个心愿正在攒" body={`${data.goal.title} · 已攒 ¥${Math.round(data.balanceCents / 100)} / ¥${Math.round(data.goal.targetCents / 100)}`} />
      </Card>
    </div>
  );
}
Object.assign(window, { ChildBoard, ChildRules, ChildLedger, ChildWishes });
