{ pkgs, lib, config, mkYarnPackage, yarn }:
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
      mkdir -p $out/bin
      cp -r ./dist/* $out/bin
      cp -r $node_modules $out
      cp -r client $out
      cp .parcelrc $out
    '';
    distPhase = "true";
}
