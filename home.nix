
{
  config,
  pkgs,
  pkgs-unstable,
  l,
  ...
}: {  
  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "alejandra";
        }
      ];
    };
    settings = {
      theme = "nord";
      editor = {
        true-color = true;
        line-number = "relative";
        lsp.display-messages = true;
        lsp.display-inlay-hints = true;
      };
      keys = {
        insert = {
          C-i = ":toggle lsp.display-inlay-hints";
        };
        normal = {

          C-i = ":toggle lsp.display-inlay-hints";
          
          "+" = {
            l = ":run-shell-command ls";
          };
          
          n = "move_char_left";
          e = "move_visual_line_up";
          i = "move_visual_line_down";
          o = "move_char_right";

          h = "open_below";
          H = "open_above";

          N = "no_op";
          E = "no_op";
          I = "no_op";
          O = "no_op";

          l = "insert_mode";
          L = "insert_at_line_start";

          j = "join_selections";
          A-j = "join_selections_space";

          J = "keep_selections";

          k = "search_next";
          K = "search_prev";

          g = {
            h = "goto_last_line";
            j = "no_op";
            k = "goto_next_buffer";
            l = "goto_implementation";

            n = "goto_line_start";
            e = "move_line_up";
            i = "move_line_down";
            o = "goto_line_end";
          };
          C-w = {
            e = "jump_view_up";
            i = "jump_view_down";
            o = "jump_view_right";
            N = "swap_view_left";
            E = "swap_view_up";
            I = "swap_view_down";
            O = "swap_view_right";
          };
        };
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "nord";
    };
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    loginShellInit = ''
      if not set -q ZELLIJ
        zellij --layout compact
        kill $fish_pid
      end
    '';
    interactiveShellInit = ''
      # fish config
      fish_config theme choose Nord
      set fish_greeting # Disable greeting

      # zoxide config
      zoxide init fish | source

      # starship config
      function starship_transient_prompt_func
        starship module character
      end
      # function starship_transient_rprompt_func
      #   starship module time
      # end
      starship init fish | source

      # carpace completions
      set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
      mkdir -p ~/.config/fish/completions
      carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
      carapace _carapace | source
    '';
    shellAliases = {
      cat = "bat";
      erd = "erd -HiI -L3 -y inverted --dir-order last";
    };
  };

  programs.starship = {
    enable = true;
    settings = let
      primary_a = "#2E3440";
      primary_b = "#3B4252";
      primary_c = "#434C5E";
      primary_d = "#4C566A";
  
      secondary_a = "#ECEFF4";
      secondary_b = "#E5E9F0";
      secondary_c = "#D8DEE9";

      accent_a = "#D08770";
      accent_b = "#BF616A";
      accent_c = "#EBCB8B";
      accent_d = "#A3BE8C";
      accent_e = "#B48EAD";

      accent_sec_a = "#5E81AC";
      accent_sec_b = "#88C0D0";
      accent_sec_c = "#81A1C1";
      accent_sec_d = "#8FBCBB";
    in {
      add_newline = true;
      character = { 
        success_symbol = "[-❯❯](bold green)";
        error_symbol = "[-❯❯](bold red)";
      };
      format = l.concatStrings [
        "[ $os](bg:${accent_sec_c})"
        "[](bg:${accent_sec_d} fg:${accent_sec_c})"
        "[ $username#$directory](bg:${accent_sec_d})[](fg:${accent_sec_d})"
        " $character"
      ];
      right_format = l.concatStrings [
        "\\($singularity$kubernetes$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$gleam$golang$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$conda$meson$spack$aws$gcloud$openstack$azure$nats$crystal\\]"
        " ❮ $package "
        "[](fg:${primary_b})"
        "[$git_branch$git_status](bg:${primary_b})"
        "[](bg:${primary_b} fg:${primary_d})"
        "[ ](bg:${primary_d})[$time](blink bg:${primary_d})"
        "[█▓▒░](fg:${primary_d})"
      ];

      os = {
        format = "$symbol";
        disabled = false;
      };
      
      username = {
        format = "[$user](bg:${accent_sec_d} fg:${secondary_a})";
        show_always = true;
      };

      directory = {
        format = "[$path](bg:${accent_sec_d} fg:${secondary_a})";
        truncation_length = 3;
        truncation_symbol = ".../";
      };

      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
      };

      git_branch = {
        style = "bg:${primary_b}";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:${primary_b}";
        format = "[($all_status$ahead_behind )]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        format = "$time";       
      };

      aws.format = "[$symbol($profile)(($region))([$duration])]($style)";
      bun.format = "[$symbol($version)]($style)";
      c.format = "[$symbol($version(-$name))]($style)";
      cmake.format = "[$symbol($version)]($style)";
      cmd_duration.format = "[ $duration]($style)";
      cobol.format = "[$symbol($version)]($style)";
      conda.format = "[$symbol$environment]($style)";
      crystal.format = "[$symbol($version)]($style)";
      daml.format = "[$symbol($version)]($style)";
      dart.format = "[$symbol($version)]($style)";
      deno.format = "[$symbol($version)]($style)";
      docker_context.format = "[$symbol$context]($style)";
      dotnet.format = "[$symbol($version)( $tfm)]($style)";
      elixir.format = "[$symbol($version (TP $otp_version))]($style)";
      elm.format = "[$symbol($version)]($style)";
      erlang.format = "[$symbol($version)]($style)";
      fennel.format = "[$symbol($version)]($style)";
      fossil_branch.format = "[$symbol$branch]($style)";
      gcloud.format = "[$symbol$account(@$domain)(($region))]($style)";
      golang.format = "[$symbol($version)]($style)";
      gradle.format = "[$symbol($version)]($style)";
      guix_shell.format = "[$symbol]($style)";
      haskell.format = "[$symbol($version)]($style)";
      haxe.format = "[$symbol($version)]($style)";
      helm.format = "[$symbol($version)]($style)";
      hg_branch.format = "[$symbol$branch]($style)";
      java.format = "[$symbol($version)]($style)";
      julia.format = "[$symbol($version)]($style)";
      kotlin.format = "[$symbol($version)]($style)";
      kubernetes.format = "[$symbol$context( ($namespace))]($style)";
      lua.format = "[$symbol($version)]($style)";
      memory_usage.format = "smbol[$ram( | $swap)]($style)";
      meson.format = "[$symbol$project]($style)";
      nim.format = "[$symbol($version)]($style)";
      nix_shell.format = "[$symbol$state( ($name))]($style)";
      nodejs.format = "[$symbol($version)]($style)";
      ocaml.format = "[$symbol($version)(($switch_indicator$switch_name))]($style)";
      opa.format = "[$symbol($version)]($style)";
      openstack.format = "[$symbol$cloud(($project))]($style)";
      perl.format = "[$symbol($version)]($style)";
      php.format = "[$symbol($version)]($style)";
      pijul_channel.format = "[$symbol$channel]($style)";
      pulumi.format = "[$symbol$stack]($style)";
      purescript.format = "[$symbol($version)]($style)";
      python.format = "[\${symbol}\${pyenv_prefix}(\${version})(($virtualenv))]($style)";
      raku.format = "[$symbol($version-$vm_version)]($style)";
      red.format = "[$symbol($version)]($style)";
      ruby.format = "[$symbol($version)]($style)";
      rust.format = "[$symbol($version)]($style)";
      scala.format = "[$symbol($version)]($style)";
      spack.format = "[$symbol$environment]($style)";
      sudo.format = "[as $symbol]($style)";
      swift.format = "[$symbol($version)]($style)";
      terraform.format = "[$symbol$workspace]($style)";
      vagrant.format = "[$symbol($version)]($style)";
      vlang.format = "[$symbol($version)]($style)";
      zig.format = "[$symbol($version)]($style)";
      solidity.format = "[$symbol($version)]($style)";
      package.format = "[$symbol$version]($style)";
      aws.symbol = "  ";
      buf.symbol = " ";
      c.symbol = " ";
      conda.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " 󰌾";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      fennel.symbol = " ";
      fossil_branch.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      guix_shell.symbol = " ";
      haskell.symbol = " ";
      haxe.symbol = " ";
      hg_branch.symbol = " ";
      hostname.ssh_symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      kotlin.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      nim.symbol = "󰆥 ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      ocaml.symbol = " ";
      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        RockyLinux = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
      };
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      python.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";
    };
    enableFishIntegration = true;
    enableTransience = true;
  };

  programs = {
    zoxide.enableFishIntegration = true;
    yazi.enableFishIntegration = true;
    broot.enableFishIntegration = true;
    carapace.enableFishIntegration = true;
    direnv.enableFishIntegration = true;
    keychain.enableFishIntegration = true;
  };

  home = {
    file = {};
    username = "thesylex";
    homeDirectory = "/home/thesylex";
    stateVersion = "24.05";
  };
  
  programs.home-manager.enable = true;
}
