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
    pkgs.fzf
    pkgs.feh
    pkgs.calcurse
    # dev
    pkgs.xclip
    pkgs.ripgrep
    pkgs.fd
    pkgs.gimp
    # ham radio
    pkgs.tqsl
    pkgs.klog
    #util
    pkgs.taskell
  ] ++ homePkgs; # fromFlakes

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-airline-themes
      vim-nix
      #(nvim-treesitter.withPlugins (p: pkgs.tree-sitter.allGrammars))
      nvim-treesitter
      popup-nvim
      plenary-nvim
      telescope-nvim
      gitsigns-nvim
      markdown-preview-nvim
    ];
    extraConfig = ''
      set clipboard=unnamedplus
      set number
      set relativenumber
      set textwidth=0 wrapmargin=0

      autocmd!
      syntax enable

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

      " Airline
      let g:airline#extensions#tabline#enabled = 1
      let g:airline_powerline_fonts = 1

      " telescope
      let mapleader=";"
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    '';
  };

  programs.gpg = {
    enable = true;
  };

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "/home/cesar/.password-store"; };
  };

  programs.neomutt = {
    enable = true;
    vimKeys = true;
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
