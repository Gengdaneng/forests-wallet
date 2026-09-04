/* @ds-bundle: {"format":4,"namespace":"ForrestSWalletDesignSystem_2e3ae3","components":[{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"CATEGORIES","sourcePath":"components/core/Tag.jsx"},{"name":"Tag","sourcePath":"components/core/Tag.jsx"},{"name":"Celebration","sourcePath":"components/feedback/Celebration.jsx"},{"name":"EmptyState","sourcePath":"components/feedback/EmptyState.jsx"},{"name":"StatusBanner","sourcePath":"components/feedback/StatusBanner.jsx"},{"name":"AmountField","sourcePath":"components/forms/AmountField.jsx"},{"name":"CategoryPicker","sourcePath":"components/forms/CategoryPicker.jsx"},{"name":"NumberPad","sourcePath":"components/forms/NumberPad.jsx"},{"name":"TextField","sourcePath":"components/forms/TextField.jsx"},{"name":"Toggle","sourcePath":"components/forms/Toggle.jsx"},{"name":"ChangeNote","sourcePath":"components/ledger/ChangeNote.jsx"},{"name":"RuleRow","sourcePath":"components/ledger/RuleRow.jsx"},{"name":"SettlementSummary","sourcePath":"components/ledger/SettlementSummary.jsx"},{"name":"BoardCell","sourcePath":"components/ledger/WeekBoard.jsx"},{"name":"WeekBoard","sourcePath":"components/ledger/WeekBoard.jsx"},{"name":"AmountText","sourcePath":"components/money/AmountText.jsx"},{"name":"BalanceHero","sourcePath":"components/money/BalanceHero.jsx"},{"name":"CostHint","sourcePath":"components/money/CostHint.jsx"},{"name":"GoalProgress","sourcePath":"components/money/GoalProgress.jsx"},{"name":"TransactionRow","sourcePath":"components/money/TransactionRow.jsx"},{"name":"NavHeader","sourcePath":"components/navigation/NavHeader.jsx"},{"name":"Sidebar","sourcePath":"components/navigation/Sidebar.jsx"},{"name":"TabBar","sourcePath":"components/navigation/TabBar.jsx"}],"sourceHashes":{"components/core/Badge.jsx":"1f3163b37975","components/core/Button.jsx":"dbc69da37b01","components/core/Card.jsx":"f40b5b05f1e6","components/core/Icon.jsx":"ff0ae6b29afc","components/core/IconButton.jsx":"c46900391d72","components/core/Tag.jsx":"4ea9c1f27788","components/feedback/Celebration.jsx":"da7880cab5fe","components/feedback/EmptyState.jsx":"85a30ba8380c","components/feedback/StatusBanner.jsx":"2fd577e33eec","components/forms/AmountField.jsx":"ae0100a6d502","components/forms/CategoryPicker.jsx":"fd4ba04b0f94","components/forms/NumberPad.jsx":"cb18a51c89a8","components/forms/TextField.jsx":"7786e3f7f047","components/forms/Toggle.jsx":"0cb86e1c3d6c","components/ledger/ChangeNote.jsx":"4cf8821d15ee","components/ledger/RuleRow.jsx":"a119d914d41d","components/ledger/SettlementSummary.jsx":"6b879df3e539","components/ledger/WeekBoard.jsx":"38f485eeb5aa","components/money/AmountText.jsx":"ae630c065225","components/money/BalanceHero.jsx":"876c2ca5e8d7","components/money/CostHint.jsx":"a7dfd7b9e2d1","components/money/GoalProgress.jsx":"1d3906199569","components/money/TransactionRow.jsx":"08eca7b93dcc","components/navigation/NavHeader.jsx":"1d81d56a471e","components/navigation/Sidebar.jsx":"f1936c5de21f","components/navigation/TabBar.jsx":"7abdc4e040d9","ui_kits/data.js":"f9c95d3643f6","ui_kits/forrest-ipad/child-detail.jsx":"b605c6290ffa","ui_kits/forrest-ipad/child-home.jsx":"e27c147b85b4","ui_kits/parent-iphone/entry-flow.jsx":"61ce51afffbf","ui_kits/parent-iphone/other-screens.jsx":"48064b49dd01","ui_kits/parent-iphone/parent-home.jsx":"2800d2a61bd0"},"inlinedExternals":[],"unexposedExports":[{"name":"formatYuan","sourcePath":"components/money/AmountText.jsx"}]} */

(() => {

const __ds_ns = (window.ForrestSWalletDesignSystem_2e3ae3 = window.ForrestSWalletDesignSystem_2e3ae3 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Card({
  children,
  variant = 'parent',
  tone = 'paper',
  pad,
  onClick,
  style,
  ...rest
}) {
  const tones = {
    paper: {
      bg: 'var(--surface-card)',
      bd: 'var(--border-card)',
      fg: 'var(--text-body)'
    },
    sunken: {
      bg: 'var(--surface-sunken)',
      bd: 'transparent',
      fg: 'var(--text-body)'
    },
    leaf: {
      bg: 'var(--surface-leaf)',
      bd: 'transparent',
      fg: 'var(--spruce-800)'
    },
    honey: {
      bg: 'var(--surface-honey)',
      bd: 'transparent',
      fg: 'var(--text-on-honey)'
    },
    ink: {
      bg: 'var(--surface-ink)',
      bd: 'transparent',
      fg: 'var(--text-on-ink)'
    }
  };
  const t = tones[tone] || tones.paper;
  const child = variant === 'child';
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    style: {
      background: t.bg,
      color: t.fg,
      border: `1px solid ${t.bd}`,
      borderRadius: child ? 'var(--radius-card-child)' : 'var(--radius-card-parent)',
      padding: pad ?? (child ? 'var(--card-pad-child)' : 'var(--card-pad-parent)'),
      boxShadow: tone === 'sunken' ? 'none' : child ? 'var(--shadow-card-child)' : 'var(--shadow-card)',
      cursor: onClick ? 'pointer' : undefined,
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Forrest's Wallet uses Lucide (line icons, 2px stroke) as its icon set — see
   readme.md ICONOGRAPHY. The Lucide UMD build must be on the page:
   <script src="https://unpkg.com/lucide@0.544.0/dist/umd/lucide.js"></script> */
function Icon({
  name,
  size = 24,
  strokeWidth = 2,
  color = 'currentColor',
  label,
  style,
  ...rest
}) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    if (window.lucide && window.lucide.createIcons) window.lucide.createIcons();
  });
  return /*#__PURE__*/React.createElement("i", _extends({
    ref: ref,
    "data-lucide": name,
    width: size,
    height: size,
    "stroke-width": strokeWidth,
    "aria-hidden": label ? undefined : 'true',
    "aria-label": label,
    style: {
      display: 'inline-flex',
      width: size,
      height: size,
      color,
      flex: '0 0 auto',
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
const TONES = {
  in: {
    bg: 'var(--money-in-bg)',
    fg: 'var(--money-in)'
  },
  out: {
    bg: 'var(--money-out-bg)',
    fg: 'var(--money-out)'
  },
  fix: {
    bg: 'var(--money-fix-bg)',
    fg: 'var(--money-fix)'
  },
  debt: {
    bg: 'var(--money-debt-bg)',
    fg: 'var(--money-debt)'
  },
  goal: {
    bg: 'var(--money-goal-track)',
    fg: 'var(--honey-700)'
  },
  neutral: {
    bg: 'var(--surface-sunken)',
    fg: 'var(--text-muted)'
  }
};
function Badge({
  children,
  tone = 'neutral',
  icon,
  size = 'parent'
}) {
  const t = TONES[tone] || TONES.neutral;
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      background: t.bg,
      color: t.fg,
      padding: child ? '6px 14px' : '4px 10px',
      borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      whiteSpace: 'nowrap'
    }
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: child ? 18 : 14
  }) : null, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  primary: {
    bg: 'var(--action-primary)',
    press: 'var(--action-primary-press)',
    fg: 'var(--action-primary-text)',
    bd: 'transparent'
  },
  accent: {
    bg: 'var(--action-accent)',
    press: 'var(--action-accent-press)',
    fg: 'var(--action-accent-text)',
    bd: 'transparent'
  },
  quiet: {
    bg: 'var(--action-quiet-bg)',
    press: 'var(--action-quiet-press)',
    fg: 'var(--text-body)',
    bd: 'transparent'
  },
  outline: {
    bg: 'transparent',
    press: 'var(--action-quiet-bg)',
    fg: 'var(--text-body)',
    bd: 'var(--border-strong)'
  },
  danger: {
    bg: 'var(--action-danger)',
    press: '#9E3222',
    fg: 'var(--paper-100)',
    bd: 'transparent'
  }
};
const SIZES = {
  child: {
    h: 'var(--touch-child)',
    px: 'var(--space-7)',
    fs: 'var(--type-child-label-size)',
    r: 'var(--radius-xl)',
    gap: 10
  },
  parent: {
    h: 'var(--touch-parent)',
    px: 'var(--space-6)',
    fs: 'var(--type-label-size)',
    r: 'var(--radius-md)',
    gap: 8
  },
  small: {
    h: '36px',
    px: 'var(--space-4)',
    fs: 'var(--type-caption-size)',
    r: 'var(--radius-sm)',
    gap: 6
  }
};
function Button({
  children,
  tone = 'primary',
  size = 'parent',
  icon,
  iconAfter,
  block,
  disabled,
  onClick,
  type = 'button',
  ...rest
}) {
  const [held, setHeld] = React.useState(false);
  const t = TONES[tone] || TONES.primary;
  const s = SIZES[size] || SIZES.parent;
  return /*#__PURE__*/React.createElement("button", _extends({
    type: type,
    disabled: disabled,
    onClick: onClick,
    onPointerDown: () => setHeld(true),
    onPointerUp: () => setHeld(false),
    onPointerLeave: () => setHeld(false),
    style: {
      display: block ? 'flex' : 'inline-flex',
      width: block ? '100%' : undefined,
      alignItems: 'center',
      justifyContent: 'center',
      gap: s.gap,
      minHeight: s.h,
      padding: `0 ${s.px}`,
      borderRadius: s.r,
      border: `1.5px solid ${disabled ? 'transparent' : t.bd}`,
      background: disabled ? 'var(--disabled-bg)' : held ? t.press : t.bg,
      color: disabled ? 'var(--disabled-text)' : t.fg,
      fontFamily: 'var(--font-rounded)',
      fontSize: s.fs,
      fontWeight: 800,
      letterSpacing: 'var(--tracking-normal)',
      cursor: disabled ? 'default' : 'pointer',
      transform: held && !disabled ? `scale(${size === 'child' ? 'var(--press-scale-child)' : 'var(--press-scale)'})` : 'scale(1)',
      transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
      WebkitTapHighlightColor: 'transparent'
    }
  }, rest), icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'small' ? 16 : 20
  }) : null, children, iconAfter ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconAfter,
    size: size === 'small' ? 16 : 20
  }) : null);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function IconButton({
  icon,
  label,
  tone = 'quiet',
  size = 'parent',
  onClick,
  disabled,
  ...rest
}) {
  const [held, setHeld] = React.useState(false);
  const dim = size === 'child' ? 54 : size === 'small' ? 36 : 48;
  const bg = tone === 'primary' ? 'var(--action-primary)' : tone === 'accent' ? 'var(--action-accent)' : tone === 'bare' ? 'transparent' : 'var(--action-quiet-bg)';
  const fg = tone === 'primary' ? 'var(--action-primary-text)' : tone === 'accent' ? 'var(--action-accent-text)' : 'var(--text-body)';
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    title: label,
    disabled: disabled,
    onClick: onClick,
    onPointerDown: () => setHeld(true),
    onPointerUp: () => setHeld(false),
    onPointerLeave: () => setHeld(false),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: dim,
      height: dim,
      borderRadius: size === 'child' ? 'var(--radius-lg)' : 'var(--radius-md)',
      border: 'none',
      background: disabled ? 'var(--disabled-bg)' : bg,
      color: disabled ? 'var(--disabled-text)' : fg,
      cursor: disabled ? 'default' : 'pointer',
      transform: held && !disabled ? 'scale(var(--press-scale))' : 'scale(1)',
      transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
      WebkitTapHighlightColor: 'transparent'
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'small' ? 18 : 24
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/Tag.jsx
try { (() => {
/** The 6 fixed spend categories from PRD §6.2. Emoji is the brand's category glyph set. */
const CATEGORIES = [{
  id: 'food',
  emoji: '🍦',
  label: '吃的'
}, {
  id: 'toy',
  emoji: '🧸',
  label: '玩具'
}, {
  id: 'game',
  emoji: '🎮',
  label: '游戏'
}, {
  id: 'book',
  emoji: '📚',
  label: '书和文具'
}, {
  id: 'gift',
  emoji: '🎁',
  label: '送人的礼物'
}, {
  id: 'other',
  emoji: '❓',
  label: '其他'
}];
function Tag({
  category,
  label,
  emoji,
  selected,
  onClick,
  size = 'parent'
}) {
  const c = CATEGORIES.find(x => x.id === category);
  const text = label ?? (c ? c.label : '');
  const glyph = emoji ?? (c ? c.emoji : null);
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("span", {
    role: onClick ? 'button' : undefined,
    onClick: onClick,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 8,
      minHeight: onClick ? child ? 'var(--touch-child)' : 'var(--touch-parent)' : undefined,
      padding: child ? '10px 18px' : '8px 14px',
      borderRadius: 'var(--radius-pill)',
      background: selected ? 'var(--surface-leaf)' : 'var(--surface-sunken)',
      border: `1.5px solid ${selected ? 'var(--leaf-500)' : 'transparent'}`,
      color: 'var(--text-body)',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-label-size)',
      cursor: onClick ? 'pointer' : 'default',
      whiteSpace: 'nowrap',
      transition: 'background var(--dur-fast) var(--ease-standard)'
    }
  }, glyph ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: child ? 22 : 18,
      lineHeight: 1
    }
  }, glyph) : null, text);
}
Object.assign(__ds_scope, { CATEGORIES, Tag });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Tag.jsx", error: String((e && e.message) || e) }); }

