{ lib, buildPythonPackage, fetchPypi, zeroconf, pythonPackages}:

buildPythonPackage rec {
  pname = "aiohttp";
  version = "1.2.0";

  src = fetchPypi {
    inherit version pname;
    sha256 = "1kplymn6255v0v1swy2h42m6z3vwyxsafvr6d6yazs8kd41wh9r2";
  };

  propagatedBuildInputs = [
  ];
}
