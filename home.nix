{ config, pkgs, homePkgs ? [ ], ... }:

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
  home.stateVersion = "22.05";

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
  ] ++ homePkgs; # fromFlakes

  # ¿Es ético operar nustro propio cerebro?
  programs.home-manager = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };
  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    clock24 = true;
    keyMode = "vi";
    baseIndex = 1;
    resizeAmount = 1;
    extraConfig = ''
      set-option -g bell-action none
      set-option -g visual-bell off
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on
      set -g @continuum-restore 'on'

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      sensible
      vim-tmux-navigator
      nord
      yank
      resurrect
      continuum
    ];
  };
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-which-key;
        config = ''
        '';
      }
      {
        plugin = nvim-whichkey-setup-lua;
        config = ''
          let mapleader=" "
          lua << EOF
            local wk = require('whichkey_setup')

            local keymap = {
                f = { -- set a nested structure
                    name = '+find',
                    a = {'<Cmd>Telescope grep_string<CR>', 'grep string'},
                    f = {'<Cmd>Telescope find_files<CR>', 'files'},
                    b = {'<Cmd>Telescope buffers<CR>', 'buffers'},
                    h = {'<Cmd>Telescope help_tags<CR>', 'help tags'},
                    c = {
                        name = '+commands',
                        c = {'<Cmd>Telescope commands<CR>', 'commands'},
                        h = {'<Cmd>Telescope command_history<CR>', 'history'},
                    },
                    q = {'<Cmd>Telescope quickfix<CR>', 'quickfix'},
                    g = {
                        name = '+git',
                        g = {'<Cmd>Telescope git_commits<CR>', 'commits'},
                        c = {'<Cmd>Telescope git_bcommits<CR>', 'bcommits'},
                        b = {'<Cmd>Telescope git_branches<CR>', 'branches'},
                        s = {'<Cmd>Telescope git_status<CR>', 'status'},
                    },
                },
                c = { -- LSP Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                  g = {
                    name = '+go to',
                    D = {'<Cmd>lua vim.lsp.buf.declaration()<CR>', 'declaration'},
                    d = {'<Cmd>lua vim.lsp.buf.definition()<CR>', 'definition'},
                    i = {'<Cmd>lua vim.lsp.buf.implementation()<CR>', 'implementation'},
                    r = {'<Cmd>lua vim.lsp.buf.references()<CR>', 'references'},
                  },
                  K = {'<Cmd>lua vim.lsp.buf.hover()<CR>', 'Hover'},
                  H = {'<Cmd>lua vim.lsp.buf.signature_help()<CR>', 'signature help'},
                  a = {'<Cmd>lua vim.lsp.buf.code_action()<CR>', 'code action'},
                  w = {
                    name = '+workspace',
                    a = {'<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', 'add folder'},
                    r = {'<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', 'remove folder'},
                    l = {'<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', 'list folders'},
                  },
                  d = {'<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'type definition'},
                  r = {'<Cmd>lua vim.lsp.buf.rename()<CR>', 'rename'},
                  e = {'<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', 'show line diagnostics'},
                  f = {'<Cmd>lua vim.lsp.buf.formatting()<CR>', 'format'},
                }
            }

            wk.register_keymap('leader', keymap)
          EOF
        '';
      }
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
          " let mapleader=" "
          " nnoremap <leader>ff <cmd>Telescope find_files<cr>
          " nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          " nnoremap <leader>fb <cmd>Telescope buffers<cr>
          " nnoremap <leader>fh <cmd>Telescope help_tags<cr>
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
          " Easymotion
          let g:EasyMotion_do_mapping = 0
          nnoremap <Leader>F <Plug>(easymotion-overwin-f2)
          xnoremap <Leader>F <Plug>(easymotion-s2)
        '';
      }
    ];
    extraConfig = ''
      let mapleader=" "
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
