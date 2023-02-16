#:  * `update-reset` [<repository> ...]
#:
#:  Fetch and reset Homebrew and all tap repositories (or any specified <repository>) using `git`(1) to their latest `origin/HEAD`.
#:
#:  *Note:* this will destroy all your uncommitted or committed changes.

# Replaces the function in Library/Homebrew/brew.sh to cache the Git executable to provide
# speedup when using Git repeatedly and prevent errors if the shim changes mid-update.
git() {
  if [[ -z "${GIT_EXECUTABLE}" ]]
  then
    # HOMEBREW_LIBRARY is set by bin/brew
    # shellcheck disable=SC2154
    GIT_EXECUTABLE="$("${HOMEBREW_LIBRARY}/Homebrew/shims/shared/git" --homebrew=print-path)"
  fi
  "${GIT_EXECUTABLE}" "$@"
}

homebrew-update-reset() {
  local option
  local DIR
  local -a REPOS=()

  for option in "$@"
  do
    case "${option}" in
      -\? | -h | --help | --usage)
        brew help update-reset
        exit $?
        ;;
      --debug) HOMEBREW_DEBUG=1 ;;
      -*)
        [[ "${option}" == *d* ]] && HOMEBREW_DEBUG=1
        ;;
      *)
        if [[ -d "${option}" ]]
        then
          REPOS+=("${option}")
        else
          local owner="${option%/*}"
          local name="${option#*/}"
          name="${name#homebrew-}" # Support both homebrew/core and homebrew/homebrew-core.

          local repo_path="${HOMEBREW_LIBRARY}/Taps/${owner}/homebrew-${name}"
          if [[ -d "${repo_path}" ]]
          then
            REPOS+=("${repo_path}")
          else
            odie "Could not find tap: ${option}"
          fi
        fi
        ;;
    esac
  done

  if [[ -n "${HOMEBREW_DEBUG}" ]]
  then
    set -x
  fi

  if [[ -z "${REPOS[*]}" ]]
  then
    REPOS+=("${HOMEBREW_REPOSITORY}" "${HOMEBREW_LIBRARY}"/Taps/*/*)
  fi

  for DIR in "${REPOS[@]}"
  do
    [[ -d "${DIR}/.git" ]] || continue
    if ! git -C "${DIR}" config --local --get remote.origin.url &>/dev/null
    then
      opoo "No remote 'origin' in ${DIR}, skipping update and reset!"
      continue
    fi
    git -C "${DIR}" config --bool core.autocrlf false
    git -C "${DIR}" config --bool core.symlinks true
    ohai "Fetching ${DIR}..."
    git -C "${DIR}" fetch --force --tags origin
    git -C "${DIR}" remote set-head origin --auto >/dev/null
    echo

    ohai "Resetting ${DIR}..."
    head="$(git -C "${DIR}" symbolic-ref refs/remotes/origin/HEAD)"
    head="${head#refs/remotes/origin/}"
    git -C "${DIR}" checkout --force -B "${head}" origin/HEAD
    echo
  done
}
