#!/bin/bash

PROMPT_ON_PUSH=false

# git wrapper providing custom behavior for the following commands:
#
#   git fixup
#
#     Automatically finds the most recent non-fixup commit and
#     creates a fixup commit against it
#
#   git push
#
#     Optionally prompts the user before pushing
#
#   git pull
#
#     A safer version of the default that explicitly calls
#
#       git pull <default_remote> <current_branch>
#       git merge <default_remote>/<current_branch>
#
#   git rebase --autofixup
#
#     Provides a custom option "--autofixup" that automatically
#     finds the most recent non-fixup commit to use as the base
#     commit to rebase against before calling rebase --autosquash
function git {
  command="${1}"
  is_verbose=$(_is_verbose "${@}")

  case "${command}" in
    fixup)
      subject=$(_get_fixup_subject)

      _git add -A
      _git commit -m "fixup! ${subject}"

      ;;

    push)
      if [ "${PROMPT_ON_PUSH}" = true ]; then
        read -p "Do you really want to push this? " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "Aborted."
          return 1
        fi
      fi

      _git "${@}"

      ;;

    pull)
      args=0

      for arg in "${@}"; do
        case "${arg}" in
          pull|-v|--verbose)
            # do nothing
            ;;
          *)
            (( args++ ))
            ;;
        esac
      done

      # passes through to git if additional parameters are passed
      if [[ ${args} > 0 ]]; then
        _git "${@}"

        return
      fi

      current_branch=$(git rev-parse --abbrev-ref HEAD)
      default_remote=$(git config --get branch."${current_branch}".remote)

      fetch_command="_git fetch ${default_remote} ${current_branch}"

      $is_verbose && {
        echo "${fetch_command}"
        fetch_command="${fetch_command} 2>&1 | sed 's/^/# /'"
      }

      fetch_status=$(eval ${fetch_command})
      echo "${fetch_status}"

      if [[ "${fetch_status}" =~ "Already up-to-date." ]]; then
        return
      fi

      merge_command="_git merge ${default_remote}/${current_branch}"

      $is_verbose && {
        echo -e "\n${merge_command}"
        merge_command="${merge_command} 2>&1 | sed 's/^/# /'"
      }

      merge_status=$(eval "${merge_command}")
      echo "${merge_status}"

      ;;

    rebase)
      do_autofixup=false

      for arg in "${@}"; do
        if [[ "${arg}" == "--autofixup" ]]; then
          do_autofixup=true
        fi
      done

      if [ "${do_autofixup}" = true ]; then
        hash="$(_get_fixup_hash)~1"
        _git rebase -i --autosquash "${hash}"
      else
        _git "${@}"
      fi

      ;;

    *)
      _git "${@}"

      ;;
  esac
}

# Executes the git command, bypassing the function above
function _git {
  command git "${@}"
}

# Gets the hash from the most recent non-fixup commit
function _get_fixup_hash {
  echo $(_get_fixup "%h")
}

# Gets the subject from the most recent non-fixup commit
function _get_fixup_subject {
  echo $(_get_fixup "%s")
}

# Gets the most recent non-fixup commit, formatted according
# to the provided custom format
function _get_fixup {
  format="${1}"

  echo $(_git log -n 1 --grep "^fixup!" --invert-grep --pretty="format:${format}")
}

# Checks if verbose output is requested
function _is_verbose {
  for arg in "${@}"; do
    if [[ "${arg}" == "-v" || "${arg}" == "--verbose" ]]; then
      echo true
      return
    fi
  done

  echo false
  return
}
