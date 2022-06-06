{ lib, buildPythonPackage, fetchPypi, zeroconf, pythonPackages, aiohttp}:

buildPythonPackage rec {
  pname = "pyatv";
  version = "0.1.0";

  src = fetchPypi {
    inherit version pname;
    sha256 = "1wjlymn6255v0v1swy2h42m6z3vwyxsafvr6d6yazs8kd41wh9r2";
  };

  propagatedBuildInputs = [
    aiohttp
  ];
}
