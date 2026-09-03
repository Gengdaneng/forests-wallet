const { BalanceHero, TransactionRow, Card, Button, StatusBanner, Badge, GoalProgress, Icon } = window.ForrestSWalletDesignSystem_2e3ae3;

function ParentHome({ data, online, onEntry, onSettle, onOpen }) {
  return (
    <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <h1 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>Forrest 的账本</h1>
        <StatusBanner size="parent" kind={online ? 'online' : 'failed'} text={online ? '已连上' : '离线 · 不能记账'} />
      </div>

      <BalanceHero cents={data.balanceCents} size="parent" note="1:1 无条件兑现 · 他真的有这么多" />

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 'var(--space-3)' }}>
        <Button tone="accent" icon="plus" block disabled={!online} onClick={() => onEntry('in')}>加进来</Button>
        <Button tone="quiet" icon="minus" block disabled={!online} onClick={() => onEntry('out')}>花掉了</Button>
        <Button tone="outline" icon="rotate-ccw" block disabled={!online} onClick={() => onEntry('fix')}>更正</Button>
      </div>
      {!online ? <StatusBanner size="parent" kind="failed" text="没有写入任何记录 —— 记账必须联网" /> : null}

      <Card onClick={onSettle} style={{ display: 'flex', alignItems: 'center', gap: 12, background: 'var(--surface-leaf)', border: 'none' }}>
        <Icon name="calendar-check" size={22} color="var(--spruce-700)" />
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: 'var(--type-body-size)' }}>周日结算等你确认</div>
          <div style={{ fontSize: 'var(--type-caption-size)', color: 'var(--spruce-600)' }}>三项达成两项 · 本周 ¥10</div>
        </div>
        <Icon name="chevron-right" size={20} color="var(--spruce-600)" />
      </Card>

      <Card tone="honey">
        <GoalProgress size="parent" title={data.goal.title} savedCents={data.balanceCents} targetCents={data.goal.targetCents} />
      </Card>

      <Card>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 'var(--space-3)' }}>
          <h2 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-head-size)' }}>最近记的</h2>
          <Badge tone="neutral" icon="lock">不能删</Badge>
        </div>
        {data.tx.slice(0, 4).map((t) => <TransactionRow key={t.id} size="parent" {...t} onClick={() => onOpen(t)} />)}
      </Card>
    </div>
  );
}
Object.assign(window, { ParentHome });