// components/feedback/EmptyState.jsx
try { (() => {
function EmptyState({
  icon = 'notebook-pen',
  title,
  body,
  size = 'child'
}) {
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      padding: child ? 'var(--space-10) var(--space-7)' : 'var(--space-8) var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      placeItems: 'center',
      width: child ? 88 : 64,
      height: child ? 88 : 64,
      margin: '0 auto var(--space-5)',
      borderRadius: 'var(--radius-xl)',
      background: 'var(--surface-leaf)',
      color: 'var(--spruce-600)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: child ? 40 : 30
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)',
      color: 'var(--text-strong)'
    }
  }, title), body ? /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: 420,
      margin: 'var(--space-3) auto 0',
      fontFamily: 'var(--font-text)',
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
      color: 'var(--text-muted)'
    }
  }, body) : null);
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/feedback/StatusBanner.jsx
try { (() => {
const KINDS = {
  offline: {
    icon: 'cloud-off',
    bg: 'var(--slate-100)',
    fg: 'var(--slate-600)',
    text: '正在显示已保存的信息'
  },
  failed: {
    icon: 'refresh-cw-off',
    bg: 'var(--money-out-bg)',
    fg: 'var(--money-out)',
    text: '更新失败，这是上次保存的信息'
  },
  online: {
    icon: 'check-circle-2',
    bg: 'var(--money-in-bg)',
    fg: 'var(--money-in)',
    text: '信息是最新的'
  },
  norealmoney: {
    icon: 'shield-check',
    bg: 'var(--surface-sunken)',
    fg: 'var(--text-muted)',
    text: '只是记账，没有真的钱在动'
  }
};
function StatusBanner({
  kind = 'offline',
  text,
  size = 'child',
  style
}) {
  const k = KINDS[kind] || KINDS.offline;
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    role: "status",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      background: k.bg,
      color: k.fg,
      borderRadius: 'var(--radius-pill)',
      padding: child ? '10px 18px' : '8px 14px',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: k.icon,
    size: child ? 20 : 16
  }), text || k.text);
}
Object.assign(__ds_scope, { StatusBanner });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/StatusBanner.jsx", error: String((e && e.message) || e) }); }

// components/forms/AmountField.jsx
try { (() => {
function AmountField({
  value = '',
  direction = 'in',
  label
}) {
  const color = direction === 'out' ? 'var(--money-out)' : direction === 'fix' ? 'var(--money-fix)' : 'var(--money-in)';
  const sign = direction === 'out' ? '−' : direction === 'fix' ? '±' : '+';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      padding: 'var(--space-6) 0'
    }
  }, label ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: 'var(--type-label-size)',
      color: 'var(--text-muted)',
      marginBottom: 'var(--space-3)'
    }
  }, label) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      justifyContent: 'center',
      gap: 4,
      color,
      fontFamily: 'var(--font-rounded)',
      fontWeight: 900,
      letterSpacing: 'var(--tracking-tight)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 40
    }
  }, sign, "\xA5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 64,
      fontVariantNumeric: 'tabular-nums'
    }
  }, value || '0'), /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      width: 3,
      height: 48,
      marginLeft: 4,
      background: color,
      borderRadius: 2,
      animation: 'fwCaret 1s steps(2,end) infinite'
    }
  })), /*#__PURE__*/React.createElement("style", null, '@keyframes fwCaret{50%{opacity:0}}'));
}
Object.assign(__ds_scope, { AmountField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/AmountField.jsx", error: String((e && e.message) || e) }); }

// components/forms/CategoryPicker.jsx
try { (() => {
function CategoryPicker({
  value,
  onChange,
  size = 'parent',
  label = '花在什么上'
}) {
  return /*#__PURE__*/React.createElement("div", null, label ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      alignItems: 'baseline',
      marginBottom: 'var(--space-3)',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: 'var(--type-label-size)',
      color: 'var(--text-body)'
    }
  }, label, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-faint)'
    }
  }, "\u53EF\u8DF3\u8FC7\uFF0C\u9ED8\u8BA4\u300C\u5176\u4ED6\u300D")) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 'var(--space-3)'
    }
  }, __ds_scope.CATEGORIES.map(c => /*#__PURE__*/React.createElement(__ds_scope.Tag, {
    key: c.id,
    category: c.id,
    size: size,
    selected: value === c.id,
    onClick: () => onChange && onChange(value === c.id ? undefined : c.id)
  }))));
}
Object.assign(__ds_scope, { CategoryPicker });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/CategoryPicker.jsx", error: String((e && e.message) || e) }); }

// components/forms/NumberPad.jsx
try { (() => {
const KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'clear', '0', 'back'];
function NumberPad({
  value = '',
  onChange,
  max = 5
}) {
  const press = k => {
    if (!onChange) return;
    if (k === 'back') return onChange(value.slice(0, -1));
    if (k === 'clear') return onChange('');
    if (value.length >= max) return;
    if (k === '0' && value === '') return;
    onChange(value + k);
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(3,1fr)',
      gap: 'var(--space-4)'
    }
  }, KEYS.map(k => /*#__PURE__*/React.createElement(PadKey, {
    key: k,
    k: k,
    onPress: () => press(k)
  })));
}
function PadKey({
  k,
  onPress
}) {
  const [held, setHeld] = React.useState(false);
  const glyph = k === 'back' ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "delete",
    size: 24
  }) : k === 'clear' ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "eraser",
    size: 24
  }) : k;
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onPress,
    "aria-label": k === 'back' ? '删除' : k === 'clear' ? '清空' : k,
    onPointerDown: () => setHeld(true),
    onPointerUp: () => setHeld(false),
    onPointerLeave: () => setHeld(false),
    style: {
      minHeight: 62,
      border: 'none',
      borderRadius: 'var(--radius-md)',
      background: k === 'back' || k === 'clear' ? 'transparent' : held ? 'var(--action-quiet-press)' : 'var(--surface-card)',
      boxShadow: k === 'back' || k === 'clear' ? 'none' : 'var(--shadow-card)',
      color: 'var(--text-strong)',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: 28,
      display: 'grid',
      placeItems: 'center',
      cursor: 'pointer',
      transform: held ? 'scale(var(--press-scale))' : 'scale(1)',
      transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
      WebkitTapHighlightColor: 'transparent'
    }
  }, glyph);
}
Object.assign(__ds_scope, { NumberPad });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/NumberPad.jsx", error: String((e && e.message) || e) }); }

