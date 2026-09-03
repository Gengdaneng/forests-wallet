const { AmountField, NumberPad, TextField, CategoryPicker, Button, Card, StatusBanner, NavHeader, CostHint, AmountText, Icon, Badge } = window.ForrestSWalletDesignSystem_2e3ae3;

/* 3 taps / 15 seconds: amount → confirm → (skippable) reason & category. */
function EntryFlow({ direction, goalTitle, onCancel, onDone }) {
  const [step, setStep] = React.useState('amount');
  const [amt, setAmt] = React.useState('');
  const [reason, setReason] = React.useState('');
  const [cat, setCat] = React.useState();
  const label = { in: '加进来多少', out: '花了多少', fix: '更正多少' }[direction];
  const cents = (parseInt(amt || '0', 10) || 0) * 100;

  if (step === 'done') {
    return (
      <div style={{ display: 'grid', gap: 'var(--space-5)', padding: 'var(--space-5)' }}>
        <div style={{ textAlign: 'center', padding: 'var(--space-6) 0' }}>
          <Icon name="check-circle-2" size={44} color="var(--money-in)" />
          <h1 style={{ marginTop: 'var(--space-4)', fontFamily: 'var(--font-rounded)', fontSize: 'var(--type-title-size)' }}>已记录</h1>
          <div style={{ marginTop: 'var(--space-3)' }}><AmountText cents={cents} direction={direction} size="heroSm" /></div>
          <div style={{ marginTop: 'var(--space-2)', color: 'var(--text-muted)' }}>{reason || '（没写事由）'}</div>
        </div>
        <StatusBanner size="parent" kind="norealmoney" text="已记录 · 没有任何真实资金移动" />
        {direction === 'out' ? <CostHint cents={cents} goalTitle={goalTitle} /> : null}
        <Button tone="primary" block onClick={onDone}>回首页</Button>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <NavHeader size="parent" title={{ in: '加进来', out: '花掉了', fix: '更正这笔' }[direction]} onBack={onCancel}
        action={direction === 'fix' ? <Badge tone="fix" icon="rotate-ccw">留痕</Badge> : null} />
      {step === 'amount' ? (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 var(--gutter-phone) var(--space-5)' }}>
          <AmountField value={amt} direction={direction} label={label} />
          <NumberPad value={amt} onChange={setAmt} />
          <div style={{ marginTop: 'auto', paddingTop: 'var(--space-5)' }}>
            <Button tone="primary" block disabled={!amt} onClick={() => setStep('extra')}>确认记录</Button>
          </div>
        </div>
      ) : (
        <div style={{ flex: 1, display: 'grid', gap: 'var(--space-5)', alignContent: 'start', padding: '0 var(--gutter-phone) var(--space-5)' }}>
          <Card tone="sunken" style={{ textAlign: 'center' }}><AmountText cents={cents} direction={direction} size="heroSm" /></Card>
          <TextField label="为什么" placeholder="买冰淇淋" optional maxLength={8} value={reason} onChange={setReason} />
          {direction === 'out' ? <CategoryPicker value={cat} onChange={setCat} /> : null}
          {direction === 'fix' ? <StatusBanner size="parent" kind="norealmoney" text="原记录会保留，另外写入一笔冲正" /> : null}
          <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
            <Button tone="primary" block onClick={() => setStep('done')}>记下来</Button>
            <Button tone="quiet" block onClick={() => setStep('done')}>都跳过，直接记</Button>
          </div>
        </div>
      )}
    </div>
  );
}
Object.assign(window, { EntryFlow });
