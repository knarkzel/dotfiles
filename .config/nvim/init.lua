-- Bootstrap
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

-- Config
local packer = require 'packer'
local use = packer.use

packer.init({git = { clone_timeout = 1000 }})

use {'wbthomason/packer.nvim', opt = true}

use 'airblade/vim-rooter'

use 'sheerun/vim-polyglot'

use 'neovim/nvim-lspconfig'

use 'tpope/vim-commentary'

use 'tpope/vim-surround'

use 'tpope/vim-repeat'

use 'tpope/vim-vinegar'

use 'dmix/elvish.vim'

use 'NoahTheDuke/vim-just'

use { 'ms-jpq/coq_nvim', branch = 'coq'}

use 'EdenEast/nightfox.nvim'
vim.g.nightfox_style = "nightfox"
vim.g.nightfox_italic_comments = 1
require('nightfox').set()

vim.cmd([[
  let g:coq_settings = { 'auto_start': v:true }
]])

use 'roxma/nvim-yarp'
use 'roxma/vim-hug-neovim-rpc'

use 'Shougo/neosnippet.vim'
use 'Shougo/neosnippet-snippets'
vim.cmd([[
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)
]])
vim.cmd("let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'")

-- Telescope
use {
  'nvim-telescope/telescope.nvim',
  requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
}
use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
local actions = require('telescope.actions')
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
    }
  },
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  }
}
require('telescope').load_extension('fzf')

use {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "rust", "lua", "zig" },
      highlight = {
        enable = true,
      },
    }
  end
}

use 'David-Kunz/treesitter-unit'
vim.api.nvim_set_keymap('x', 'iu', ':lua require"treesitter-unit".select()<CR>', {noremap=true})
vim.api.nvim_set_keymap('x', 'au', ':lua require"treesitter-unit".select(true)<CR>', {noremap=true})
vim.api.nvim_set_keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', {noremap=true})
vim.api.nvim_set_keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', {noremap=true})

local nvim_lsp = require 'lspconfig'

local on_attach = function(_, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<C-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

nvim_lsp.tsserver.setup {
    on_attach = on_attach,
}

nvim_lsp.html.setup {
    on_attach = on_attach,
}

nvim_lsp.zls.setup {
    on_attach = on_attach,
}

nvim_lsp.ccls.setup{
    on_attach = on_attach,
}

nvim_lsp.rust_analyzer.setup {
  on_attach = on_attach,

  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        enable = true
      }
    }
  }
}

nvim_lsp.sumneko_lua.setup {
  cmd = { "/usr/bin/lua-language-server" };
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

vim.g.mapleader = " "
vim.o.autochdir = true
vim.o.autoread = true
vim.o.backup = false
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.lazyredraw = true
vim.o.mouse = "a"
vim.o.path = "**"
vim.o.pumheight = 10
vim.o.showcmd = true
vim.o.showmode = false
vim.o.shiftwidth = 4
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.swapfile = false
vim.o.switchbuf = "usetab"
vim.o.syntax = "on"
vim.o.tabstop = 4
vim.o.expandtab = false
vim.o.termguicolors = true
vim.o.wildignore = "*target/*,*.git/*,Cargo.lock"
vim.o.wildmenu = true
vim.o.wrap = false
vim.o.writebackup = false
vim.wo.number = true
vim.wo.relativenumber = true

vim.g.rooter_silent_chdir = 1
vim.g.rooter_change_directory_for_non_project_files = 'current'

vim.api.nvim_set_keymap('', 'Q', ':qa!<CR>', {})
vim.api.nvim_set_keymap('n', '0', '^', { noremap = true })
vim.api.nvim_set_keymap('n', '<ESC>', ':noh<CR><ESC>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>o', ':e ~/.config/nvim/init.lua<CR>', {})

vim.api.nvim_set_keymap('n', '<Leader>m', '<cmd>Telescope<cr>', {})

vim.cmd('autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o')

vim.cmd('au TermOpen * tnoremap <buffer> <Esc> <c-\\><c-n>')

vim.cmd('set signcolumn=yes')

vim.cmd('autocmd FileType cpp nnoremap <leader><leader> :!g++ -g --std=c++11 -Wall % -o %:r<CR>')

vim.cmd('set tabstop=4 shiftwidth=4 expandtab')

vim.cmd('au BufReadPost *.stpl set syntax=html')