// components/forms/TextField.jsx
try { (() => {
function TextField({
  label,
  value,
  onChange,
  placeholder,
  optional,
  maxLength,
  size = 'parent'
}) {
  const [focus, setFocus] = React.useState(false);
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'block'
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      gap: 8,
      alignItems: 'baseline',
      marginBottom: 'var(--space-3)',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: 'var(--type-label-size)',
      color: 'var(--text-body)'
    }
  }, label, optional ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-faint)'
    }
  }, "\u53EF\u8DF3\u8FC7") : null) : null, /*#__PURE__*/React.createElement("input", {
    value: value,
    placeholder: placeholder,
    maxLength: maxLength,
    onChange: e => onChange && onChange(e.target.value),
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    style: {
      width: '100%',
      minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
      padding: '0 var(--space-4)',
      borderRadius: 'var(--radius-control)',
      border: `1.5px solid ${focus ? 'var(--spruce-500)' : 'var(--border-card)'}`,
      background: 'var(--surface-card)',
      color: 'var(--text-strong)',
      fontFamily: 'var(--font-text)',
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
      boxShadow: focus ? 'var(--shadow-focus)' : 'none',
      outline: 'none',
      transition: 'border-color var(--dur-fast) var(--ease-standard), box-shadow var(--dur-fast) var(--ease-standard)'
    }
  }));
}
Object.assign(__ds_scope, { TextField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/TextField.jsx", error: String((e && e.message) || e) }); }

// components/forms/Toggle.jsx
try { (() => {
function Toggle({
  checked,
  onChange,
  label,
  hint,
  disabled
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: 'var(--touch-parent)',
      cursor: disabled ? 'default' : 'pointer'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: 'var(--type-body-size)',
      color: 'var(--text-strong)'
    }
  }, label), hint ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      marginTop: 2,
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, hint) : null), /*#__PURE__*/React.createElement("button", {
    type: "button",
    role: "switch",
    "aria-checked": !!checked,
    "aria-label": label,
    disabled: disabled,
    onClick: () => onChange && onChange(!checked),
    style: {
      width: 52,
      height: 32,
      flex: '0 0 auto',
      borderRadius: 'var(--radius-pill)',
      border: 'none',
      background: disabled ? 'var(--disabled-bg)' : checked ? 'var(--leaf-500)' : 'var(--paper-300)',
      padding: 3,
      cursor: disabled ? 'default' : 'pointer',
      transition: 'background var(--dur-fast) var(--ease-standard)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      width: 26,
      height: 26,
      borderRadius: '50%',
      background: 'var(--paper-000)',
      boxShadow: '0 1px 3px rgba(14,42,36,.28)',
      transform: `translateX(${checked ? 20 : 0}px)`,
      transition: 'transform var(--dur-fast) var(--ease-bounce)'
    }
  })));
}
Object.assign(__ds_scope, { Toggle });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Toggle.jsx", error: String((e && e.message) || e) }); }

// components/ledger/ChangeNote.jsx
try { (() => {
function ChangeNote({
  text,
  date,
  size = 'child'
}) {
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start',
      background: 'var(--surface-sunken)',
      borderRadius: 'var(--radius-lg)',
      padding: child ? 'var(--space-5)' : 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "pencil-line",
    size: child ? 22 : 18,
    color: "var(--money-fix)",
    style: {
      marginTop: 2
    }
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
      color: 'var(--text-strong)'
    }
  }, text), date ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 4,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, date) : null));
}
Object.assign(__ds_scope, { ChangeNote });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/ledger/ChangeNote.jsx", error: String((e && e.message) || e) }); }

// components/ledger/RuleRow.jsx
try { (() => {
function RuleRow({
  name,
  detail,
  rewardCents,
  met,
  size = 'child',
  kind = 'base',
  onClick
}) {
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: child ? 'var(--space-5)' : 'var(--space-4)',
      minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
      padding: child ? 'var(--space-4) 0' : 'var(--space-3) 0',
      borderBottom: '1px solid var(--border-hair)',
      cursor: onClick ? 'pointer' : undefined
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      placeItems: 'center',
      width: child ? 44 : 36,
      height: child ? 44 : 36,
      borderRadius: 'var(--radius-md)',
      background: kind === 'base' ? 'var(--surface-leaf)' : 'var(--surface-honey)',
      color: kind === 'base' ? 'var(--spruce-700)' : 'var(--honey-700)',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: kind === 'base' ? 'repeat' : 'sparkles',
    size: child ? 22 : 18
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
      color: 'var(--text-strong)'
    }
  }, name), detail ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 2,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, detail) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      flex: '0 0 auto'
    }
  }, met !== undefined ? /*#__PURE__*/React.createElement(__ds_scope.Badge, {
    tone: met ? 'in' : 'neutral',
    icon: met ? 'check' : 'clock',
    size: size
  }, met ? '做到了' : '还没记') : null, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontVariantNumeric: 'tabular-nums',
      fontSize: child ? 'var(--type-amount-size)' : 'var(--type-amount-sm-size)',
      color: 'var(--spruce-700)'
    }
  }, "\xA5", Math.round(rewardCents / 100))));
}
Object.assign(__ds_scope, { RuleRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/ledger/RuleRow.jsx", error: String((e && e.message) || e) }); }

// components/ledger/SettlementSummary.jsx
try { (() => {
function SettlementSummary({
  lines,
  bonus,
  size = 'parent'
}) {
  const child = size === 'child';
  const total = lines.reduce((s, l) => s + (l.met ? l.rewardCents : 0), 0) + (bonus && bonus.met ? bonus.rewardCents : 0);
  const fs = child ? 'var(--type-child-body-size)' : 'var(--type-body-size)';
  const row = (label, note, cents, met, key) => /*#__PURE__*/React.createElement("div", {
    key: key,
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 10,
      padding: child ? '10px 0' : '7px 0'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: fs,
      color: met ? 'var(--text-strong)' : 'var(--text-muted)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      borderBottom: '1px dotted var(--border-card)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, note), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontVariantNumeric: 'tabular-nums',
      fontSize: fs,
      color: met ? 'var(--money-in)' : 'var(--text-faint)',
      minWidth: 56,
      textAlign: 'right'
    }
  }, met ? '+¥' + Math.round(cents / 100) : '¥0'));
  return /*#__PURE__*/React.createElement("div", null, lines.map((l, i) => row(l.name, `目标 ${l.goal} 次 · 做到 ${l.doneCount} 次`, l.rewardCents, l.met, i)), bonus ? row('三项全达成奖励', bonus.met ? '达成' : '未达成', bonus.rewardCents, bonus.met, 'bonus') : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      marginTop: 'var(--space-4)',
      paddingTop: 'var(--space-4)',
      borderTop: '2px solid var(--spruce-700)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "equal",
    size: child ? 22 : 18,
    color: "var(--spruce-700)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)',
      color: 'var(--text-strong)'
    }
  }, "\u672C\u5468\u57FA\u7840\u96F6\u82B1\u94B1"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 900,
      fontVariantNumeric: 'tabular-nums',
      fontSize: child ? 34 : 26,
      color: 'var(--money-in)'
    }
  }, "+\xA5", Math.round(total / 100))));
}
Object.assign(__ds_scope, { SettlementSummary });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/ledger/SettlementSummary.jsx", error: String((e && e.message) || e) }); }

