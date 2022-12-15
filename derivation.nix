{ pkgs, lib, config, mkYarnPackage, yarn }:
let
  frontend = mkYarnPackage {
    name = "tetra-kit-player-frontend";
    src = ./client;

    yarnLock = ./client/yarn.lock;

    buildInputs = [ yarn ];
    configurePhase = ''
      cp -r $node_modules node_modules
    '';
    buildPhase = ''
      yarn build
    '';
    installPhase = ''
      mkdir $out
      cp -r ./dist/* $out
    '';
    distPhase = "true";
  };
in
mkYarnPackage {
  name = "tetra-kit-player";
  src = ./.;

  yarnLock = ./yarn.lock;
  
  buildInputs = [ yarn ];
  configurePhase = ''
    cp -r $node_modules node_modules
    chmod 777 -R ./node_modules 
    chmod +w node_modules
  '';
  buildPhase = ''
    yarn build
  '';
  installPhase = ''
    mkdir -p $out/{bin,frontend}
    cp -r ./dist/* $out/bin
    cp -r $node_modules $out
    cp -r ${frontend}/* $out/frontend
  '';
  distPhase = "true";
}
