function __android_switch() {
  local LAST_DIR=`pwd`

  cd $1
  source build/envsetup.sh

  # Only switch back if it's a child of the current directory
  if [[ "$LAST_DIR" == "$1"/* ]]; then
    cd "$LAST_DIR"
  fi

  # Switch to the correct java version using the passed in function.
  $2; rehash
}

function aosp() {
  __android_switch /android/aosp use_java8
}

function internal() {
  __android_switch /android/internal use_java8
}

function nyc() {
  __android_switch /android/nyc-dev use_java8
}

function mnc() {
  __android_switch /android/mnc-dev use_java7
}

function lmp() {
  __android_switch /android/lmp-dev use_java7
}

function klp() {
  __android_switch /android/klp-dev use_java6
}

function __generic_device() {
  local REPO=$1
  local PRODUCT=$2
  local TYPE=$3
  local SERIAL=$4

  $REPO

  lunch "${PRODUCT}-${TYPE}"
  export ANDROID_SERIAL=$SERIAL
}

function {
  typeset -A devices
  typeset -A aosp
  local current="nyc"
  devices[shamu]="ZX1G22LGPK"

  devices[flounder]="HT46CJT00073"
  aosp[flounder]=true

  devices[volantis]="HT46CJT00073"
  aosp[volantis]=false

  devices[seed]="1764c48e"
  aosp[seed]=false

  devices[sprout]="6I4804CGACA406A"
  aosp[sprout]=false

  devices[ryu]="5810000432"
  aosp[ryu]=false

  devices[dragon]="5810000432"
  aosp[dragon]=true

  devices[angler]="84B5T15915000293"
  devices[bullhead]="00ade0ddf4892033"
  devices[flo]="06d25a85"
  devices[hammerhead]="03baf040437e94f1"

  devices[aosp_x86]=""
  devices[aosp_x86_64]=""
  devices[aosp_arm]=""
  devices[aosp_arm64]=""

  function gen_alias() {
    local PRODUCT=$1
    local REPO=$2
    local AOSP=$3
    local SERIAL=$4
    local PRODUCT_PREFIX="aosp_"

    if [[ $AOSP == false ]]; then
      PRODUCT_PREFIX=""
    fi

    if [[ $PRODUCT == aosp_* ]]; then
      # Special case for emulators, so we don't have aosp_aosp_foo.
      PRODUCT_PREFIX=""
    fi

    alias "${PRODUCT}-${REPO}-user"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} user ${SERIAL}"
    alias "${PRODUCT}-${REPO}-userdebug"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} userdebug ${SERIAL}"
    alias "${PRODUCT}-${REPO}-eng"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} eng ${SERIAL}"
    alias "${PRODUCT}-${REPO}"="${PRODUCT}-${REPO}-eng"
  }

  function gen_aliases() {
    local PRODUCT=$1
    local AOSP=$2
    local SERIAL=$3

    gen_alias $PRODUCT nyc-mr1 $AOSP $SERIAL
    gen_alias $PRODUCT nyc $AOSP $SERIAL
    gen_alias $PRODUCT mnc $AOSP $SERIAL
    gen_alias $PRODUCT lmp $AOSP $SERIAL
    gen_alias $PRODUCT klp $AOSP $SERIAL
  }

  local PRODUCT
  for PRODUCT in "${(@k)devices}"; do
    local SERIAL=$devices[$PRODUCT]
    local AOSP=$aosp[$PRODUCT]

    if [[ "$AOSP" == true ]]; then
      gen_alias $PRODUCT aosp $AOSP $SERIAL
      gen_aliases $PRODUCT $AOSP $SERIAL
      alias "${PRODUCT}"="${PRODUCT}-${current}"
      alias "${PRODUCT}-user"="${PRODUCT}-${current}-user"
      alias "${PRODUCT}-userdebug"="${PRODUCT}-${current}-userdebug"
      alias "${PRODUCT}-eng"="${PRODUCT}-${current}-eng"
    elif [[ "$AOSP" == false ]]; then
      gen_alias $PRODUCT internal $AOSP $SERIAL
      gen_aliases $PRODUCT $AOSP $SERIAL
      alias "${PRODUCT}"="${PRODUCT}-${current}"
      alias "${PRODUCT}-user"="${PRODUCT}-${current}-user"
      alias "${PRODUCT}-userdebug"="${PRODUCT}-${current}-userdebug"
      alias "${PRODUCT}-eng"="${PRODUCT}-${current}-eng"
    else
      # $aosp[$PRODUCT] unset, generate everything.
      gen_alias $PRODUCT aosp true $SERIAL
      gen_alias $PRODUCT internal false $SERIAL
      gen_aliases $PRODUCT false $SERIAL
      alias "${PRODUCT}"="${PRODUCT}-${current}"
      alias "${PRODUCT}-user"="${PRODUCT}-${current}-user"
      alias "${PRODUCT}-userdebug"="${PRODUCT}-${current}-userdebug"
      alias "${PRODUCT}-eng"="${PRODUCT}-${current}-eng"
    fi
  done
}

function setup_jdk() {
  # Remove the current JDK from PATH
  if [ -n "$JAVA_HOME" ] ; then
    PATH=${PATH/$JAVA_HOME\/bin:/}
  fi
  export JAVA_HOME=$1
  export PATH=$JAVA_HOME/bin:$PATH
}

function use_java6() {
  setup_jdk /usr/lib/jvm/jdk1.6.0_45
}

function use_java7() {
  setup_jdk /usr/lib/jvm/java-7-openjdk-amd64
}

function use_java8() {
  setup_jdk /usr/lib/jvm/java-8-openjdk-amd64
}


function _backport() {
  local dry=$1
  local local_path=$2
  if [[ -z "$local_path" ]]; then
    local_path="."
  fi
  for sha in `git cherry HEAD goog/mirror-aosp-master | grep '^+' | cut -d' ' -f2`; do
    if [[ -e $local_path ]]; then
      local color_reset="\x1b[0m"
      local color_bold="\x1b[1m"
      local color_red="\x1b[31;1m"
      local color_green="\x1b[32;1m"
      local check=`git show $sha $local_path | wc -l`
      local commit_description="`git --no-pager log --oneline -n1 $sha`"

      if [[ $check == "0" ]]; then
        echo "${color_red}[SKIP]${color_reset} $commit_description"
        continue
      else
        echo "${color_green}[PICK]${color_reset}${color_bold} $commit_description${color_reset}"
        if [[ $dry != true ]]; then
          git cherry-pick -x $sha || return
        fi
      fi
    fi
  done
}

function backport() {
  _backport false $1
}

function backport_dry() {
  _backport true $1
}

[ -d /usr/lib/jvm/java-8-openjdk-amd64 ] && use_java8
if [ -d $HOME/.android/sdk ]; then
  export ANDROID_HOME="$HOME/.android/sdk"
  PATH="$PATH:$ANDROID_HOME/tools"
fi

alias n='m USE_GOMA=true -j1024'
alias nn='mm USE_GOMA=true -j1024'
alias nna='mma USE_GOMA=true -j1024'
