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
#   git rebase --autofixup
#
#     Provides a custom option "--autofixup" that automatically
#     finds the most recent non-fixup commit to use as the base
#     commit to rebase against before calling rebase --autosquash
function git {
  command="${1}"

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

    rebase)
      do_autofixup=false

      for arg in "${@}"; do
        if [[ "${arg}" == "--autofixup" ]]; then
          do_autofixup=true
        fi
      done

      if [ "${do_autofixup}" = true ]; then
        hash=$(_get_fixup_hash)

        _git rebase -i --autosquash "${hash}~1"
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

