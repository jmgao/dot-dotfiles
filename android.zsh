function __android_switch() {
  local LAST_DIR=`pwd`

  cd $1
  source build/envsetup.sh

  # Only switch back if it's a child of the current directory
  if [[ "$LAST_DIR" == "$1"/* ]]; then
    cd "$LAST_DIR"
  fi
}

function aosp() {
  __android_switch /android/aosp
}

function internal() {
  __android_switch /android/nyc-dev
}

function __generic_device() {
  local REPO=$1
  local PRODUCT=$2
  local TYPE=$3
  local SERIAL=$4
  if [[ "$REPO" == "aosp" ]]; then
    aosp
    lunch "aosp_${PRODUCT}-${TYPE}"
  else
    internal
    lunch "${PRODUCT}-${TYPE}"
  fi

  export ANDROID_SERIAL=$SERIAL
}

function {
  typeset -A devices
  typeset -A only
  devices[shamu]="ZX1G22LGPK"

  devices[flounder]="HT46CJT00073"
  only[flounder]="aosp"

  devices[volantis]="HT46CJT00073"
  only[volantis]="internal"

  devices[seed]="1764c48e"
  only[seed]="internal"

  devices[sprout]="6I4804CGACA406A"
  only[sprout]="internal"

  devices[angler]="84B7N15818000564"
  devices[bullhead]="00ade0ddf4892033"
  devices[flo]="06d25a85"
  devices[hammerhead]="03baf040437e94f1"

  function gen_aliases() {
    local PRODUCT=$1
    local TYPE=$2
    local SERIAL=$3
    alias "${PRODUCT}_${TYPE}_user"="__generic_device ${TYPE} ${PRODUCT} user ${SERIAL}"
    alias "${PRODUCT}_${TYPE}_userdebug"="__generic_device ${TYPE} ${PRODUCT} userdebug ${SERIAL}"
    alias "${PRODUCT}_${TYPE}_eng"="__generic_device ${TYPE} ${PRODUCT} eng ${SERIAL}"
    alias "${PRODUCT}_${TYPE}"="${PRODUCT}_${TYPE}_eng"
  }

  local PRODUCT
  for PRODUCT in "${(@k)devices}"; do
    local SERIAL=$devices[$PRODUCT]
    local ONLY=$only[$PRODUCT]

    if [ "$ONLY" ]; then
      gen_aliases $PRODUCT $ONLY $SERIAL
      alias "${PRODUCT}"="${PRODUCT}_${ONLY}"
      alias "${PRODUCT}_user"="${PRODUCT}_${ONLY}_user"
      alias "${PRODUCT}_userdebug"="${PRODUCT}_${ONLY}_userdebug"
      alias "${PRODUCT}_eng"="${PRODUCT}_${ONLY}_eng"
    else
      gen_aliases $PRODUCT aosp $SERIAL
      gen_aliases $PRODUCT internal $SERIAL
      alias "${PRODUCT}"="${PRODUCT}_internal"
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
    if [[ -d $local_path ]]; then
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

export USE_NINJA=true
alias n='m USE_GOMA=true -j1024'
alias nn='mm USE_GOMA=true -j1024'
alias nna='mma USE_GOMA=true -j1024'
