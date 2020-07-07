#!/bin/bash

main() {
  echo "" # see https://github.com/actions/toolkit/issues/168

  if usesBoolean "${ACTIONS_STEP_DEBUG}"; then
    echo "::add-mask::${INPUT_HOST}"
    echo "::add-mask::${INPUT_USERNAME}"
    echo "::add-mask::${INPUT_KEY}"
    echo "::add-output::${INPUT_TARGET}"
    echo "::add-output::${INPUT_FILES}"
    echo "::add-output::${INPUT_RECURSIVE}"
  fi

  # make sure remote folder exists
  CMDS="-mkdir \"${INPUT_TARGET}\"\n"
  FOLDER=$(dirname $INPUT_TARGET)
  OLDFOLDER="${INPUT_TARGET}"
  while [ "${FOLDER}" != "." -a "${FOLDER}" != "/" -a "${FOLDER}" != "${OLDFOLDER}" ]; do
    CMDS="-mkdir \"${FOLDER}\"\n${CMDS}"
    OLDFOLDER="${FOLDER}"
    FOLDER=$(dirname ${FOLDER})
  done

  # copy the files
  for x in ${INPUT_FILES}; do
    if [ -e "${x}" ]; then
      CMDS="${CMDS}\nput \"${x}\" \"${INPUT_TARGET}\"\n"
    fi
  done

  if usesBoolean "${ACTIONS_STEP_DEBUG}"; then
    echo "::add-output::${CMDS}"
  fi

  # save script
  echo -e "${CMDS}" > batchjob

  # save key
  echo "${INPUT_KEY}" > sshkey
  chmod 600 sshkey

  # copy files
  sftp -r -p -i sshkey -b batchjob ${INPUT_USERNAME}@${INPUT_HOST}
}

usesBoolean() {
  [ ! -z "${1}" ] && [ "${1}" = "true" ]
}

main
