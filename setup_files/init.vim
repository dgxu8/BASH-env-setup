set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

nnoremap <F9> :split term://bash<CR>
tnoremap <Esc> <C-\><C-n>
tnoremap <F9> :q<CR>
nmap <leader>~ :source ~/.config/nvim/init.vim<CR>:redraw!<CR>:echo "~/.config/nvim/init.vim reloaded!"<CR>

" autocommand for running PackerCompile whenever plugins.lua is changed
augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

lua require('plugins')
lua << EOF

----------------
-- Setup scrollbar
----------------
require("scrollbar").setup()

----------------
-- Setup neoscroll
----------------
require('neoscroll').setup({
  easing_function = "sine"
})
local scroll = {}
-- Syntax: scroll[keys] = {function, {function arguments}}
-- Use the "sine" easing function
scroll['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '80', [['sine']]}}
scroll['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '80', [['sine']]}}
-- Use the "circular" easing function
scroll['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', '150', [['sine']]}}
scroll['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '150', [['sine']]}}
-- Pass "nil" to disable the easing animation (constant scrolling speed)
--scroll['<C-y>'] = {'scroll', {'-0.10', 'false', '30', nil}}
--scroll['<C-e>'] = {'scroll', { '0.10', 'false', '30', nil}}
-- When no easing function is provided the default easing function (in this case "quadratic") will be used
scroll['zt']    = {'zt', {'100'}}
scroll['zz']    = {'zz', {'100'}}
scroll['zb']    = {'zb', {'100'}}

require('neoscroll.config').set_mappings(scroll)

----------------
-- Setup Lualine
----------------
require('lualine').setup {
  options = {
    theme = 'powerline',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1,
        shorting_target = 40,
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]', -- Text to show for unnamed buffers.
        }
      }
    },
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        show_filename_only = false,
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
}


-------------------
-- Setup Treesitter
-------------------
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "cpp", "lua", "rust", "python", "yaml", "cmake" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- Add additional capabilities supported by nvim-cmp
local my_capabilities = vim.lsp.protocol.make_client_capabilities()
my_capabilities = require('cmp_nvim_lsp').default_capabilities(my_capabilities)

local lspconfig = require('lspconfig')

-- keybinds
local my_on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
lspconfig.pylsp.setup {
  on_attach = my_on_attach,
  capabilities = my_capabilities,
  flags = {
      debounce_text_changes = 200,
      allow_incremental_sync = false
  },
}

lspconfig.ccls.setup {
  on_attach = my_on_attach,
  capabilities = my_capabilities,
  flags = {
      debounce_text_changes = 150
  }
}

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
local lspkind = require('lspkind')
cmp.setup {
  formatting = {
    format = lspkind.cmp_format({
      with_text = false, -- do not show text alongside icons
      maxwidth = 80, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
    })
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
EOF

function FoldConfig()
	set foldmethod=expr
	set foldexpr=nvim_treesitter#foldexpr()
endfunction
autocmd BufAdd,BufEnter,BufNew,BufNewFile,BufWinEnter * :call FoldConfig()
