#!/usr/bin/env sh

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

if [ -z "${OVERLAY}" ]; then
  OVERLAY="cntk"
fi

if ! command -v yq 1> /dev/null 2> /dev/null; then
  echo "yq cli is required" >&2
  exit 1
fi

echo "Generating mkdocs.yml using ${OVERLAY} overlay"

export BASE_PATH="${SCRIPT_DIR}/_mkdocs.base.yml"

yq '. *= load(env(BASE_PATH))' "${SCRIPT_DIR}/_mkdocs.overlay.${OVERLAY}.yml" > "${SCRIPT_DIR}/mkdocs.yml"
