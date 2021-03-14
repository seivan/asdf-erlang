KERL_VERSION="${ASDF_KERL_VERSION:-2.1.0}"


echoerr() {
  >&2 echo -e "\033[0;31m$1\033[0m"
}

ensure_kerl_setup() {
  export KERL_BASE_DIR="$(kerl_dir)"
  export KERL_CONFIG="$(kerl_dir)/kerlrc"
  #export KERL_BUILD_BACKEND="git"
  ensure_kerl_installed
}

ensure_kerl_installed() {
  # If kerl exists
  if [ -x "$(kerl_path)" ]; then
    # But was passed an expected version
    if [ -n "${ASDF_KERL_VERSION:-}" ]; then
      current_kerl_version="$("$(kerl_path)" version)"
      # Check if expected version matches current version
      if [ "$current_kerl_version" != "$KERL_VERSION" ]; then
        # If not, reinstall with ASDF_KERL_VERSION
        download_kerl
      fi
    fi
  else
    # kerl does not exist, so install using default value in KERL_VERSION
    download_kerl
  fi
}



download_kerl() {
  # Remove directory in case it still exists from last download
  rm -rf "$(kerl_source_dir)"
  rm -rf "$(kerl_dir)"

  # Print to stderr so asdf doesn't assume this string is a list of versions
  echoerr "Downloading kerl $KERL_INSTALL_VERSION"

  # Clone down and checkout the correct kerl version
  git clone https://github.com/kerl/kerl.git "$(kerl_source_dir)" --quiet
  (cd "$(kerl_source_dir)"; git checkout $KERL_INSTALL_VERSION --quiet;)

  mkdir -p "$(kerl_dir)/bin"
  mv "$(kerl_source_dir)/kerl" "$(kerl_path)"
  chmod +x "$(kerl_path)"

  rm -rf "$(kerl_source_dir)"
}

asdf_erlang_plugin_path() {
  echo "$(dirname "$(dirname "$0")")"
}

kerl_dir() {
  echo "$(asdf_erlang_plugin_path)/kerl"
}

kerl_source_dir() {
  echo "$(asdf_erlang_plugin_path)/kerl-install-source"
}


kerl_path() {
  #Check if kerl exists without an expected version
  if [ -x "$(command -v kerl)" ] && [ -z "${ASDF_KERL_VERSION:-}" ]; then
    echo "$(command -v kerl)"
  else
    echo "$(kerl_dir)/bin/kerl"
  fi
}
