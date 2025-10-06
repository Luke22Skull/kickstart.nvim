return {
  -- Neo-tree: A modern file explorer for Neovim
  -- See: https://github.com/nvim-neo-tree/neo-tree.nvim
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required for core functionality
    'nvim-tree/nvim-web-devicons', -- Optional, enhances file icons
    'MunifTanjim/nui.nvim', -- Required for UI components
  },
  lazy = false,
  keys = {
    {
      '\\',
      function()
        -- Check if a buffer is loaded (i.e., a file is open)
        local has_file = vim.fn.bufname() ~= ''
        if has_file then
          -- Open Neo-tree in a new tab and reveal the current file
          vim.cmd 'tabnew'
          -- require('neo-tree.command').execute { action = 'filesystem', reveal = true, position = 'left' }
          vim.cmd 'Neotree filesystem'
        else
          -- Open Neo-tree in the current window and reveal
          -- require('neo-tree.command').execute { action = 'filesystem', reveal = true, position = 'left' }
          vim.cmd 'Neotree filesystem'
        end
        -- Move cursor to Neo-tree window asynchronously
        vim.schedule(function()
          -- Wait briefly to ensure Neo-tree is rendered
          vim.cmd 'wincmd h' -- Move to left window where Neo-tree should be
        end)
      end,
      desc = 'NeoTree reveal (new tab if file open)',
      silent = true,
    },
    -- Mappatura per chiudere Neo-tree manualmente
    { '<leader>nc', '<cmd>Neotree close<CR>', desc = '[N]eo[T]ree [C]lose', silent = true },
    -- Mappatura per aprire Neo-tree filesystem
    { '<leader>no', '<cmd>Neotree filesystem<CR>', desc = '[N]eo[T]ree [O]pen (Neotree Filesystem)', silent = true },
  },
  opts = {
    sources = { 'filesystem' }, -- Focus on filesystem source
    default_component_configs = {
      indent = { padding = 0 }, -- Clean indentation
    },
    filesystem = {
      follow_current_file = true, -- Sync with the current file
      hijack_netrw_behavior = 'open_current', -- Replace netrw with Neo-tree
      use_libuv_file_watcher = true, -- Improve file watching performance
      close_on_file_open = true, -- Close Neo-tree when a file is opened
      window = {
        mappings = {
          ['<cr>'] = 'open', -- Open file and close Neo-tree
          ['\\'] = 'close_window', -- Close Neo-tree with backslash
          ['q'] = 'close_window', -- Alternative to close Neo-tree
          ['<esc>'] = 'close_node', -- Close current node with Esc
        },
      },
    },
    event_handlers = {
      {
        event = 'file_opened',
        handler = function()
          -- Ensure Neo-tree closes after file open
          require('neo-tree.command').execute { action = 'close' }
        end,
      },
      {
        event = 'neo_tree_window_open',
        handler = function(args)
          -- Automatically set focus to Neo-tree window when opened
          if args.position == 'left' then
            vim.api.nvim_set_current_win(args.winid)
          end
        end,
      },
    },
  },
}
