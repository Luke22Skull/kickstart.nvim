-- Configurazioni base e plugins custom

local pid = vim.fn.getpid()

-- Nuovo metodo: configs viene da vim.lsp.configs (NON lspconfig)
local configs = vim.lsp.config
local lsp = require 'vim.lsp'

-- Configurazione Java LSP jdtls
local function setup_jdtls()
  local root_dir = vim.fs.dirname(vim.fs.find({ 'pom.xml', 'build.gradle', '.git' }, { upward = true })[1]) or vim.fn.getcwd()
  local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace' .. vim.fn.fnamemodify(root_dir, ':p:h:t'))

  lsp.start {
    name = 'jdtls',
    cmd = { 'jdtls', '-data', workspace_dir },
    root_dir = root_dir,
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = 'JavaSE-25',
              path = '/usr/lib/jvm/java-25-openjdk',
            },
          },
        },
      },
    },
  }
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = setup_jdtls,
})

-- Keymap custom per LSP (attacca su ogni buffer con LSP)
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, opts)
end

-- Altre keymap globali di esempio
return {
  vim.keymap.set('n', '/', 'f', { noremap = true }),
  vim.keymap.set('n', 'f', '/', { noremap = true }),
  vim.keymap.set('n', '?', 'F', { noremap = true }),

  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      '<leader>f',
      function()
        require('conform').format { async = true }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      sql = { 'sql-formatter' },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = 'fallback',
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 500 },
    -- Customize formatters
    formatters = {
      shfmt = {
        append_args = { '-i', '2' },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
