#!/usr/bin/env bash

if [ ! -d "${HOME}" ]
then
  mkdir -p "${HOME}"
fi

if [ ! -d "${HOME}/.config/containers" ]
then
  mkdir -p ${HOME}/.config/containers
  (echo '[storage]';echo 'driver = "overlay"';echo 'graphroot = "/tmp/graphroot"';echo '[storage.options.overlay]';echo 'mount_program = "/usr/bin/fuse-overlayfs"') > ${HOME}/.config/containers/storage.conf
fi

#
# Set Up Environment with workspace specific config
#
WORKSPACE_RC=${PROJECT_SOURCE}/.workspace-init/workspace.rc
# Configure Z shell
if [ ! -f ${HOME}/.zshrc ]
then
  (echo "HISTFILE=${HOME}/.zsh_history"; echo "HISTSIZE=1000"; echo "SAVEHIST=1000") > ${HOME}/.zshrc
  (echo "if [ -f ${WORKSPACE_RC} ]"; echo "then"; echo "  . ${WORKSPACE_RC}"; echo "fi") >> ${HOME}/.zshrc
fi
# Configure Bash shell
if [ ! -f ${HOME}/.bashrc ]
then
  (echo "if [ -f ${WORKSPACE_RC} ]"; echo "then"; echo "  . ${WORKSPACE_RC}"; echo "fi") > ${HOME}/.bashrc
fi

exec "$@"
