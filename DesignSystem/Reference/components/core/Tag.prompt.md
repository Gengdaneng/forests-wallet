Spend category, shown as emoji + word. Categories are optional on entry and default to 其他.

```jsx
{CATEGORIES.map(c => <Tag key={c.id} category={c.id} selected={pick===c.id} onClick={()=>setPick(c.id)} />)}
```

These six are fixed for MVP; there is no category editor.
