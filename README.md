# smart_cr.nvim
Support library to customize `<CR>`


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
  },
  endwise_cr = {
    enabled = true,
    rules = {
      lua = {
        -- do_statement can be endwised with 'end' or 'until'. Both case are not supported
        {'then%s*$',                'end', {'if_statement'}},
        {'do%s*$',                  'end', {'for_statement',
											'while_statement',
											'do_statement'}},
        {'function.*%(.*%)%s*$',    'end', {'function_definition',
											'local_function',
											'function_declaration'}},
      },
      matlab = {
        {'if%s+.+$',             'end', {'if_statement'}},
        {'while%s+.+$',          'end', {'while_statement'}},
        {'for%s+.+$',            'end', {'while_statement'}},
        {'switch.*$',            'end', {'switch_statement'}},
        {'try.*$',               'end', {'try_statement'}},
        {'classdef%s+.+$',       'end', {'class_definition'}},
        {'properties.*$',        'end', {'properties'}},
        {'methods.*$',           'end', {'methods'}},
        {'function%s+.*%(.*%)$', 'end', {'function_definition',
										 'function_declaration',
										 'function_signature'}},
      },
      sh = {
        {'then%s*$', 'fi', {'if_statement'}},
        {'do%s*$',   'done', {'while_statement', 'for_statement', 'until_statement'}},
        {'in%s*$',   'esac', {'case_statement'}},
      },
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


## 2) `<CR>` for endwise

```lua
-- before
if a==b then|

-- after
if a==b then
  |
end
```

To implement this, you can set keymap like this

```lua
vim.keymap.set('i', '<CR>', function()
  -- The order of calls order between bracket and endwise doesn't matter
  -- you can use 'endwise_cr()' independently
  local bracket = require('smart_cr').bracket.bracket_cr()
  local endwise = require('smart_cr').endwise.endwise_cr()

  if not bracket and not endwise then
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end, { noremap = true, silent = true, desc = 'Smart enter' })
```

I know there are endwise plugins already, the reason I created this is
because the previous ones were unreliable to use or configure as I think.

There are some purpose to make endwise feature.
1) **_Implementation of loose judgment criteria_**
	- It is annoying to add endwise when only syntax is exact.
	  I just wanted to input `end` with anything condition expression. Error will be detected by lsp.
2) **_Implementation of a solid configuration._**
	- Many endwise plugins are use treesitter to check endwise and require nodes in configuration. \
	  Operation of treesitter parser is different by languages. Some languages change current node to `ERROR` node
	  instead of recognizing sub-nodes or fields as errors or the treesitter parser's incomplete aspect is
	  shown differently according to statement location in context.
	- I was confused about how to configure it according to the language and
	  why it didn't work even though I wrote it the same way.


### _Main point to configure_

```lua
lua = {
  {'function.*%(.*%)%s*$',    'end', {'function_definition', 'local_function', 'function_declaration'}},
}
```

- You can add any filetype to `rules` field as key. Endword will be added by filetype.
- `table[1]:string` : Lua regex pattern to check this line is worth adding end
	- You can specify this pattern more in detail.
- `table[2]:string` : End word to add
- `table[3]:table` : Treesitter <u>named</u> node <u>which supports endwise</u>.
	- It means if you executes `vim.treesitter.get_node_text()` to this node, it needs to have end word.
	- You may need to add `ERROR` node to some languages when you use other plugins.
	  But you don't need to add this plugin. You just need to identify and write the treesitter node
	  when the grammar is correct overall.




