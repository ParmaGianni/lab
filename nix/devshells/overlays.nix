let
  mkEnv = name: value: {inherit name value;};
  mkTls = name: extension: cluster: {
    inherit name;
    value = "${baseSecretsPath}/${cluster}/tls.${extension}";
  };
  mkAge = cluster: {
    name = "SOPS_AGE_KEY_FILE";
    value = "${baseSecretsPath}/${cluster}/age.agekey";
  };
  baseSecretsPath = "/run/secrets";
in {
  flake.aspects.devshells.dev = let
    clusterContext = "dev";
    baseIP = "10.0.0";
    nodeIP = ["179" "153" "193"];
    nodes =
      builtins.concatStringsSep " "
      (builtins.map (ip: "${baseIP}.${ip}") nodeIP);
  in {
    env = [
      (mkAge "${clusterContext}")
      (mkEnv "CLUSTER_BRANCH" "${clusterContext}")
      (mkEnv "TALOS_CLUSTER" "dev-gary")
      (mkEnv "TALOS_IPS" "${nodes}")
      (mkEnv "TALOS_NODE" "dev")
      (mkTls "TLS_CRT_FILE" "crt" "${clusterContext}")
      (mkTls "TLS_KEY_FILE" "key" "${clusterContext}")
      (mkEnv "CONTEXT_KCONFIG" "dev-gary")
      (mkEnv "CONTEXT_TALOS" "dev-gary")
    ];
  };
  flake.aspects.devshells.prod = let
    clusterContext = "prod";
    baseIP = "192.168.1";
    nodeIP = ["200" "210" "202"];
    nodes =
      builtins.concatStringsSep " "
      (builtins.map (ip: "${baseIP}.${ip}") nodeIP);
  in {
    env = [
      (mkAge "${clusterContext}")
      (mkEnv "CLUSTER_BRANCH" "${clusterContext}")
      (mkEnv "TALOS_CLUSTER" "sleepy-gary")
      (mkEnv "TALOS_IPS" "${nodes}")
      (mkEnv "TALOS_NODE" "sleepy-gary")
      (mkTls "TLS_CRT_FILE" "crt" "${clusterContext}")
      (mkTls "TLS_KEY_FILE" "key" "${clusterContext}")
      (mkEnv "CONTEXT_KCONFIG" "sleepy-gary")
      (mkEnv "CONTEXT_TALOS" "sleepy-gary")
    ];
  };
}
