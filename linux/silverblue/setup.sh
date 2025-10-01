#!/usr/bin/env bash

# Dependencies of the script.
DEPENDENCIES="awk flatpak rpm-ostree tail grep"
# Don´t ask for confirmation in the commands.
ASSUME_YES="false"
# Fedora remotes list.
FEDORA_REMOTES="fedora fedora-testing"
# Name of the file who stores the flatpak list.
FLATPAK_LIST="flatpak_list"

OSTREE_OVERRIDE_REMOVE_LIST="firefox firefox-langpacks"
OSTREE_LAYERED_INSTALL_LIST="distrobox steam-devices"

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
      echo -n "Updating system..."
      rpm-ostree update > /dev/null 2>&1
      echo " Done"
      return 0
    fi
  done
}

# Install the layered packages
install_layer_ostree() {
  while true; do
    state=$(rpm-ostree status | grep State | awk '{print $2}')
    if [ $state = "busy" ]; then
      sleep 10
    else
      echo -n "Installing the packages $OSTREE_LAYERED_INSTALL_LIST..."
      if ! rpm-ostree install "$OSTREE_LAYERED_INSTALL_LIST"; then
        echo " Error (not changes have been made)"
      else
        echo " Done"
      fi
    fi
  done
}

# Remove the packages from the base
remove_override_ostree() {
  while true; do
    state=$(rpm-ostree status | grep State | awk '{print $2}')
    if [ $state = "busy" ]; then
      sleep 10
    else
      echo -n "Removing the packages $OSTREE_OVERRIDE_REMOVE_LIST..."
      if ! rpm-ostree override remove "$OSTREE_OVERRIDE_REMOVE_LIST"; then
        echo " Error (not changes have been made)"
      else
        echo " Done"
      fi
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
    echo "Flathub is already enabled."
    return 1
  else
    flatpak remote-modify --enable flathub
    echo "Flathub correctly enabled."
  fi
}

# Uninstall fedora flatpaks.
uninstall_fedora_flatpak() {
  packages_to_uninstall=$(flatpak list --columns=application,origin | grep fedora | awk '{print $1}')
  number_of_packages_uninstalled=0
  if [ -z "$packages_to_uninstall" ]; then
    echo "Not fedora flatpak packages to uninstall!"
    return 0
  fi
  for i in $packages_to_uninstall; do
    flatpak uninstall --delete-data --force-remove --assume-yes $i
    number_of_packages_uninstalled=$(( number_of_packages_uninstalled + 1 ))
  done
  echo "Uninstalled $number_of_packages_uninstalled packages and runtimes."
}

# Disable fedora flatpak remote.
disable_fedora_remote() {
  for i in $FEDORA_REMOTES; do
    is_disabled=$(flatpak remotes --show-disabled | grep -E "^$i\s+.*disabled.*$")
    if [ -z is_disabled ]; then
      if $(flatpak remote-modify --disable $i 2>/dev/null); then
        echo "Remote $i correctly disabled."
      else
        echo "Error disabling the remote $i."
      fi
    else
      echo "The remote $i is already disabled."
      continue
    fi
  done
}

# Install the flathub selection from FLATPAK_LIST
install_flathub_selection() {
  if [ ! -f "$FLATPAK_LIST" ]; then
    echo "file $FLATPAK_LIST not found"
    return 1
  fi
  is_available=$(flatpak remotes | grep -E 'flathub')
  if [ -z "$is_available" ]; then
    echo "The remote flathub is not available."
    return 1
  fi
  for i in $(cat $FLATPAK_LIST | sort ); do
    # if is not empty, it is installed
    is_installed=$(flatpak list --columns=ref | grep $i)
    if [ ! -z "$is_installed" ]; then
      echo "The reference $i is already installed."
      continue
    fi
    if ! flatpak install --assumeyes flathub "$i" > /dev/null 2>&1; then
      echo "Error installing $i."
    fi
  done
}

# Function for save the new flathub selection.
save_flathub_selection() {
  flatpak list --app --columns=ref | tail -n +1 > $FLATPAK_LIST
}

# Auxiliar function for uninstalling confirmation for fedora flatpaks.
uninstall_fedora_flatpak_confirmation() {
  while true; do
    read -e -p "Uninstall all fedora flatpaks? y/n: " -n 1
    case $REPLY in
    [yY]) 
      uninstall_fedora_flatpak
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      return 0
    esac
  done
}

# Auxiliar function for disabling confirmation for fedora remote.
disable_fedora_remote_confirmation() {
  while true; do
    read -e -p "Disable fedora flatpak remote(requires root)? y/n: " -n 1
    case $REPLY in
    [yY]) 
      disable_fedora_remote
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      return 0
    esac
  done
}

# Auxiliar function for enabling confirmation for flathub remote.
enable_flathub_remote_confirmation() {
  while true; do
    read -e -p "Enable flathub flatpak remote(requires root)? y/n: " -n 1
    case $REPLY in
    [yY]) 
      enable_flathub_remote
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      continue
    esac
  done
}

# Auxiliar function for installing confirmation of flathub selection.
install_flathub_selection_confirmation() {
  while true; do
    read -e -p "Install the flathub apps selection? y/n: " -n 1
    case $REPLY in
    [yY]) 
      install_flathub_selection
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      continue
    esac
  done
}

# Auxiliar function for saving the new flathub apps list.
save_flathub_selection_confirmation() {
  while true; do
    read -e -p "Save the new flathub selection? y/n: " -n 1
    case $REPLY in
    [yY]) 
      save_flathub_selection
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      continue
    esac
  done 
}

# Auxiliar function for applying the changes in rpm-ostree.
apply_ostree_changes() {
  while true; do
    read -e -p "Make changes in ostree? y/n: " -n 1
    case $REPLY in
    [yY]) 
      install_layer_ostree
      remove_override_ostree
      return 0
      ;;
    [nN])
      return 0
      ;;
    *)
      continue
    esac
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
  install_flathub_selection
  save_flathub_selection

  install_layer_ostree
  remove_override_ostree
else
  uninstall_fedora_flatpak_confirmation
  disable_fedora_remote_confirmation
  enable_flathub_remote_confirmation
  install_flathub_selection_confirmation
  save_flathub_selection
  apply_ostree_changes
fi