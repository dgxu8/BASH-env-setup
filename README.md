# BASH-env-setup
setup scripts for linux bash environments

Install scripts in the following order:
1. install_base.sh
2. setup_env.sh

## For WSL run
- wsl_setup.sh

## Improve wsl ssh performance
In powershell run:
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow
