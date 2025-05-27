{
  lib,
  mkRocqDerivation,
  which,
  coq,
  version ? null,
}:

with lib;
mkRocqDerivation {
  pname = "parseque";
  repo = "parseque";
  owner = "rocq-communiy";
  domain = "github.com";

  inherit version;
  defaultVersion =
    with versions;
    switch
      [ coq.coq-version ]
      [
        {
          cases = [ (range "8.16" "8.20") ];
          out = "0.2.2";
        }
      ]
      null;

  release."0.2.2".sha256 = "";

  releaseRev = v: "v${v}";

  meta = {
    description = "Total parser combinators in Rocq";
    maintainers = with maintainers; [ _womeier ];
    license = licenses.mit;
  };
}
