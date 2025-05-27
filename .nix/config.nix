{
  ## DO NOT CHANGE THIS
  format = "1.0.0";
  ## unless you made an automated or manual update
  ## to another supported format.

  attribute = "parseque";

  default-bundle = "8.20";
  bundles."8.20" = {
    coqPackages.coq.override.version = "8.20";
  };

  ## Cachix caches to use in CI
  cachix.coq = {};
  cachix.coq-community = {};
  
  cachix.coq-community.authToken = "CACHIX_AUTH_TOKEN";
}
