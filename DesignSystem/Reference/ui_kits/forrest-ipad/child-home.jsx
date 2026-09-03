const { BalanceHero, GoalProgress, TransactionRow, Card, StatusBanner, Badge, Celebration, Button } = window.ForrestSWalletDesignSystem_2e3ae3;

function ChildHome({ data, offline, celebrate, onDismiss, onOpenAll }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
        <h1 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-title-size)', color: 'var(--text-strong)' }}>我的钱</h1>
        <StatusBanner kind={offline ? 'offline' : 'online'} />
      </div>

      {celebrate ? <Celebration cents={1000} reason="本周基础零花钱" onDone={onDismiss} /> : null}

      <BalanceHero cents={data.balanceCents} note="爸爸记下的每一笔都在下面，你可以自己数一遍。" />

      <Card variant="child" tone="honey">
        <GoalProgress title={data.goal.title} savedCents={data.balanceCents} targetCents={data.goal.targetCents} />
      </Card>

      <Card variant="child">
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 'var(--space-4)' }}>
          <h2 style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-child-head-size)' }}>钱为什么变了</h2>
          <Badge tone="neutral" icon="eye" size="child">只能看</Badge>
        </div>
        <div style={{ display: 'grid' }}>
          {data.tx.slice(0, 5).map((t) => <TransactionRow key={t.id} {...t} />)}
        </div>
        <div style={{ marginTop: 'var(--space-5)' }}>
          <Button size="child" tone="quiet" iconAfter="chevron-right" onClick={onOpenAll}>看全部流水</Button>
        </div>
      </Card>
    </div>
  );
}
Object.assign(window, { ChildHome });
