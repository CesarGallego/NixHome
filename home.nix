{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "cesar";
  home.homeDirectory = "/home/cesar";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home.packages = [
    # sys
    pkgs.htop
    pkgs.feh
    pkgs.calcurse
    (pkgs.aspellWithDicts (dicts: with dicts; [ en es ]))
    pkgs.neomutt
    # dev
    pkgs.xclip
    pkgs.ripgrep
    pkgs.fd
    pkgs.gimp
    # langs
    pkgs.nodePackages_latest.pyright
    # ham radio
    pkgs.tqsl
    pkgs.klog
  ];

  # ¿Es ético operar nustro propio cerebro?
  programs.home-manager = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-airline;
        config = ''
          " Airline
          let g:airline#extensions#tabline#enabled = 1
          let g:airline_powerline_fonts = 1
        '';
      }
      {
        plugin = vim-airline-themes;
        config = "let g:airline_theme='minimalist'";
      }
      nord-nvim
      vim-nix
      nvim-metals
      (nvim-treesitter.withPlugins (p: pkgs.tree-sitter.allGrammars))
      # nvim-treesitter
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
          end
          local lsp_flags = {
            debounce_text_changes = 150,
          }
          require('lspconfig')['pyright'].setup{
            on_attach = on_attach,
            flags = lsp_flags,
          }
          require('lspconfig')['metals'].setup{
            on_attach = on_attach,
            flags = lsp_flags,
          }
          require('lspconfig')['gopls'].setup{
            on_attach = on_attach,
            flags = lsp_flags,
          }
          EOF
          set completeopt-=preview
        '';
      }
      popup-nvim
      plenary-nvim
      {
        plugin = telescope-nvim;
        config = ''
          " telescope
          let mapleader=";"
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        '';
      }
      {
        plugin = trouble-nvim;
        config = ''
          " trouble
          nnoremap <leader>xx <cmd>TroubleToggle<cr>
          nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
          nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
          nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
          nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
          nnoremap gR <cmd>TroubleToggle lsp_references<cr>
        '';
      }
      gitsigns-nvim
      markdown-preview-nvim
      nvim-web-devicons
      {
        plugin = lazygit-nvim;
        config = ''
          " setup mapping to call :LazyGit
          nnoremap <silent> <leader>gg :LazyGit<CR>
        '';
      }
      copilot-vim
      {
        plugin = vim-easymotion;
        config = ''
          nnoremap \ <Plug>(easymotion-overwin-f)
        '';
      }
    ];
    extraConfig = ''
      set clipboard=unnamedplus
      set number
      set relativenumber
      set textwidth=0 wrapmargin=0

      autocmd!
      syntax enable
      colorscheme nord

      set encoding=utf-8 
      set title
      set autoindent
      set expandtab

      set lazyredraw
      set smarttab

      filetype plugin indent on
      set shiftwidth=2
      set tabstop=2
      set ai
      set si

      set spelllang=es

      lua << EOF
        if vim.g.neovide then
          vim.opt.guifont = { "Fira Code Nerd Font", "h11" }
          vim.g.neovide_scale_factor = 1.0
          local change_scale_factor = function(delta)
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
          end
          vim.keymap.set("n", "<C-=>", function()
            change_scale_factor(1.25)
          end)
          vim.keymap.set("n", "<C-->", function()
            change_scale_factor(1/1.25)
          end)
        end
      EOF
    '';
  };

  programs.gpg = {
    enable = true;
  };

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "/home/cesar/.password-store"; };
    package = pkgs.pass.withExtensions (ext: [ ext.pass-otp ext.pass-import ]);
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "onedark";
      editor = {
        line-number = "relative";
        mouse = false;
        auto-completion = false;
        auto-pairs = false;
        
        lsp = {
          auto-signature-help = false;
        };
        
        indent-guides = {
          render = true;
        };
      };
      
      keys.insert = {
        C-o = "signature_help";
      };
    };
    
    languages = [
      {
        name = "toml";
        scope = "source.toml";
        injection-regex = "toml";
        file-types = ["toml"];
        roots = [];
        comment-token = "#";
        language-server = { command = "taplo"; args = ["lsp" "stdio"]; };
        indent = { tab-width = 2; unit = "  "; };
      }
      {
        name = "python";
        scope = "source.python";
        injection-regex = "python";
        file-types = ["py"];
        shebangs = ["python" "python3"];
        roots = [];
        comment-token = "#";
        language-server = { command = "pylsp";};
        # TODO: pyls needs utf-8 offsets
        indent = { tab-width = 4; unit = "    ";};
      }
    ];
  };
  
}
