#!/usr/bin/env sh

# based on hypnoglow/helm-s3
set -euo pipefail

version="$(cat plugin.yaml | grep "version" | cut -d '"' -f 2)"
echo "Downloading and installing kubectl v${version} ..."

url=""

# convert architecture of the target system to a compatible GOARCH value.
# Otherwise failes to download of the plugin from github, because the provided
# architecture by `uname -m` is not part of the github release.
arch=""
case $(uname -m) in
  x86_64)
    arch="amd64"
    ;;
  armv6*)
    arch="armv6"
    ;;
  # match every arm processor version like armv7h, armv7l and so on.
  armv7*)
    arch="armv7"
    ;;
  aarch64 | arm64)
    arch="arm64"
    ;;
  *)
    echo "Failed to detect target architecture"
    exit 1
    ;;
esac


if [ "$(uname)" = "Darwin" ]; then
    url="https://dl.k8s.io/release/v${version}/bin/darwin/${arch}/kubectl"
elif [ "$(uname)" = "Linux" ] ; then
    url="https://dl.k8s.io/release/v${version}/bin/linux/${arch}/kubectl"
else
  echo "OS not supported"
  exit 1
fi

echo $url

mkdir -p "bin"
rm -f bin/kubectl
# Download with curl if possible.
if [ -x "$(which curl 2>/dev/null)" ]; then
    curl -sSL "${url}" -o "bin/kubectl"
else
    wget -q "${url}" -O "bin/kubectl"
fi
chmod 555 "bin/kubectl"
