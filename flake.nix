{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.aider-chat
          pkgs.nodejs_22
          (pkgs.python3.withPackages (p: with p; [
            django
            djangorestframework
            djangorestframework-simplejwt
            django-cors-headers
            django-filter
            mysqlclient
            python-dotenv
            pytest
            pytest-django
          ]))
        ];
      };
    };
}
