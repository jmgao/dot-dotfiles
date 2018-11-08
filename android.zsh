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
  __android_switch /android/aosp true
}

function internal() {
  __android_switch /android/internal true
}

function pi() {
  __android_switch /android/pi-dev true
}

function __generic_device() {
  local REPO=$1
  local PRODUCT=$2
  local TYPE=$3
  local SERIAL=$4

  $REPO

  export ANDROID_SERIAL=$SERIAL
  lunch "${PRODUCT}-${TYPE}"
}

function {
  typeset -A devices
  typeset -A aosp
  local current="internal"

  devices[sailfish]="HT67E0300016"
  devices[taimen]="704KPTM000281"
  devices[walleye]="HT75P1A00083"
  devices[blueline]="822X0028S"
  devices[hikey960]="hikey960"

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
      PRODUCT_PREFIX=""
    fi

    if [[ $PRODUCT == hikey960 ]]; then
      PRODUCT_PREFIX=""
    fi

    alias "${PRODUCT}-${REPO}-user"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} user ${SERIAL}"
    alias "${PRODUCT}-${REPO}-userdebug"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} userdebug ${SERIAL}"
    alias "${PRODUCT}-${REPO}-eng"="__generic_device ${REPO} ${PRODUCT_PREFIX}${PRODUCT} eng ${SERIAL}"
    alias "${PRODUCT}-${REPO}"="${PRODUCT}-${REPO}-userdebug"
  }

  function gen_aliases() {
    local PRODUCT=$1
    local AOSP=$2
    local SERIAL=$3

    gen_alias $PRODUCT pi $AOSP $SERIAL
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

function ms() {
  m installed-file-list "${@}"
}

function setup_jdk() {
  # Remove the current JDK from PATH
  if [ -n "$JAVA_HOME" ] ; then
    PATH=${PATH/$JAVA_HOME\/bin:/}
  fi
  export JAVA_HOME=$1
  export PATH=$JAVA_HOME/bin:$PATH
}

function _cherry() {
  local dry=$1
  local src_branch=$2
  local local_path=$3
  if [[ -z "$local_path" ]]; then
    local_path="."
  fi
  echo "git cherry HEAD $src_branch | grep '^+' | cut -d' ' -f2"
  for sha in `git cherry HEAD $src_branch | grep '^+' | cut -d' ' -f2`; do
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

function cherry() {
  _cherry false $@
}

function cherry_dry() {
  _cherry true $@
}

if [ -d $HOME/.android/sdk ]; then
  export ANDROID_HOME="$HOME/.android/sdk"
  PATH="$PATH:$ANDROID_HOME/tools"
fi

export GOMA_DIR=$HOME/.goma
export USE_GOMA=true

alias lcf='adb logcat -c; adb logcat -v color | egrep --line-buffered -v "(qmi_client|fpce_|slim_daemon|sensorservice|NuPlayer|AtCmdFwd|MediaPlayer)"'

alias lock_max="adb shell 'for x in /sys/devices/system/cpu/cpu?/cpufreq; do echo userspace > \$x/scaling_governor; cat \$x/scaling_max_freq > \$x/scaling_setspeed; done'"
alias lock_min="adb shell 'for x in /sys/devices/system/cpu/cpu?/cpufreq; do echo userspace > \$x/scaling_governor; cat \$x/scaling_min_freq > \$x/scaling_setspeed; done'"
alias unlock="adb shell 'for x in /sys/devices/system/cpu/cpu?/cpufreq; do echo sched > \$x/scaling_governor; done'"

alias adbrepo='cd /android/adb; source setup.sh'
