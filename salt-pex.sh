#/bin/sh

# Latest salt release
SALT_REL='2016.11.5'
ITER=00
BUILDDIR='BUILD'
BIN='/usr/local/bin'

clean(){
  if [ -d ${BUILDDIR} ];then
    echo "Cleaning ${BUILDDIR}..."
    rm -rf ${BUILDDIR}
  else
    echo "${BUILDDIR} does not exist"
  fi
}

build(){
  if [ -f ${BUILDDIR}/SRC${BIN}/salt-call ]; then
    if [ "${SALT_REL}" == "$(${BUILDDIR}/SRC${BIN}/salt-call --version | awk '{ print $2 }')" ]; then
       echo "Already built the pex file"
       return
    fi
  fi

  pkg install -y python27 py27-virtualenv swig openssl-devel libzmq3
  if [ ! -d ${BUILDDIR} ];then
    mkdir -p ${BUILDDIR}/SRC
  fi
  if [ ! -d ${BUILDDIR}/VENV ];then
    echo "Create virtualenv for pex"
    virtualenv ${BUILDDIR}/VENV
  fi
  ${BUILDDIR}/VENV/bin/pip install pex
  ${BUILDDIR}/VENV/bin/pex salt==${SALT_REL} -e salt.scripts:salt_call -o ${BUILDDIR}/SRC${BIN}/salt-call
}

pkging(){
  build
  echo "${BIN}/salt-call" > ${BUILDDIR}/plist

  cat << EOF > ${BUILDDIR}/+MANIFEST
name: salt-call-pex
origin: sysutils/salt
version: ${SALT_REL}-${ITER}
comment: Saltstack wrapped in Python Executable environment
maintainer: rob@sarcasticadmin.com
www: https://github.com/saltstack/salt
abi: FreeBSD:11:amd64
arch: freebsd:11:x86:64
desc: Saltstack Python Executable
prefix: /usr/local
deps:
  {python27: {origin: lang/python27, version: 2.7.13_6}}
EOF

  pkg create -v -m $(pwd)/${BUILDDIR}/ -r $(pwd)/${BUILDDIR}/SRC -p $(pwd)/${BUILDDIR}/plist -o ${BUILDDIR}
}

usage(){
  cat << EOF
usage: $(basename $0) [OPTIONS] ARGS

This script builds salt-call-pex and can create a pkg for
pkgng.

OPTIONS:

  -h      Show this message
  -r      Specify a release of salt

EXAMPLES:

  To build salt-call-pex into a pkg
    # $(basename $0) pkg
  To build salt-call-pex with a specific version
    # $(basename $0) -r 2016.11.3 pkg
EOF
}

while getopts "hr:" OPTION
do
  case $OPTION in
    h )
      usage
      exit 0
      ;;
    r )
      SALT_REL=$OPTARG
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ "${1}" == "pkg" ];then
  pkging
elif [ "${1}" == "clean" ]; then
  clean
elif [ "${1}" == "build" ]; then
  build
else
  echo "Cannot handle arg: ${1}"
  exit 1
fi
