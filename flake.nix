{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-flake = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld-rs-flake = {
      url = "github:nix-community/nix-ld-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix-flake = {
      url = "github:helix-editor/helix/24.07";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    asciinema-flake = {
      url = "github:asciinema/asciinema?rev=eda506c3001aa70bbcad608da2f2cbf55b6572a7";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    openapi-tui-flake = {
      url = "github:zaghaghi/openapi-tui/0.9.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { ... } @ inputs: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    l = inputs.nixpkgs.lib // pkgs.lib // builtins; # Not really sure why nixpkgs and pkgs aren't the same
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = l.nixosSystem rec {
      inherit system;

      specialArgs = { inherit pkgs pkgs-unstable l; };
      
      modules = [
        {
          wsl = {
            enable = true;
            defaultUser = "thesylex";
            interop.register = true;
          };

          nix.settings = {
            experimental-features = ["nix-command" "flakes"];
            trusted-users = ["root" "thesylex" "@wheel"];

            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
            ];

            trusted-public-keys = [
              # the default public key of cache.nixos.org, it's built-in, no need to add it here
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };

          users.mutableUsers = false;
          users.users.thesylex = {
            hashedPassword = "$y$j9T$hlHPS1Na.x9ezNd0TQDO/.$fv5URIMauotR5CObfjGMZhgyx1RPPI7oX.R5nVG5TZ0";
            createHome = true;
            home = "/home/thesylex";
            isNormalUser = true;
            extraGroups = ["wheel" "docker"];
            shell = pkgs.fish;
          };

          virtualisation.docker.enable = true;

          programs = {
            direnv.enable = true;
            nix-ld = {
              enable = true;
              package = inputs.nix-ld-rs-flake.packages."${system}".nix-ld-rs;
            };
            ssh.startAgent = true;
            fish.enable = true;
          };

          environment.systemPackages = with pkgs; [
            # # Nix
            alejandra
            nil

            # Shell
            fish
            starship
            zellij
            carapace
            zoxide

            # CLI
            wget
            git
            bat
            erdtree
            du-dust
            ripgrep
            fd
            onefetch

            # TUI
            yazi
            gitui
            tealdeer
            bottom

            # Desktop
            # jetbrains.datagrip
          ] ++ [
            inputs.helix-flake.packages."${system}".default
            inputs.asciinema-flake.packages."${system}".default

            (pkgs.rustPlatform.buildRustPackage {
              name = "rsftch";
              src = pkgs.fetchFromGitHub {
                owner = "charklie";
                repo = "rsftch";
                rev = "6694c28";
                hash = "sha256-9c//XLPZWyziSn6IIe86Tec+vtskgwwrs2UT7y2zMaI=";
              };
              cargoHash = "sha256-ULm20/bUULwTKMol6HSaLyiJw40CA3ArW41NxY2L8aE=";
              doCheck = false;
              postConfigure = "cargo metadata --offline";
            })
            (pkgs.rustPlatform.buildRustPackage {
              name = "slumber";
              src = pkgs.fetchFromGitHub {
                owner = "LucasPickering";
                repo = "slumber";
                rev = "v1.5.0";
                hash = "sha256-7JXkyRhoSjGYhse+2/v3Ndogar10K4N3ZUZNGpMiQ/A=";
              };
              cargoHash = "sha256-is27/IWT9Ska5dyURZlxjrStmI3uzGVHJM3b7BrH9/w=";
              doCheck = false;
            })
            # FIXME: Doesn't build due to OpenSSL errors :(
            # inputs.openapi-tui-flake.packages."${system}".default
            # We have to add these two ENV vars for the package to build
            (l.overrideDerivation
              inputs.openapi-tui-flake.packages."${system}".default (old: {
                OPENSSL_NO_VENDOR = 1;
                PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
              })
            )                       
          ];

          system.stateVersion = "23.11";
        }
        inputs.nixos-wsl.nixosModules.wsl
        inputs.home-manager-flake.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            backupFileExtension = "backup";

            users.thesylex = import ./home.nix;
          };
        }
      ];
    };
  };
}