// components/ledger/WeekBoard.jsx
try { (() => {
const DAYS = ['一', '二', '三', '四', '五', '六', '日'];
const STATES = {
  done: {
    bg: 'var(--cell-done-bg)',
    ink: 'var(--cell-done-ink)',
    border: 'transparent',
    icon: 'check'
  },
  unlogged: {
    bg: 'var(--cell-unlogged-bg)',
    ink: 'var(--text-faint)',
    border: 'var(--cell-unlogged-line)',
    icon: null
  },
  future: {
    bg: 'var(--cell-future-bg)',
    ink: 'var(--cell-future-ink)',
    border: 'transparent',
    icon: null
  },
  missed: {
    bg: 'var(--cell-missed-bg)',
    ink: 'var(--cell-missed-ink)',
    border: 'transparent',
    icon: 'minus'
  }
};
function BoardCell({
  state = 'unlogged',
  onToggle,
  size = 'child'
}) {
  const s = STATES[state] || STATES.unlogged;
  const dim = size === 'child' ? 54 : 44;
  const interactive = !!onToggle && state !== 'future';
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    disabled: !interactive,
    onClick: onToggle,
    "aria-label": {
      done: '已完成',
      unlogged: '还没记',
      future: '还没到',
      missed: '未达成'
    }[state],
    style: {
      width: dim,
      height: dim,
      borderRadius: 'var(--radius-cell)',
      background: s.bg,
      color: s.ink,
      border: s.border === 'transparent' ? '1.5px solid transparent' : `1.5px dashed ${s.border}`,
      display: 'grid',
      placeItems: 'center',
      cursor: interactive ? 'pointer' : 'default',
      transition: 'background var(--dur-fast) var(--ease-standard), transform var(--dur-instant) var(--ease-bounce)'
    }
  }, s.icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: s.icon,
    size: size === 'child' ? 26 : 20,
    strokeWidth: 3
  }) : null);
}
function WeekBoard({
  items,
  size = 'child',
  onToggle,
  weekLabel
}) {
  const child = size === 'child';
  const cell = child ? 54 : 44;
  return /*#__PURE__*/React.createElement("div", null, weekLabel ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 'var(--space-4)',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)',
      color: 'var(--text-strong)'
    }
  }, weekLabel) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: `minmax(96px,1fr) repeat(7, ${cell}px)`,
      gap: child ? 10 : 6,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", null), DAYS.map(d => /*#__PURE__*/React.createElement("div", {
    key: d,
    style: {
      textAlign: 'center',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 17 : 13,
      color: 'var(--text-muted)'
    }
  }, d)), items.map((it, r) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: it.name
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2,
      paddingRight: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-label-size)',
      color: 'var(--text-strong)'
    }
  }, it.name), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: child ? 15 : 12,
      color: 'var(--text-muted)',
      fontVariantNumeric: 'tabular-nums'
    }
  }, it.days.filter(s => s === 'done').length, "/", it.goal, " \xB7 \xA5", Math.round(it.rewardCents / 100))), it.days.map((st, c) => /*#__PURE__*/React.createElement("div", {
    key: c,
    style: {
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(BoardCell, {
    state: st,
    size: size,
    onToggle: onToggle ? () => onToggle(r, c) : undefined
  })))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: child ? 20 : 14,
      marginTop: 'var(--space-5)',
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, [['done', '做到了'], ['unlogged', '爸爸还没记'], ['future', '还没到']].map(([k, label]) => /*#__PURE__*/React.createElement("span", {
    key: k,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 18,
      height: 18,
      borderRadius: 5,
      background: STATES[k].bg,
      border: STATES[k].border === 'transparent' ? 'none' : `1.5px dashed ${STATES[k].border}`
    }
  }), label))));
}
Object.assign(__ds_scope, { BoardCell, WeekBoard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/ledger/WeekBoard.jsx", error: String((e && e.message) || e) }); }

// components/money/AmountText.jsx
try { (() => {
/** Money is stored in cents and always displayed as whole yuan (PRD §3). */
function formatYuan(cents) {
  const yuan = Math.round(Math.abs(cents) / 100);
  return yuan.toLocaleString('zh-CN');
}
const DIR = {
  in: {
    color: 'var(--money-in)',
    sign: '+'
  },
  out: {
    color: 'var(--money-out)',
    sign: '−'
  },
  fix: {
    color: 'var(--money-fix)',
    sign: '±'
  },
  debt: {
    color: 'var(--money-debt)',
    sign: '−'
  },
  flat: {
    color: 'var(--text-body)',
    sign: ''
  }
};
function AmountText({
  cents,
  direction,
  size = 'row',
  showSign = true,
  style
}) {
  const dir = direction || (cents < 0 ? 'debt' : cents > 0 ? 'in' : 'flat');
  const d = DIR[dir] || DIR.flat;
  const sizes = {
    hero: {
      fs: 'var(--type-balance-size)',
      fw: 900,
      lh: 'var(--type-balance-lh)'
    },
    heroSm: {
      fs: 'var(--type-balance-sm-size)',
      fw: 900,
      lh: 'var(--type-balance-sm-lh)'
    },
    row: {
      fs: 'var(--type-amount-size)',
      fw: 'var(--type-amount-weight)',
      lh: 1.1
    },
    small: {
      fs: 'var(--type-amount-sm-size)',
      fw: 700,
      lh: 1.2
    }
  };
  const s = sizes[size] || sizes.row;
  return /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: s.fs,
      fontWeight: s.fw,
      lineHeight: s.lh,
      letterSpacing: 'var(--tracking-tight)',
      color: d.color,
      whiteSpace: 'nowrap',
      ...style
    }
  }, showSign && d.sign ? d.sign : '', "\xA5", formatYuan(cents));
}
Object.assign(__ds_scope, { formatYuan, AmountText });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/money/AmountText.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Celebration.jsx
try { (() => {
/** Income only. Spend, debt and corrections get one quiet static acknowledgement (PRD §10). */
function Celebration({
  cents,
  reason,
  show = true,
  onDone,
  reducedMotion
}) {
  React.useEffect(() => {
    if (!show || !onDone) return;
    const t = setTimeout(onDone, 1800);
    return () => clearTimeout(t);
  }, [show, onDone]);
  if (!show) return null;
  const still = reducedMotion || typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const leaves = [-160, -95, -30, 35, 100, 165];
  return /*#__PURE__*/React.createElement("div", {
    role: "status",
    style: {
      position: 'relative',
      display: 'grid',
      placeItems: 'center',
      padding: 'var(--space-9) var(--space-7)',
      background: 'var(--surface-leaf)',
      borderRadius: 'var(--radius-2xl)',
      overflow: 'hidden'
    }
  }, !still && leaves.map((x, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      top: -24,
      left: `calc(50% + ${x}px)`,
      width: 14,
      height: 14,
      borderRadius: '14px 2px 14px 2px',
      background: i % 2 ? 'var(--honey-500)' : 'var(--leaf-500)',
      animation: `fwFall var(--dur-celebrate) var(--ease-out) ${i * 70}ms both`
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: 'var(--type-child-head-size)',
      color: 'var(--spruce-700)'
    }
  }, "\u52A0\u8FDB\u6765\u4E86"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-3)',
      animation: still ? 'none' : 'fwPop var(--dur-celebrate) var(--ease-bounce) both'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.AmountText, {
    cents: cents,
    direction: "in",
    size: "heroSm"
  })), reason ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-3)',
      fontFamily: 'var(--font-text)',
      fontSize: 'var(--type-child-body-size)',
      color: 'var(--spruce-600)'
    }
  }, reason) : null, /*#__PURE__*/React.createElement("style", null, '@keyframes fwFall{0%{transform:translateY(0) rotate(0);opacity:0}20%{opacity:1}100%{transform:translateY(240px) rotate(220deg);opacity:0}}@keyframes fwPop{0%{transform:scale(.6);opacity:0}60%{transform:scale(1.06)}100%{transform:scale(1);opacity:1}}'));
}
Object.assign(__ds_scope, { Celebration });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Celebration.jsx", error: String((e && e.message) || e) }); }

// components/money/BalanceHero.jsx
try { (() => {
function BalanceHero({
  cents,
  caption = '你现在有',
  size = 'child',
  note,
  style
}) {
  const negative = cents < 0;
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: negative ? 'var(--money-debt-bg)' : 'var(--surface-ink)',
      color: negative ? 'var(--money-debt)' : 'var(--text-on-ink)',
      border: negative ? '1.5px solid var(--berry-400)' : 'none',
      borderRadius: child ? 'var(--radius-2xl)' : 'var(--radius-lg)',
      padding: child ? 'var(--space-9) var(--space-8)' : 'var(--space-6)',
      textAlign: child ? 'center' : 'left',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-label-size)',
      color: negative ? 'var(--money-debt)' : 'var(--text-on-ink-muted)',
      marginBottom: child ? 'var(--space-4)' : 'var(--space-2)'
    }
  }, negative ? '你现在欠爸爸' : caption), /*#__PURE__*/React.createElement(__ds_scope.AmountText, {
    cents: cents,
    size: child ? 'hero' : 'heroSm',
    showSign: false,
    direction: "flat",
    style: {
      color: negative ? 'var(--money-debt)' : 'var(--paper-000)'
    }
  }), negative ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: child ? 'center' : 'flex-start',
      gap: 8,
      marginTop: 'var(--space-4)',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "alert-triangle",
    size: child ? 22 : 18
  }), "\u4E0B\u6B21\u96F6\u82B1\u94B1\u4F1A\u5148\u8FD8\u4E0A") : note ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-4)',
      fontFamily: 'var(--font-text)',
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-caption-size)',
      color: 'var(--text-on-ink-muted)'
    }
  }, note) : null);
}
Object.assign(__ds_scope, { BalanceHero });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/money/BalanceHero.jsx", error: String((e && e.message) || e) }); }

// components/money/CostHint.jsx
try { (() => {
function CostHint({
  cents,
  goalTitle,
  style
}) {
  const yuan = Math.round(Math.abs(cents) / 100);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      background: 'var(--surface-honey)',
      borderRadius: 'var(--radius-lg)',
      padding: 'var(--space-4) var(--space-5)',
      color: 'var(--text-on-honey)',
      fontFamily: 'var(--font-text)',
      fontWeight: 600,
      fontSize: 'var(--type-body-size)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "move-right",
    size: 20,
    color: "var(--honey-700)"
  }), /*#__PURE__*/React.createElement("span", null, "\u79BB", goalTitle ? `「${goalTitle}」` : '你的目标', "\u53C8\u8FDC\u4E86 \xA5", yuan));
}
Object.assign(__ds_scope, { CostHint });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/money/CostHint.jsx", error: String((e && e.message) || e) }); }

// components/money/GoalProgress.jsx
try { (() => {
function GoalProgress({
  title,
  savedCents,
  targetCents,
  size = 'child',
  reached,
  style
}) {
  const saved = Math.max(0, Math.round(savedCents / 100));
  const target = Math.round(targetCents / 100);
  const pct = Math.min(100, Math.round(saved / Math.max(1, target) * 100));
  const left = Math.max(0, target - saved);
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      marginBottom: child ? 'var(--space-4)' : 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "target",
    size: child ? 26 : 20,
    color: "var(--honey-700)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)',
      color: 'var(--text-strong)'
    }
  }, title)), /*#__PURE__*/React.createElement("div", {
    style: {
      height: child ? 20 : 12,
      borderRadius: 'var(--radius-pill)',
      background: 'var(--money-goal-track)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: pct + '%',
      height: '100%',
      borderRadius: 'var(--radius-pill)',
      background: reached ? 'var(--leaf-500)' : 'var(--money-goal)',
      transition: 'width var(--dur-slow) var(--ease-out)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      gap: 12,
      marginTop: child ? 'var(--space-4)' : 'var(--space-3)',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-label-size)',
      color: 'var(--text-body)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontVariantNumeric: 'tabular-nums'
    }
  }, "\u5DF2\u6512 \xA5", saved, " / \xA5", target), /*#__PURE__*/React.createElement("span", {
    style: {
      color: reached ? 'var(--money-in)' : 'var(--honey-700)'
    }
  }, reached ? '你可以买了' : `还差 ¥${left}`)));
}
Object.assign(__ds_scope, { GoalProgress });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/money/GoalProgress.jsx", error: String((e && e.message) || e) }); }

