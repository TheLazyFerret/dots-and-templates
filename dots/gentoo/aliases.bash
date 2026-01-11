#!/bin/bash

# System update aliases
alias sys-update='sudo emaint --auto sync'
alias sys-upgrade='sudo emerge --ask --verbose --update --deep --changed-use --getbinpkg @world'
alias sys-clean='sudo emerge --ask --depclean'
