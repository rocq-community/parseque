{
  ## DO NOT CHANGE THIS
  format = "1.0.0";
  ## unless you made an automated or manual update
  ## to another supported format.

  attribute = "parseque";

  default-bundle = "9.3";
  bundles."9.0" = {
    rocqPackages.CertiRocq.job = false;
    rocqPackages.rocq-core.override.version = "9.0";
    rocqPackages.coq.override.version = "9.0";
  };
  bundles."9.1" = {
    rocqPackages.CertiRocq.job = false;
    rocqPackages.rocq-core.override.version = "9.1";
    rocqPackages.coq.override.version = "9.1";
    rocqPackages.mathcomp-boot.override.version = "2.5.0";
  };
  bundles."9.2" = {
    rocqPackages.CertiRocq.job = false;
    rocqPackages.rocq-core.override.version = "9.2";
  };
  bundles."9.3" = {
    rocqPackages.CertiRocq.job = false;
    rocqPackages.rocq-core.override.version = "9.3";
    rocqPackages.coq.override.version = "9.3";
  };
  bundles."rocq-master" = {
    rocqPackages.CertiRocq.job = false;
    rocqPackages.rocq-core.override.version = "master";
    rocqPackages.coq.override.version = "master";
    rocqPackages.stdlib.override.version = "master";
    # Follow the dependency branches used by Rocq's master CI.
    rocqPackages.mathcomp-boot.override.version = "master";
    rocqPackages.hierarchy-builder.override.version = "master";
    rocqPackages.rocq-elpi.override.version = "master";
    rocqPackages.flocq.override.version = "master";
    rocqPackages.wasmcert.override.version = "rocq-master";
  };

  ## Cachix caches to use in CI
  cachix.coq = {};
  cachix.coq-community = {};
  
  cachix.coq-community.authToken = "CACHIX_AUTH_TOKEN";
}
