#!/usr/bin/env bash

# Dependencies of the script.
DEPENDENCIES="awk flatpak rpm-ostree tail grep"
# Don´t ask for confirmation in the commands.
ASSUME_YES="false"
# Fedora remotes list.
FEDORA_REMOTES="fedora fedora-testing"

# Function to check if all dependencies are installed.
check_dependencies() {
  dependency_not_found="false"
  for i in $DEPENDENCIES; do
    if ! command -v "$i" > /dev/null 2>&1; then
      echo "dependency $i not found"
      dependency_not_found="true"
    fi
  done

  if [ $dependency_not_found = true ]; then
    exit 1
  fi
}

# Parse the invoque arguments.
parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case $1 in
      # Assume-yes
      -y | --assumeyes)
        ASSUME_YES="true"
        ;;
      *)
        echo "Unkown option: $1"
        exit 1
    esac
    shift
  done
}

# Update system.
update_system() {
  while true; do
    state=$(rpm-ostree status | grep State | awk '{print $2}')
    if [ $state = "busy" ]; then
      sleep 10
    else
      rpm-ostree update
      return 0
    fi
  done
}

# Enable flafhub remote
enable_flathub_remote() {
  # if exists, will not be empty
  exist=$(flatpak remote-list --show-disabled | grep flathub)
  enabled=$(flatpak remote-list --show-disabled | grep -E 'flathub\s+.*disabled.*')
  if [ -z "$exist" ]; then
    echo "Flathub doesn't exist!"
    return 1
  # if disabled, will not be empty
  elif [ -z "$enabled" ]; then
    echo "Flathub is already enable"
    return 1
  else
    flatpak remote-modify --enable flathub
    echo "Flathub enabled"
  fi
}

# Uninstall fedora flatpaks.
uninstall_fedora_flatpak() {
  packages_to_uninstall=$(flatpak list --columns=application,origin | grep fedora | awk '{print $1}')
  number_of_packages_uninstalled=0
  if [ -z "$packages_to_uninstall" ]; then
    echo "Not packages to uninstall!"
    return 0
  fi
  for i in $packages_to_uninstall; do
    flatpak uninstall --delete-data --force-remove --assume-yes $i
    number_of_packages_uninstalled=$(( number_of_packages_uninstalled + 1 ))
  done
  echo "Uninstalled $number_of_packages_uninstalled packages and runtimes"
}

# Disable fedora flatpak remote.
disable_fedora_remote() {
  for i in $FEDORA_REMOTES; do
    if ! flatpak remote-modify --disable $i 2>/dev/null; then
      echo "Error disabling the remote: $i"
    else
      echo "Correctly disabled the remote: $i"
    fi
  done
}

# Auxiliar function for uninstalling confirmation for fedora flatpaks.
uninstall_fedora_flatpak_confirmation() {
  while true; do
    read -e -p "Uninstall all fedora flatpaks? y/n: " -n 1
    if [ $REPLY = "y" ] || [ $REPLY = "Y" ]; then
      uninstall_fedora_flatpak
      return 0
    elif [ $REPLY = "n" ] || [ $REPLY = "N" ]; then 
      return 0
    fi
  done
}

# Auxiliar function for disabling confirmation for fedora remote.
disable_fedora_remote_confirmation() {
  while true; do
    read -e -p "Disable fedora flatpak remote(requires root)? y/n: " -n 1
    if [ $REPLY = "y" ] || [ $REPLY = "Y" ]; then
      disable_fedora_remote
      return 0
    elif [ $REPLY = "n" ] || [ $REPLY = "N" ]; then
      return 0
    fi
  done
}

# Auxiliar function for enabling confirmation for flathub remote.
enable_flathub_remote_confirmation() {
  while true; do
    read -e -p "Enable flathub remote(requires root)? y/n: " -n 1
    if [ $REPLY = "y" ] || [ $REPLY = "Y" ]; then
      enable_flathub_remote
      return 0
    elif [ $REPLY = "n" ] || [ $REPLY = "N" ]; then
      return 0
    fi
  done
}

# Main program.
check_dependencies
parse_arguments "$@"
update_system

if [ $ASSUME_YES = "true" ]; then
  uninstall_fedora_flatpak
  disable_fedora_remote
  enable_flathub_remote
else
  uninstall_fedora_flatpak_confirmation
  disable_fedora_remote_confirmation
  enable_flathub_remote_confirmation
fi