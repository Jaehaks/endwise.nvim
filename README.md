# smart_cr.nvim
Support library to smart `<CR>`


# why?

I want to implement smart `<CR>` such as `endwise` or `indented in parentheses`. \
There are already many useful plugins that do this job. They supports smart `<CR>` inherently only.
Their `<CR>` features can be enable or disable only and I cannot customize them easily.
Some plugins are supports adjusting their rules but it is too complex to use as beginner.
I didn't encounter perfect plugin to support autopair / endwise / smart_cr.
So I needs to customize `<CR>` behavior properly.


# Installation

If you use `lazy.nvim`

```lua
return {
	'Jaehaks/smart_cr.nvim',
	opts = {

	}
}
```


# Configuration

<details>
	<summary> Default configuration </summary>

```lua
require('smart_cr').setup({
  bracket_cr = {
    enabled = true, -- on/off bracket_cr
    bracket_pairs = {
      ['('] = ')',
      ['['] = ']',
      ['{'] = '}',
      ['<'] = '>',
    }
  }
})
```


</details>


# API

## 1) `<CR>` inside of brackets

case1) empty parentheses
```lua
-- before
a = {|}

-- after
a = {
  |
}
```

case2) non-empty parentheses
```lua
-- before
a = {aa |bb}

-- after
a = {aa
  |bb}
```

To implement this, you can set keymap like this

```lua
vim.keymap.set('i', '<CR>', function()
	-- Check cursor is inside of brackets or return false
	-- If cursor is inside of bracket, add indented new line
	local bracket = require('smart_cr').bracket.bracket_cr()
	if not bracket then -- fallback to original enter
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
	end
end, { noremap = true, silent = true, desc = 'Smart enter' })
```

In many plugins implements this feature by replacing keycodes. \
It makes customization easier, but some languages are applied by different indentexpr.
This characters can be a disadvantage because the behavior is not always consistent according to languages.
(ex. python)
In `smart_cr.nvim`, It is purpose to support consistent behavior always. \
<u>Indentation will be changed by `vim.bo.shiftwidth` of user setting</u>




