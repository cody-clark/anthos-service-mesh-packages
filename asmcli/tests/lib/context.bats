# Setting up a test with a shared *.bash file
# Shared procedures/functions should go in that file
setup() {
  load '../unit_test_common.bash'
  _common_setup
  PROJECT_ID="this-is-a-test-project"
  CLUSTER_NAME="this-is-a-test-cluster"
  CLUSTER_LOCATION="us-east-2a"
  context_init
}

# Potential cleanup work should happen here
teardown() {
  rm "${context_FILE_LOCATION}"
  echo "Cleaned up"
}

@test "test context_FILE_LOCATION initialized with environment variables" {
  run context_get-option "PROJECT_ID"
  assert_output "${PROJECT_ID}"

  run context_get-option "CLUSTER_NAME"
  assert_output "${CLUSTER_NAME}"

  run context_get-option "CLUSTER_LOCATION"
  assert_output "${CLUSTER_LOCATION}"
}

@test "test context_FILE_LOCATION getter and setter on numeric values" {
  run context_get-option "ENABLE_ALL"
  assert_output 0

  run context_set-option "ENABLE_ALL" 1
  assert_success

  run context_get-option "ENABLE_ALL"
  assert_output 1
}

@test "test context_FILE_LOCATION getter and setter on string values" {
  run context_get-option "CA"
  assert_output ""

  run context_set-option "CA" "meshca"
  assert_success

  run context_get-option "CA"
  assert_output "meshca"
}

@test "test context_FILE_LOCATION append a istioctl file" {
  run context_list-istio-yamls
  assert_output ""

  run context_append-istio-yaml "istio-1.yaml"
  assert_success

  run context_list-istio-yamls
  assert_output "istio-1.yaml"
}

@test "test context_FILE_LOCATION append a kubectl file" {
  run context_list-kube-yamls
  assert_output ""

  run context_append-kube-yaml "kube-1.yaml"
  assert_success

  run context_list-kube-yamls
  assert_output "kube-1.yaml"
}

@test "test context_FILE_LOCATION append multiple istioctl files" {
  run context_list-istio-yamls
  assert_output ""

  run context_append-istio-yaml "istio-1.yaml"
  assert_success

  run context_list-istio-yamls
  assert_output "istio-1.yaml"

  run context_append-istio-yaml "istio-2.yaml"
  assert_success

  run context_list-istio-yamls
  assert_output --stdin <<EOF
istio-1.yaml
istio-2.yaml
EOF
}

@test "test context_FILE_LOCATION append kubectl files" {
  run context_list-kube-yamls
  assert_output ""

  run context_append-kube-yaml "kube-1.yaml"
  assert_success

  run context_list-kube-yamls
  assert_output "kube-1.yaml"

  run context_append-kube-yaml "kube-2.yaml"
  assert_success

  run context_list-kube-yamls
  assert_output --stdin <<EOF
kube-1.yaml
kube-2.yaml
EOF
}

@test "test missing values in non-interactive mode will fail fast" {
  context_set-option "NON_INTERACTIVE" 1
  run has_value "ENVIRON_PROJECT_ID"
  assert_failure
  context_set-option "NON_INTERACTIVE" 0
}

@test "test not-missing values in non-interactive mode will succeed" {
  context_set-option "NON_INTERACTIVE" 1
  run has_value "PROJECT_ID"
  assert_success
}

@test "test missing values in interactive will read from stdin" {
  local ENVIRON_PROJECT_ID; ENVIRON_PROJECT_ID="111111"
  has_value "ENVIRON_PROJECT_ID" << EOF
${ENVIRON_PROJECT_ID}
EOF
  assert_equal $(context_get-option "ENVIRON_PROJECT_ID") "${ENVIRON_PROJECT_ID}"
  context_set-option "ENVIRON_PROJECT_ID" ""
}
