#!/usr/bin/env bash

# For all functions: 
#   0 -> true 
#   1 -> false

### CONSTANTS
LAYER_PACKAGES="distrobox steam-devices"
OVERRIDE_PACKAGES="firefox firefox-langpacks"
FLATPAK_LIST="flatpak_list"
FEDORA_REMOTES="fedora fedora-testing"

APPS_TO_HIDE="org.freedesktop.MalcontentControl.desktop org.gnome.SystemMonitor.desktop yelp.desktop org.gnome.Tour.desktop"

DEPENDENCIES="rpm-ostree grep awk flatpak "

SYSTEMD_USER_SERVICES="podman.socket"

### FUNCTIONS
check_dependencies() {
  for i in $DEPENDENCIES; do
    if ! type $i > /dev/null 2>&1; then
      echo "  Dependency not found: $i"
    fi
  done
}

wait_ostree_busy() {
  while true; do
    state=$(rpm-ostree status | grep -i state | awk '{print $2}')
    if [ "$state" = "busy" ]; then
      echo "  rpm-ostree is busy, waiting"
      sleep 10
    else
      return 0
    fi
  done
}

is_package_layered() {
  layered_packages=$(rpm-ostree status | grep -i LayeredPackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for i in $layered_packages; do
    if [ "$1" = "$i" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_package_overrided() {
  overrided_packages=$(rpm-ostree status | grep -i RemovedBasePackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for i in $overrided_packages; do
    if [ "$1" = "$i" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_ref_installed() { # ref # package
  installed_refs=$(flatpak list --columns=ref,origin | awk '{print $1}')
  for u in $installed_refs; do
    if [ "$1" = "$u" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_remote_enabled() {
  active_remotes=$(flatpak remotes | awk '{print $1}')
  for i in $active_remotes; do
    if [ "$1" = "$i" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_remote_added() {
  added_remotes=$(flatpak remotes --show-disabled  | awk '{print $1}')
  for i in $added_remotes; do
    if [ "$1" = "$i" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

update_ostree() {
  wait_ostree_busy
  echo -n "  Updating system..."
  rpm-ostree update > /dev/null 2>&1
  echo " Done"
  return 0
}

layers_install_ostree() {
  aux=""
  for i in $LAYER_PACKAGES; do
    if ! is_package_layered "$i"; then
      aux="$aux $i"
    fi
  done
  if [ -z "$aux" ]; then
    echo "  Not packages to install"
    return 0
  fi
  wait_ostree_busy
  echo -n "  Installing layered packages..."
  if ! rpm-ostree install $aux > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

overrides_remove_ostree() {
  aux=""
  for i in $OVERRIDE_PACKAGES; do
    if ! is_package_overrided "$i"; then
      aux="$aux $i"
    fi
  done
  if [ -z "$aux" ]; then
    echo "  Not packages to remove"
    return 0
  fi
  wait_ostree_busy
  echo -n "  Removing override packages..."
  if ! rpm-ostree override remove $aux > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

uninstall_flatpak_remote() { # remote
  if ! is_remote_added $1; then
    echo "  The remote $1 is not in the remote list"
    return 0
  elif ! is_remote_enabled $1; then
    echo "  The remote $1 is disabled"
    return 0
  fi
  package_list=$(flatpak list --columns=ref,origin | grep "$1" | awk '{print $1}')
  if [ -z "$package_list" ]; then
    echo "  Not packages to uninstall"
    return 0
  fi
  for i in $package_list; do
    echo -n "  Uninstalling $i..."
    flatpak uninstall --delete-data --assumeyes "$i" > /dev/null 2>&1
    echo " Done"
  done
}

install_flatpak_selection() { # remote
  if ! is_remote_added $1; then
    echo "  The remote $1 is not in the remote list"
    return 1
  elif ! is_remote_enabled $1; then
    echo "  The remote $1 is disabled"
    return 1
  elif [ ! -f "$FLATPAK_LIST" ]; then
    echo "  The file doesn't exist"
    return 1
  fi
  package_list=$(cat "$FLATPAK_LIST")
  if [ -z "$package_list" ]; then
    echo "  Not packages to install"
    return 1
  fi
  for i in $package_list; do
    short_name=$(echo "$i" | cut -d '/' -f1)
    echo -n "  Installing the ref $short_name..."
    if is_ref_installed "$i"; then
      echo " Already installed"
      continue
    elif flatpak install "$1" "$i" > /dev/null 2>&1 ; then
      echo " Done"
    else
      echo " Fail"
    fi
  done
}

toggle_flatpak_remote() { # remote
  if ! is_remote_added $1; then
    echo "  The remote $1 is not in the remote list"
    return 1
  elif is_remote_enabled $1; then
    echo -n "  Disabling the remote $1..."
    flatpak remote-modify --disable "$1" > /dev/null 2>&1
    echo " Done"
  else
    echo -n "  Enabling the remote $1..."
    flatpak remote-modify --enable "$1" > /dev/null 2>&1
    echo " Done"
  fi
  return 0
}

ask_confirmation() { # message
  while true; do
    read -e -p "$1 y/n: " -n 1
    case $REPLY in
    [yY])
      return 0
      ;;
    [nN])
      return 1
      ;;
    *)
      continue
    esac
  done
}

hide_programs() {
  for i in $APPS_TO_HIDE; do
    if [ ! -f "$HOME/.local/share/applications/$i" ]; then
      mkdir -p "$HOME/.local/share/applications" > /dev/null 2>&1
      cp "/usr/share/applications/$i" "$HOME/.local/share/applications/$i" > /dev/null 2>&1
    elif [ -z "$(cat $HOME/.local/share/applications/$i | grep NoDisplay)" ]; then
      echo "NoDisplay=true" >> $HOME/.local/share/applications/$i
      echo "  Correctly hidden the .desktop: $i"
    fi
  done
}

enable_user_services() {
  for i in $SYSTEMD_USER_SERVICES; do
    systemctl enable --user --now "$i" > /dev/null 2>&1
    echo "  Enabled the systemd $i"
  done
}

add_flathub_remote() {
  if is_remote_added "flathub"; then
    echo "  The remote flathub is already enabled"
  else
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1
    echo " The remote flathub correctly enabled"
  fi
}

### MAIN
check_dependencies
# OSTREE
update_ostree
layers_install_ostree
overrides_remove_ostree

# FLATPAK
for remote in $FEDORA_REMOTES; do
  if is_remote_enabled "$remote"; then
    uninstall_flatpak_remote "$remote"
    if ask_confirmation "Disable $remote remote? (requires root)"; then
      toggle_flatpak_remote "$remote"
    fi
  fi
done

if ! is_remote_added "flathub"; then
  if ask_confirmation "Add flathub remote? (requires root)"; then
    add_flathub_remote
  fi
fi

if ! is_remote_enabled "flathub"; then
  if ask_confirmation "Enable flathub remote? (requires root)"; then
    toggle_flatpak_remote "flathub"
  fi
fi
install_flatpak_selection "flathub"

hide_programs
enable_user_services
