-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
local pid = vim.fn.getpid()

-- Configuration for jdtls using vim.lsp.start
local function setup_jdtls()
  local root_dir = vim.fs.dirname(vim.fs.find({ 'pom.xml', 'build.gradle', '.git' }, { upward = true })[1]) or vim.fn.getcwd()
  local workspace_dir = vim.fn.expand '~/.cache/jdtls/workspace' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  vim.lsp.start {
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
            {
              -- name = 'JavaSE-17',
              -- path = '/usr/lib/jvm/java-17-openjdk',
            },
          },
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Custom keymaps for LSP
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    end,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }
end

-- Call the setup function for Java files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = setup_jdtls,
})

return {
  vim.keymap.set('n', '/', 'f', { noremap = true }),
  vim.keymap.set('n', 'f', '/', { noremap = true }),
  vim.keymap.set('n', '?', 'F', { noremap = true }),
}