// components/money/TransactionRow.jsx
try { (() => {
const KIND = {
  in: {
    icon: 'arrow-down-left',
    bg: 'var(--money-in-bg)',
    fg: 'var(--money-in)'
  },
  out: {
    icon: 'arrow-up-right',
    bg: 'var(--money-out-bg)',
    fg: 'var(--money-out)'
  },
  fix: {
    icon: 'rotate-ccw',
    bg: 'var(--money-fix-bg)',
    fg: 'var(--money-fix)'
  }
};
function TransactionRow({
  reason,
  cents,
  direction = 'in',
  date,
  category,
  balanceAfter,
  size = 'child',
  reversed,
  onClick
}) {
  const k = KIND[direction] || KIND.in;
  const cat = __ds_scope.CATEGORIES.find(c => c.id === category);
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: child ? 'var(--space-5)' : 'var(--space-4)',
      minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
      padding: child ? 'var(--space-4) 0' : 'var(--space-3) 0',
      cursor: onClick ? 'pointer' : undefined,
      opacity: reversed ? 0.55 : 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      placeItems: 'center',
      flex: '0 0 auto',
      width: child ? 48 : 40,
      height: child ? 48 : 40,
      borderRadius: 'var(--radius-md)',
      background: k.bg,
      color: k.fg
    }
  }, cat ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: child ? 24 : 20
    }
  }, cat.emoji) : /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: k.icon,
    size: child ? 24 : 20
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 0,
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
      color: 'var(--text-strong)',
      textDecoration: reversed ? 'line-through' : 'none',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, reason), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 2,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, /*#__PURE__*/React.createElement("span", null, date), reversed ? /*#__PURE__*/React.createElement("span", null, "\xB7 \u5DF2\u6539\u6B63") : null)), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'right',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.AmountText, {
    cents: cents,
    direction: direction,
    size: child ? 'row' : 'small'
  }), balanceAfter !== undefined ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 2,
      fontFamily: 'var(--font-mono)',
      fontSize: child ? 15 : 12,
      color: 'var(--text-faint)'
    }
  }, "\u5269 \xA5", Math.round(balanceAfter / 100)) : null));
}
Object.assign(__ds_scope, { TransactionRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/money/TransactionRow.jsx", error: String((e && e.message) || e) }); }

// components/navigation/NavHeader.jsx
try { (() => {
function NavHeader({
  title,
  onBack,
  action,
  size = 'child',
  subtitle
}) {
  const child = size === 'child';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: child ? 64 : 52,
      padding: child ? '0 var(--gutter-pad)' : '0 var(--gutter-phone)'
    }
  }, onBack ? /*#__PURE__*/React.createElement(__ds_scope.IconButton, {
    icon: "chevron-left",
    label: "\u8FD4\u56DE",
    tone: "bare",
    size: child ? 'parent' : 'small',
    onClick: onBack
  }) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: child ? 'var(--type-child-title-size)' : 'var(--type-title-size)',
      color: 'var(--text-strong)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), subtitle ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 2,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, subtitle) : null), action);
}
Object.assign(__ds_scope, { NavHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/NavHeader.jsx", error: String((e && e.message) || e) }); }

// components/navigation/Sidebar.jsx
try { (() => {
function Sidebar({
  items,
  active,
  onSelect,
  brand = "Forrest's Wallet",
  footer
}) {
  return /*#__PURE__*/React.createElement("nav", {
    style: {
      width: 'var(--sidebar-pad-width)',
      flex: '0 0 auto',
      display: 'flex',
      flexDirection: 'column',
      background: 'var(--surface-ink)',
      color: 'var(--text-on-ink)',
      padding: 'var(--space-8) var(--space-5)',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 900,
      fontSize: 22,
      letterSpacing: 'var(--tracking-tight)',
      color: 'var(--honey-500)',
      padding: '0 var(--space-3)'
    }
  }, brand), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-2)'
    }
  }, items.map(it => {
    const on = it.id === active;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      onClick: () => onSelect && onSelect(it.id),
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 'var(--space-4)',
        minHeight: 'var(--touch-child)',
        padding: '0 var(--space-4)',
        borderRadius: 'var(--radius-lg)',
        border: 'none',
        textAlign: 'left',
        background: on ? 'rgba(251,247,237,.14)' : 'transparent',
        color: on ? 'var(--paper-000)' : 'var(--text-on-ink-muted)',
        fontFamily: 'var(--font-rounded)',
        fontWeight: on ? 800 : 600,
        fontSize: 'var(--type-child-label-size)',
        cursor: 'pointer',
        transition: 'background var(--dur-fast) var(--ease-standard)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: it.icon,
      size: 24
    }), it.label);
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto'
    }
  }, footer));
}
Object.assign(__ds_scope, { Sidebar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/Sidebar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TabBar.jsx
try { (() => {
function TabBar({
  items,
  active,
  onSelect,
  center
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-around',
      gap: 4,
      background: 'var(--surface-card)',
      borderTop: '1px solid var(--border-hair)',
      padding: '6px var(--space-3) 10px'
    }
  }, items.map(it => {
    const on = it.id === active;
    const isCenter = center && it.id === center;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      onClick: () => onSelect && onSelect(it.id),
      "aria-current": on ? 'page' : undefined,
      style: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 3,
        minHeight: 'var(--touch-parent)',
        border: 'none',
        background: 'transparent',
        cursor: 'pointer',
        color: isCenter ? 'var(--action-accent-text)' : on ? 'var(--spruce-700)' : 'var(--text-faint)'
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        display: 'grid',
        placeItems: 'center',
        width: isCenter ? 46 : 30,
        height: isCenter ? 46 : 30,
        borderRadius: isCenter ? 'var(--radius-md)' : 0,
        background: isCenter ? 'var(--action-accent)' : 'transparent',
        boxShadow: isCenter ? 'var(--shadow-card)' : 'none'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: it.icon,
      size: isCenter ? 26 : 24,
      strokeWidth: on || isCenter ? 2.4 : 2
    })), /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--font-rounded)',
        fontWeight: on ? 800 : 600,
        fontSize: 11
      }
    }, it.label));
  }));
}
Object.assign(__ds_scope, { TabBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TabBar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/data.js
try { (() => {
/* Shared mock ledger for both UI kits. Cents in, whole yuan out. */
window.FWData = {
  goal: {
    title: '乐高赛车',
    targetCents: 40000
  },
  balanceCents: 8700,
  tx: [{
    id: 9,
    reason: '本周基础零花钱',
    cents: 1000,
    direction: 'in',
    date: '10月5日',
    balanceAfter: 8700
  }, {
    id: 8,
    reason: '帮忙搬水',
    cents: 200,
    direction: 'in',
    date: '10月4日',
    balanceAfter: 7700
  }, {
    id: 7,
    reason: '买冰淇淋',
    cents: 1500,
    direction: 'out',
    date: '10月3日',
    category: 'food',
    balanceAfter: 7500
  }, {
    id: 6,
    reason: '更正：记错了',
    cents: 300,
    direction: 'fix',
    date: '10月2日',
    balanceAfter: 9000
  }, {
    id: 5,
    reason: '乐高小车',
    cents: 1400,
    direction: 'out',
    date: '10月2日',
    category: 'toy',
    balanceAfter: 8700,
    reversed: true
  }, {
    id: 4,
    reason: '画笔',
    cents: 900,
    direction: 'out',
    date: '9月30日',
    category: 'book',
    balanceAfter: 10100
  }, {
    id: 3,
    reason: '上周基础零花钱',
    cents: 1500,
    direction: 'in',
    date: '9月28日',
    balanceAfter: 11000
  }, {
    id: 2,
    reason: '送同学生日礼物',
    cents: 2000,
    direction: 'out',
    date: '9月26日',
    category: 'gift',
    balanceAfter: 9500
  }, {
    id: 1,
    reason: '期初余额',
    cents: 11500,
    direction: 'in',
    date: '9月20日',
    balanceAfter: 11500
  }],
  board: [{
    name: '跳绳',
    goal: 5,
    rewardCents: 500,
    days: ['done', 'done', 'done', 'unlogged', 'future', 'future', 'future']
  }, {
    name: '喝牛奶',
    goal: 7,
    rewardCents: 500,
    days: ['done', 'done', 'unlogged', 'future', 'future', 'future', 'future']
  }, {
    name: '上学全勤',
    goal: 5,
    rewardCents: 500,
    days: ['done', 'done', 'done', 'unlogged', 'future', 'future', 'future']
  }],
  rules: [{
    name: '跳绳',
    detail: '每周 5 次',
    rewardCents: 500,
    kind: 'base'
  }, {
    name: '喝牛奶',
    detail: '每周 7 次',
    rewardCents: 500,
    kind: 'base'
  }, {
    name: '上学全勤',
    detail: '每周 5 天',
    rewardCents: 500,
    kind: 'base'
  }, {
    name: '三项全达成奖励',
    detail: '三项都做到才有',
    rewardCents: 300,
    kind: 'base'
  }],
  adhoc: [{
    name: '帮忙搬水',
    detail: '10月4日 · 商量好的',
    rewardCents: 200,
    kind: 'adhoc'
  }, {
    name: '主动整理书桌',
    detail: '9月29日 · 商量好的',
    rewardCents: 300,
    kind: 'adhoc'
  }, {
    name: '帮妈妈拿快递',
    detail: '9月24日 · 商量好的',
    rewardCents: 100,
    kind: 'adhoc'
  }],
  changes: [{
    text: '从 10 月 1 日起，跳绳从 5 元变成 3 元',
    date: '10月1日 · 和爸爸一起决定的'
  }, {
    text: '加了新的一项：上学全勤，做到有 5 元',
    date: '9月21日 · 和爸爸一起决定的'
  }],
  wishes: [{
    title: '恐龙拼图',
    cents: 6800,
    date: '8月17日 攒到'
  }, {
    title: '水彩笔一套',
    cents: 4500,
    date: '7月2日 攒到'
  }]
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/data.js", error: String((e && e.message) || e) }); }

// ui_kits/forrest-ipad/child-detail.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  WeekBoard,
  RuleRow,
  ChangeNote,
  TransactionRow,
  Card,
  NavHeader,
  Badge,
  EmptyState,
  SettlementSummary,
  AmountText,
  CostHint,
  Icon
} = window.ForrestSWalletDesignSystem_2e3ae3;
function ChildBoard({
  data
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-title-size)'
    }
  }, "\u672C\u5468\u770B\u677F"), /*#__PURE__*/React.createElement(Card, {
    variant: "child"
  }, /*#__PURE__*/React.createElement(WeekBoard, {
    items: data.board,
    weekLabel: "10\u67081\u65E5 \u2013 10\u67087\u65E5"
  })), /*#__PURE__*/React.createElement(Card, {
    variant: "child",
    tone: "leaf"
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-head-size)',
      marginBottom: 'var(--space-4)'
    }
  }, "\u5468\u65E5\u4E00\u8D77\u7B97\u7B97\u770B"), /*#__PURE__*/React.createElement(SettlementSummary, {
    size: "child",
    lines: [{
      name: '跳绳',
      goal: 5,
      doneCount: 3,
      rewardCents: 500,
      met: false
    }, {
      name: '喝牛奶',
      goal: 7,
      doneCount: 2,
      rewardCents: 500,
      met: false
    }, {
      name: '上学全勤',
      goal: 5,
      doneCount: 3,
      rewardCents: 500,
      met: false
    }],
    bonus: {
      rewardCents: 300,
      met: false
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-5)',
      fontSize: 'var(--type-child-body-size)',
      color: 'var(--spruce-600)'
    }
  }, "\u73B0\u5728\u8FD8\u6CA1\u5230\u5468\u65E5\uFF0C\u7A7A\u7740\u7684\u683C\u5B50\u53EA\u662F\u7238\u7238\u8FD8\u6CA1\u8BB0\u3002")));
}
function ChildRules({
  data
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-title-size)'
    }
  }, "\u89C4\u5219"), /*#__PURE__*/React.createElement(Card, {
    variant: "child"
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-head-size)',
      marginBottom: 'var(--space-3)'
    }
  }, "\u6BCF\u5468\u90FD\u6709\u7684"), data.rules.map(r => /*#__PURE__*/React.createElement(RuleRow, _extends({
    key: r.name
  }, r, {
    met: r.name === '跳绳' ? false : undefined
  })))), /*#__PURE__*/React.createElement(Card, {
    variant: "child"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 10,
      marginBottom: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-head-size)'
    }
  }, "\u5546\u91CF\u597D\u7684"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-child-label-size)',
      color: 'var(--text-muted)'
    }
  }, "\u4E00\u5171 12 \u6761\uFF0C\u4E0B\u9762\u662F\u6700\u8FD1 3 \u6761")), data.adhoc.map(r => /*#__PURE__*/React.createElement(RuleRow, _extends({
    key: r.name
  }, r)))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("h2", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-head-size)',
      marginBottom: 'var(--space-4)'
    }
  }, "\u89C4\u5219\u6539\u8FC7\u54EA\u4E9B"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-4)'
    }
  }, data.changes.map(c => /*#__PURE__*/React.createElement(ChangeNote, _extends({
    key: c.text
  }, c))))));
}
function ChildLedger({
  data
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-6)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-title-size)'
    }
  }, "\u5168\u90E8\u6D41\u6C34"), /*#__PURE__*/React.createElement(CostHint, {
    cents: 1500,
    goalTitle: data.goal.title
  }), /*#__PURE__*/React.createElement(Card, {
    variant: "child"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid'
    }
  }, data.tx.map(t => /*#__PURE__*/React.createElement(TransactionRow, _extends({
    key: t.id
  }, t))))));
}
function ChildWishes({
  data
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-title-size)'
    }
  }, "\u5DF2\u5B9E\u73B0\u7684\u5FC3\u613F"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 'var(--space-5)'
    }
  }, data.wishes.map(w => /*#__PURE__*/React.createElement(Card, {
    key: w.title,
    variant: "child",
    tone: "honey"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "party-popper",
    size: 30,
    color: "var(--honey-700)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-4)',
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: 'var(--type-child-head-size)'
    }
  }, w.title), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-2)'
    }
  }, /*#__PURE__*/React.createElement(AmountText, {
    cents: w.cents,
    direction: "flat",
    showSign: false
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-2)',
      fontSize: 'var(--type-child-label-size)',
      color: 'var(--honey-700)'
    }
  }, w.date)))), /*#__PURE__*/React.createElement(Card, {
    variant: "child",
    tone: "sunken",
    style: {
      padding: 0
    }
  }, /*#__PURE__*/React.createElement(EmptyState, {
    icon: "target",
    title: "\u4E0B\u4E00\u4E2A\u5FC3\u613F\u6B63\u5728\u6512",
    body: `${data.goal.title} · 已攒 ¥${Math.round(data.balanceCents / 100)} / ¥${Math.round(data.goal.targetCents / 100)}`
  })));
}
Object.assign(window, {
  ChildBoard,
  ChildRules,
  ChildLedger,
  ChildWishes
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/forrest-ipad/child-detail.jsx", error: String((e && e.message) || e) }); }

// ui_kits/forrest-ipad/child-home.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  BalanceHero,
  GoalProgress,
  TransactionRow,
  Card,
  StatusBanner,
  Badge,
  Celebration,
  Button
} = window.ForrestSWalletDesignSystem_2e3ae3;
function ChildHome({
  data,
  offline,
  celebrate,
  onDismiss,
  onOpenAll
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-title-size)',
      color: 'var(--text-strong)'
    }
  }, "\u6211\u7684\u94B1"), /*#__PURE__*/React.createElement(StatusBanner, {
    kind: offline ? 'offline' : 'online'
  })), celebrate ? /*#__PURE__*/React.createElement(Celebration, {
    cents: 1000,
    reason: "\u672C\u5468\u57FA\u7840\u96F6\u82B1\u94B1",
    onDone: onDismiss
  }) : null, /*#__PURE__*/React.createElement(BalanceHero, {
    cents: data.balanceCents,
    note: "\u7238\u7238\u8BB0\u4E0B\u7684\u6BCF\u4E00\u7B14\u90FD\u5728\u4E0B\u9762\uFF0C\u4F60\u53EF\u4EE5\u81EA\u5DF1\u6570\u4E00\u904D\u3002"
  }), /*#__PURE__*/React.createElement(Card, {
    variant: "child",
    tone: "honey"
  }, /*#__PURE__*/React.createElement(GoalProgress, {
    title: data.goal.title,
    savedCents: data.balanceCents,
    targetCents: data.goal.targetCents
  })), /*#__PURE__*/React.createElement(Card, {
    variant: "child"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      marginBottom: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-child-head-size)'
    }
  }, "\u94B1\u4E3A\u4EC0\u4E48\u53D8\u4E86"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral",
    icon: "eye",
    size: "child"
  }, "\u53EA\u80FD\u770B")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid'
    }
  }, data.tx.slice(0, 5).map(t => /*#__PURE__*/React.createElement(TransactionRow, _extends({
    key: t.id
  }, t)))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    size: "child",
    tone: "quiet",
    iconAfter: "chevron-right",
    onClick: onOpenAll
  }, "\u770B\u5168\u90E8\u6D41\u6C34"))));
}
Object.assign(window, {
  ChildHome
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/forrest-ipad/child-home.jsx", error: String((e && e.message) || e) }); }

// ui_kits/parent-iphone/entry-flow.jsx
try { (() => {
const {
  AmountField,
  NumberPad,
  TextField,
  CategoryPicker,
  Button,
  Card,
  StatusBanner,
  NavHeader,
  CostHint,
  AmountText,
  Icon,
  Badge
} = window.ForrestSWalletDesignSystem_2e3ae3;

/* 3 taps / 15 seconds: amount → confirm → (skippable) reason & category. */
function EntryFlow({
  direction,
  goalTitle,
  onCancel,
  onDone
}) {
  const [step, setStep] = React.useState('amount');
  const [amt, setAmt] = React.useState('');
  const [reason, setReason] = React.useState('');
  const [cat, setCat] = React.useState();
  const label = {
    in: '加进来多少',
    out: '花了多少',
    fix: '更正多少'
  }[direction];
  const cents = (parseInt(amt || '0', 10) || 0) * 100;
  if (step === 'done') {
    return /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'grid',
        gap: 'var(--space-5)',
        padding: 'var(--space-5)'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        textAlign: 'center',
        padding: 'var(--space-6) 0'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "check-circle-2",
      size: 44,
      color: "var(--money-in)"
    }), /*#__PURE__*/React.createElement("h1", {
      style: {
        marginTop: 'var(--space-4)',
        fontFamily: 'var(--font-rounded)',
        fontSize: 'var(--type-title-size)'
      }
    }, "\u5DF2\u8BB0\u5F55"), /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: 'var(--space-3)'
      }
    }, /*#__PURE__*/React.createElement(AmountText, {
      cents: cents,
      direction: direction,
      size: "heroSm"
    })), /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: 'var(--space-2)',
        color: 'var(--text-muted)'
      }
    }, reason || '（没写事由）')), /*#__PURE__*/React.createElement(StatusBanner, {
      size: "parent",
      kind: "norealmoney",
      text: "\u5DF2\u8BB0\u5F55 \xB7 \u6CA1\u6709\u4EFB\u4F55\u771F\u5B9E\u8D44\u91D1\u79FB\u52A8"
    }), direction === 'out' ? /*#__PURE__*/React.createElement(CostHint, {
      cents: cents,
      goalTitle: goalTitle
    }) : null, /*#__PURE__*/React.createElement(Button, {
      tone: "primary",
      block: true,
      onClick: onDone
    }, "\u56DE\u9996\u9875"));
  }
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement(NavHeader, {
    size: "parent",
    title: {
      in: '加进来',
      out: '花掉了',
      fix: '更正这笔'
    }[direction],
    onBack: onCancel,
    action: direction === 'fix' ? /*#__PURE__*/React.createElement(Badge, {
      tone: "fix",
      icon: "rotate-ccw"
    }, "\u7559\u75D5") : null
  }), step === 'amount' ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      padding: '0 var(--gutter-phone) var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(AmountField, {
    value: amt,
    direction: direction,
    label: label
  }), /*#__PURE__*/React.createElement(NumberPad, {
    value: amt,
    onChange: setAmt
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      paddingTop: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "primary",
    block: true,
    disabled: !amt,
    onClick: () => setStep('extra')
  }, "\u786E\u8BA4\u8BB0\u5F55"))) : /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'grid',
      gap: 'var(--space-5)',
      alignContent: 'start',
      padding: '0 var(--gutter-phone) var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(Card, {
    tone: "sunken",
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement(AmountText, {
    cents: cents,
    direction: direction,
    size: "heroSm"
  })), /*#__PURE__*/React.createElement(TextField, {
    label: "\u4E3A\u4EC0\u4E48",
    placeholder: "\u4E70\u51B0\u6DC7\u6DCB",
    optional: true,
    maxLength: 8,
    value: reason,
    onChange: setReason
  }), direction === 'out' ? /*#__PURE__*/React.createElement(CategoryPicker, {
    value: cat,
    onChange: setCat
  }) : null, direction === 'fix' ? /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: "\u539F\u8BB0\u5F55\u4F1A\u4FDD\u7559\uFF0C\u53E6\u5916\u5199\u5165\u4E00\u7B14\u51B2\u6B63"
  }) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "primary",
    block: true,
    onClick: () => setStep('done')
  }, "\u8BB0\u4E0B\u6765"), /*#__PURE__*/React.createElement(Button, {
    tone: "quiet",
    block: true,
    onClick: () => setStep('done')
  }, "\u90FD\u8DF3\u8FC7\uFF0C\u76F4\u63A5\u8BB0"))));
}
Object.assign(window, {
  EntryFlow
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/parent-iphone/entry-flow.jsx", error: String((e && e.message) || e) }); }

// ui_kits/parent-iphone/other-screens.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  WeekBoard,
  SettlementSummary,
  RuleRow,
  ChangeNote,
  TransactionRow,
  Card,
  Button,
  NavHeader,
  Toggle,
  StatusBanner,
  Badge,
  TextField,
  Icon,
  AmountText,
  Celebration
} = window.ForrestSWalletDesignSystem_2e3ae3;

/* Today is Thursday in the mock week: days 0–3 are loggable, 4–6 are still 未到. */
const TODAY = 3;
const freshDays = () => Array.from({
  length: 7
}, (_, i) => i <= TODAY ? 'unlogged' : 'future');

/* Add / rename / delete a check-in item, and edit its weekly target and amount.
   Rules are editable by design (PRD §5.4) — the set grows as Forrest gets older.
   There is no rule versioning: settlement snapshots the name and amount into the
   transaction, and every change leaves a note on Forrest's side. */
function ItemEditor({
  item,
  onSave,
  onDelete,
  onCancel
}) {
  const [name, setName] = React.useState(item.name || '');
  const [goal, setGoal] = React.useState(String(item.goal ?? 5));
  const [yuan, setYuan] = React.useState(String(Math.round((item.rewardCents ?? 500) / 100)));
  const isNew = !item.name;
  const valid = name.trim() && parseInt(goal, 10) > 0 && parseInt(goal, 10) <= 7 && parseInt(yuan, 10) >= 0;
  return /*#__PURE__*/React.createElement(Card, {
    tone: "sunken"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-head-size)'
    }
  }, isNew ? '加一项打卡' : '改「' + item.name + '」'), /*#__PURE__*/React.createElement(TextField, {
    label: "\u6253\u5361\u9879\u540D\u79F0",
    placeholder: "\u4F8B\u5982\uFF1A\u7EC3\u7434",
    value: name,
    onChange: setName,
    maxLength: 6
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement(TextField, {
    label: "\u6BCF\u5468\u76EE\u6807\u6B21\u6570",
    value: goal,
    onChange: v => setGoal(v.replace(/\D/g, '').slice(0, 1))
  }), /*#__PURE__*/React.createElement(TextField, {
    label: "\u505A\u5230\u7ED9\u591A\u5C11\uFF08\u5143\uFF09",
    value: yuan,
    onChange: v => setYuan(v.replace(/\D/g, '').slice(0, 3))
  })), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: isNew ? '新加的项从这周开始算，Forrest 的规则页会出现一条记录' : '改完会在 Forrest 的规则页留一条变更记录'
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "primary",
    block: true,
    disabled: !valid,
    onClick: () => onSave({
      name: name.trim(),
      goal: parseInt(goal, 10),
      rewardCents: parseInt(yuan, 10) * 100
    })
  }, "\u4FDD\u5B58"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: onDelete ? '1fr 1fr' : '1fr',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "quiet",
    block: true,
    onClick: onCancel
  }, "\u53D6\u6D88"), onDelete ? /*#__PURE__*/React.createElement(Button, {
    tone: "danger",
    icon: "trash-2",
    block: true,
    onClick: onDelete
  }, "\u5220\u6389\u8FD9\u9879") : null))));
}
function ParentBoard({
  items,
  setItems,
  bonusCents,
  setBonusCents
}) {
  const [editing, setEditing] = React.useState(null); // index, or 'new'
  const [bonusEdit, setBonusEdit] = React.useState(false);
  const [bonusDraft, setBonusDraft] = React.useState(String(Math.round(bonusCents / 100)));
  const toggle = (r, c) => setItems(b => b.map((row, i) => i !== r ? row : {
    ...row,
    days: row.days.map((s, j) => j !== c ? s : s === 'done' ? 'unlogged' : 'done')
  }));
  const total = items.reduce((s, it) => s + (it.days.filter(d => d === 'done').length >= it.goal ? it.rewardCents : 0), 0);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "\u672C\u5468\u770B\u677F"), /*#__PURE__*/React.createElement(Button, {
    size: "small",
    tone: "accent",
    icon: "plus",
    onClick: () => setEditing('new')
  }, "\u52A0\u4E00\u9879")), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(WeekBoard, {
    size: "parent",
    items: items,
    onToggle: toggle,
    weekLabel: "10\u67081\u65E5 \u2013 10\u67087\u65E5"
  })), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: "\u968F\u65F6\u53EF\u4EE5\u8865\u52FE \xB7 \u53EA\u6709\u5468\u65E5\u7ED3\u7B97\u624D\u4F1A\u7B97\u6210\u672A\u8FBE\u6210"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      marginBottom: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-head-size)'
    }
  }, "\u8FD9\u4E9B\u9879\u76EE\u548C\u91D1\u989D"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral",
    icon: "pencil-line"
  }, "\u53EF\u4EE5\u6539")), items.map((it, i) => /*#__PURE__*/React.createElement(RuleRow, {
    key: it.name + i,
    size: "parent",
    name: it.name,
    detail: '每周 ' + it.goal + ' 次 · 已做到 ' + it.days.filter(d => d === 'done').length + ' 次',
    rewardCents: it.rewardCents,
    onClick: () => setEditing(i)
  })), /*#__PURE__*/React.createElement("div", {
    onClick: () => setBonusEdit(true),
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      minHeight: 'var(--touch-parent)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "gift",
    size: 18,
    color: "var(--honey-700)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-body-size)'
    }
  }, "\u5168\u90E8\u8FBE\u6210\u5956\u52B1"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, items.length, " \u9879\u90FD\u505A\u5230\u624D\u6709")), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontVariantNumeric: 'tabular-nums',
      fontSize: 'var(--type-amount-sm-size)',
      color: 'var(--honey-700)'
    }
  }, "\xA5", Math.round(bonusCents / 100)), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right",
    size: 18,
    color: "var(--text-faint)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-4)',
      paddingTop: 'var(--space-4)',
      borderTop: '2px solid var(--spruce-700)',
      display: 'flex',
      alignItems: 'baseline',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontWeight: 800,
      fontSize: 'var(--type-head-size)'
    }
  }, "\u6309\u73B0\u5728\u7684\u8FDB\u5EA6\uFF0C\u672C\u5468"), /*#__PURE__*/React.createElement(AmountText, {
    cents: total,
    direction: "in"
  }))), editing === 'new' ? /*#__PURE__*/React.createElement(ItemEditor, {
    item: {},
    onCancel: () => setEditing(null),
    onSave: v => {
      setItems(b => [...b, {
        ...v,
        days: freshDays()
      }]);
      setEditing(null);
    }
  }) : editing !== null ? /*#__PURE__*/React.createElement(ItemEditor, {
    item: items[editing],
    onCancel: () => setEditing(null),
    onSave: v => {
      setItems(b => b.map((row, i) => i !== editing ? row : {
        ...row,
        ...v
      }));
      setEditing(null);
    },
    onDelete: () => {
      setItems(b => b.filter((_, i) => i !== editing));
      setEditing(null);
    }
  }) : null, bonusEdit ? /*#__PURE__*/React.createElement(Card, {
    tone: "sunken"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement(TextField, {
    label: "\u5168\u90E8\u8FBE\u6210\u5956\u52B1\uFF08\u5143\uFF09",
    value: bonusDraft,
    onChange: v => setBonusDraft(v.replace(/\D/g, '').slice(0, 3))
  }), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: "\u5206\u9879\u8BA1\u5206 + \u5168\u52E4\u5956\uFF1A\u6F0F\u4E00\u9879\u4E0D\u4F1A\u5F52\u96F6\uFF0C\u575A\u6301\u5230\u5E95\u53E6\u6709\u4EF7\u503C"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "quiet",
    block: true,
    onClick: () => setBonusEdit(false)
  }, "\u53D6\u6D88"), /*#__PURE__*/React.createElement(Button, {
    tone: "primary",
    block: true,
    onClick: () => {
      setBonusCents((parseInt(bonusDraft, 10) || 0) * 100);
      setBonusEdit(false);
    }
  }, "\u4FDD\u5B58")))) : null);
}
function ParentSettle({
  onConfirm,
  done,
  items,
  bonusCents
}) {
  const lines = items.map(it => {
    const doneCount = it.days.filter(d => d === 'done').length;
    return {
      name: it.name,
      goal: it.goal,
      doneCount,
      rewardCents: it.rewardCents,
      met: doneCount >= it.goal
    };
  });
  const bonusMet = lines.length > 0 && lines.every(l => l.met);
  const total = lines.reduce((s, l) => s + (l.met ? l.rewardCents : 0), 0) + (bonusMet ? bonusCents : 0);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "\u5468\u65E5\u7ED3\u7B97"), done ? /*#__PURE__*/React.createElement(Celebration, {
    cents: total,
    reason: "\u672C\u5468\u57FA\u7840\u96F6\u82B1\u94B1 \xB7 \u5DF2\u5165\u8D26"
  }) : null, /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SettlementSummary, {
    size: "parent",
    lines: lines,
    bonus: {
      rewardCents: bonusCents,
      met: bonusMet
    }
  })), /*#__PURE__*/React.createElement(Card, {
    tone: "sunken"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)',
      lineHeight: 1.5
    }
  }, "\u89C4\u5219\u540D\u548C\u91D1\u989D\u4F1A\u7167\u73B0\u5728\u7684\u6837\u5B50\u5B58\u8FDB\u8FD9\u7B14\u4EA4\u6613\u91CC\uFF0C\u4EE5\u540E\u6539\u89C4\u5219\u4E5F\u4E0D\u4F1A\u6539\u5199\u8FD9\u4E00\u5468\u7684\u5386\u53F2\u3002")), /*#__PURE__*/React.createElement(Button, {
    tone: "accent",
    icon: "check",
    block: true,
    disabled: done,
    onClick: onConfirm
  }, done ? '本周已入账' : '确认，记入 +¥' + Math.round(total / 100)));
}
function ParentRules({
  data,
  items,
  bonusCents
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "\u89C4\u5219\u6E05\u5355"), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-head-size)',
      marginBottom: 'var(--space-2)'
    }
  }, "\u6BCF\u5468\u90FD\u6709\u7684"), items.map((r, i) => /*#__PURE__*/React.createElement(RuleRow, {
    key: r.name + i,
    size: "parent",
    name: r.name,
    detail: '每周 ' + r.goal + ' 次',
    rewardCents: r.rewardCents,
    kind: "base"
  })), /*#__PURE__*/React.createElement(RuleRow, {
    size: "parent",
    name: "\u5168\u90E8\u8FBE\u6210\u5956\u52B1",
    detail: items.length + ' 项都做到才有',
    rewardCents: bonusCents,
    kind: "base"
  })), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: "\u9879\u76EE\u548C\u91D1\u989D\u5728\u300C\u672C\u5468\u770B\u677F\u300D\u91CC\u6539 \xB7 \u6539\u5B8C\u8FD9\u91CC\u548C Forrest \u7684\u89C4\u5219\u9875\u540C\u6B65"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 10,
      marginBottom: 'var(--space-2)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-head-size)'
    }
  }, "\u5546\u91CF\u597D\u7684"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, "\u4E00\u4E8B\u4E00\u8BAE\uFF0C\u76F4\u63A5\u8BB0\u8D26")), data.adhoc.map(r => /*#__PURE__*/React.createElement(RuleRow, _extends({
    key: r.name,
    size: "parent"
  }, r)))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-3)'
    }
  }, data.changes.map(c => /*#__PURE__*/React.createElement(ChangeNote, _extends({
    key: c.text,
    size: "parent"
  }, c)))));
}
function ParentHistory({
  data
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "\u5168\u90E8\u8BB0\u5F55"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral",
    icon: "lock"
  }, "\u4E0D\u53EF\u5220\u9664")), /*#__PURE__*/React.createElement(Card, null, data.tx.map(t => /*#__PURE__*/React.createElement(TransactionRow, _extends({
    key: t.id,
    size: "parent"
  }, t, {
    onClick: () => {}
  })))), /*#__PURE__*/React.createElement(Card, {
    tone: "sunken"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "link",
    size: 18,
    color: "var(--money-fix)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)',
      lineHeight: 1.5
    }
  }, "10\u67082\u65E5\u300C\u4E50\u9AD8\u5C0F\u8F66 \u2212\xA514\u300D\u5DF2\u88AB\u51B2\u6B63\uFF0C\u5E76\u5199\u5165\u6B63\u786E\u7684\u4E00\u7B14\u3002\u539F\u8BB0\u5F55\u3001\u51B2\u6B63\u3001\u6B63\u786E\u8BB0\u5F55\u4E09\u6761\u4E92\u76F8\u5173\u8054\uFF0C\u90FD\u7559\u5728\u6D41\u6C34\u91CC\u3002"))));
}
function ParentSettings() {
  const [remind, setRemind] = React.useState(true);
  const [pin, setPin] = React.useState(true);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "\u8BBE\u7F6E"), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-head-size)',
      marginBottom: 'var(--space-3)'
    }
  }, "\u5DF2\u914D\u5BF9\u7684\u8BBE\u5907"), [['Forrest 的 iPad', '儿童 · 只读', 'tablet'], ['爸爸的 iPhone', '家长 · 可写入（本机）', 'smartphone']].map(([n, r, ic]) => /*#__PURE__*/React.createElement("div", {
    key: n,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      minHeight: 'var(--touch-parent)',
      borderBottom: '1px solid var(--border-hair)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: ic,
    size: 20,
    color: "var(--spruce-600)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 600
    }
  }, n), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, r)), /*#__PURE__*/React.createElement(Button, {
    size: "small",
    tone: "quiet"
  }, "\u64A4\u9500"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'var(--space-4)',
      display: 'grid',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "primary",
    icon: "plus",
    block: true
  }, "\u6DFB\u52A0\u8BBE\u5907\uFF08\u751F\u6210\u914D\u5BF9\u7801\uFF09"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--text-muted)'
    }
  }, "6 \u4F4D\u6570\u5B57 \xB7 10 \u5206\u949F\u8FC7\u671F \xB7 \u7528\u4E00\u6B21\u5373\u4F5C\u5E9F"))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(Toggle, {
    label: "\u5468\u65E5\u7ED3\u7B97\u63D0\u9192",
    hint: "\u53EA\u53D1\u7ED9\u7238\u7238\u3002Forrest \u7684 iPad \u4E0A\u4E00\u6761\u901A\u77E5\u90FD\u4E0D\u4F1A\u6709\u3002",
    checked: remind,
    onChange: setRemind
  }), /*#__PURE__*/React.createElement(Toggle, {
    label: "\u9884\u89C8\u513F\u7AE5\u89C6\u56FE\u9700\u8981 PIN",
    hint: "PIN \u53EA\u4FDD\u62A4\u8FD9\u4E2A\u5165\u53E3\uFF0C\u6743\u9650\u4ECD\u7531\u670D\u52A1\u7AEF\u5F3A\u5236",
    checked: pin,
    onChange: setPin
  })), /*#__PURE__*/React.createElement(Card, {
    tone: "sunken"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "outline",
    icon: "eye",
    block: true
  }, "\u9884\u89C8 Forrest \u770B\u5230\u7684\u753B\u9762"), /*#__PURE__*/React.createElement(Button, {
    tone: "outline",
    icon: "repeat",
    block: true
  }, "\u91CD\u65B0\u914D\u5BF9"))), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "norealmoney",
    text: "\u8FD9\u4E2A App \u53EA\u8BB0\u5F55\u6570\u5B57\uFF0C\u4E0D\u63A5\u89E6\u94F6\u884C\u5361\u3001\u4E5F\u4E0D\u8F6C\u79FB\u73B0\u91D1"
  }));
}
Object.assign(window, {
  ParentBoard,
  ParentSettle,
  ParentRules,
  ParentHistory,
  ParentSettings,
  ItemEditor
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/parent-iphone/other-screens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/parent-iphone/parent-home.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  BalanceHero,
  TransactionRow,
  Card,
  Button,
  StatusBanner,
  Badge,
  GoalProgress,
  Icon
} = window.ForrestSWalletDesignSystem_2e3ae3;
function ParentHome({
  data,
  online,
  onEntry,
  onSettle,
  onOpen
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-title-size)'
    }
  }, "Forrest \u7684\u8D26\u672C"), /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: online ? 'online' : 'failed',
    text: online ? '已连上' : '离线 · 不能记账'
  })), /*#__PURE__*/React.createElement(BalanceHero, {
    cents: data.balanceCents,
    size: "parent",
    note: "1:1 \u65E0\u6761\u4EF6\u5151\u73B0 \xB7 \u4ED6\u771F\u7684\u6709\u8FD9\u4E48\u591A"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr 1fr',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    tone: "accent",
    icon: "plus",
    block: true,
    disabled: !online,
    onClick: () => onEntry('in')
  }, "\u52A0\u8FDB\u6765"), /*#__PURE__*/React.createElement(Button, {
    tone: "quiet",
    icon: "minus",
    block: true,
    disabled: !online,
    onClick: () => onEntry('out')
  }, "\u82B1\u6389\u4E86"), /*#__PURE__*/React.createElement(Button, {
    tone: "outline",
    icon: "rotate-ccw",
    block: true,
    disabled: !online,
    onClick: () => onEntry('fix')
  }, "\u66F4\u6B63")), !online ? /*#__PURE__*/React.createElement(StatusBanner, {
    size: "parent",
    kind: "failed",
    text: "\u6CA1\u6709\u5199\u5165\u4EFB\u4F55\u8BB0\u5F55 \u2014\u2014 \u8BB0\u8D26\u5FC5\u987B\u8054\u7F51"
  }) : null, /*#__PURE__*/React.createElement(Card, {
    onClick: onSettle,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      background: 'var(--surface-leaf)',
      border: 'none'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "calendar-check",
    size: 22,
    color: "var(--spruce-700)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-rounded)',
      fontWeight: 700,
      fontSize: 'var(--type-body-size)'
    }
  }, "\u5468\u65E5\u7ED3\u7B97\u7B49\u4F60\u786E\u8BA4"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--type-caption-size)',
      color: 'var(--spruce-600)'
    }
  }, "\u4E09\u9879\u8FBE\u6210\u4E24\u9879 \xB7 \u672C\u5468 \xA510")), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right",
    size: 20,
    color: "var(--spruce-600)"
  })), /*#__PURE__*/React.createElement(Card, {
    tone: "honey"
  }, /*#__PURE__*/React.createElement(GoalProgress, {
    size: "parent",
    title: data.goal.title,
    savedCents: data.balanceCents,
    targetCents: data.goal.targetCents
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      marginBottom: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-rounded)',
      fontSize: 'var(--type-head-size)'
    }
  }, "\u6700\u8FD1\u8BB0\u7684"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral",
    icon: "lock"
  }, "\u4E0D\u80FD\u5220")), data.tx.slice(0, 4).map(t => /*#__PURE__*/React.createElement(TransactionRow, _extends({
    key: t.id,
    size: "parent"
  }, t, {
    onClick: () => onOpen(t)
  })))));
}
Object.assign(window, {
  ParentHome
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/parent-iphone/parent-home.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.CATEGORIES = __ds_scope.CATEGORIES;

__ds_ns.Tag = __ds_scope.Tag;

__ds_ns.Celebration = __ds_scope.Celebration;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.StatusBanner = __ds_scope.StatusBanner;

__ds_ns.AmountField = __ds_scope.AmountField;

__ds_ns.CategoryPicker = __ds_scope.CategoryPicker;

__ds_ns.NumberPad = __ds_scope.NumberPad;

__ds_ns.TextField = __ds_scope.TextField;

__ds_ns.Toggle = __ds_scope.Toggle;

__ds_ns.ChangeNote = __ds_scope.ChangeNote;

__ds_ns.RuleRow = __ds_scope.RuleRow;

__ds_ns.SettlementSummary = __ds_scope.SettlementSummary;

__ds_ns.BoardCell = __ds_scope.BoardCell;

__ds_ns.WeekBoard = __ds_scope.WeekBoard;

__ds_ns.AmountText = __ds_scope.AmountText;

__ds_ns.BalanceHero = __ds_scope.BalanceHero;

__ds_ns.CostHint = __ds_scope.CostHint;

__ds_ns.GoalProgress = __ds_scope.GoalProgress;

__ds_ns.TransactionRow = __ds_scope.TransactionRow;

__ds_ns.NavHeader = __ds_scope.NavHeader;

__ds_ns.Sidebar = __ds_scope.Sidebar;

__ds_ns.TabBar = __ds_scope.TabBar;

})();
