{
  lib,
  mkRocqDerivation,
  which,
  stdlib,
  rocq-core,
  version ? null,
}:

with lib;
mkRocqDerivation {
  pname = "parseque";
  repo = "parseque";
  owner = "rocq-community";

  inherit version;
  defaultVersion =
    with versions;
    switch
      [ rocq-core.rocq-version ]
      [
        {
          cases = [ (range "8.16" "8.20") ];
          out = "0.2.2";
        }
        {
          cases = [ (range "9.0" "9.0") ];
          out = "0.2.3";
        }
      ]
      null;

  release."0.2.2".sha256 = "sha256-O50Rs7Yf1H4wgwb7ltRxW+7IF0b04zpfs+mR83rxT+E=";

  propagatedBuildInputs = [ stdlib ];

  releaseRev = v: "v${v}";

  meta = {
    description = "Total parser combinators in Rocq";
    maintainers = with maintainers; [ womeier ];
    license = licenses.mit;
  };
}
