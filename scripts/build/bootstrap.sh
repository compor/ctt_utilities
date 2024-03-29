#!/usr/bin/env bash

usage() { echo "Usage: $0 [-p]" 1>&2; exit 1; }

while getopts ":p" opt; do
  case "${o}" in
    p)
      UPDATE_REPO_OPT=1
      ;;
    \? )
      usage
      ;;
  esac
done
shift $((OPTIND-1))

found=$( hash clang 2>&1 || hash clang++ 2>&1 > /dev/null )
[[ $found ]] && echo "clang/clang++ not found" && exit 1

[[ -z ${BOOST_ROOT} ]] && echo "BOOST_ROOT is not set" && exit 1
#[[ -z ${GTEST_ROOT} ]] && echo "GTEST_ROOT is not set" && exit 1

# preparatory

REPO_ROOT="${PWD}/repos/"
BUILD_ROOT="${PWD}/builds/"
INSTALL_ROOT="${PWD}/installs/"

mkdir -p ${REPO_ROOT}
mkdir -p ${BUILD_ROOT}
mkdir -p ${INSTALL_ROOT}

#

# set up these vars for inter-project dependencies

export PEDIGREE_DIR="${INSTALL_ROOT}/Pedigree/lib/cmake/"
export ITERATORRECOGNITION_DIR="${INSTALL_ROOT}/IteratorRecognition/lib/cmake/"

#

REPOS=( "Pedigree" "IteratorRecognition" "Atrox" "Ephippion" )

for i in "${REPOS[@]}"; do
  REPO_NAME="${i}"

  echo "Setting up: ${REPO_NAME}"

  REPO_URL="https://github.com/compor/${REPO_NAME}.git"

  pushd ${REPO_ROOT}

  if [[ ! -e ${REPO_NAME} ]]; then
    git clone --recursive ${REPO_URL}
  elif [[ ${UPDATE_REPO_OPT} -ne 0 ]]; then
    pushd ${REPO_NAME}
    git pull
    popd
  fi

  popd

  #

  REPO_DIR=${REPO_ROOT}/${REPO_NAME}
  BUILD_DIR=${BUILD_ROOT}/${REPO_NAME}
  INSTALL_DIR=${INSTALL_ROOT}/${REPO_NAME}

  mkdir -p ${BUILD_DIR}
  mkdir -p ${INSTALL_DIR}

  pushd ${BUILD_DIR}

  source ${REPO_DIR}/utils/scripts/build/exports_deps1.sh
  ${REPO_DIR}/utils/scripts/build/build.sh ${REPO_DIR} ${INSTALL_DIR}

  [[ $? -ne 0 ]] && echo "error configuring ${REPO_NAME}" && exit 1

  cmake --build .

  [[ $? -ne 0 ]] && echo "error building ${REPO_NAME}" && exit 1

  cmake -P cmake_install.cmake

  popd
done

#

exit 0

