{
  ## DO NOT CHANGE THIS
  format = "1.0.0";
  ## unless you made an automated or manual update
  ## to another supported format.

  attribute = "parseque";

  default-bundle = "9.0";
  bundles."9.0" = {
    rocqPackages.rocq-core.override.version = "9.0";
  };
  bundles."9.1" = {
    rocqPackages.rocq-core.override.version = "9.1";
  };

  ## Cachix caches to use in CI
  cachix.coq = {};
  cachix.coq-community = {};
  
  cachix.coq-community.authToken = "CACHIX_AUTH_TOKEN";
}
