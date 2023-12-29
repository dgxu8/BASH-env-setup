#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import shutil
import subprocess

from glob import glob
from copy import deepcopy
from pathlib import Path
from typing import List, Dict, Union, Set

from prompt_toolkit import prompt
from prompt_toolkit.completion import (
    NestedCompleter,
    FuzzyCompleter,
    WordCompleter,
)

# Yaml imports
import yaml

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


INSTALLS_FILE = "installs.yml"

DEPENDS_ATTR_KEY = "__depends__"
RDEPENDS_ATTR_KEY = "__rdepends__"
INSTALL_ATTR_KEY = "_install_fmt"
CHECK_ATTR_KEY = "_check_fmt"


class NodeAttributes:
    def __init__(self, pkg_info: Union[dict, str]):
        self.depends: List[str] = []
        self.rdepends: List[str] = []
        self.install_fmt = None
        self.check_fmt = None
        if isinstance(pkg_info, dict):
            self.update_attr(pkg_info)

    def copy_update(self, pkg_info: dict) -> NodeAttributes:
        """Returns a copy of itself with updated attributes"""
        new_attr = deepcopy(self)
        new_attr.update_attr(pkg_info)
        return new_attr

    def update_attr(self, pkg_info: dict):
        """Update attributes of object with pkg_info"""
        self.depends += listify_element(pkg_info, DEPENDS_ATTR_KEY)
        self.rdepends += listify_element(pkg_info, RDEPENDS_ATTR_KEY)
        self.install_fmt = pkg_info.get(INSTALL_ATTR_KEY, self.install_fmt)
        self.check_fmt = pkg_info.get(CHECK_ATTR_KEY, self.check_fmt)

    def __str__(self):
        mstr = stringify(vars(self))
        if len(mstr) == 0:
            return "none"
        return "[" + mstr + "]"


class PackageNode:
    def __init__(
        self, key_name: str, pkg_info: Union[dict, str], parent_attr: NodeAttributes
    ):
        self.is_installed = False
        self._key_name = key_name
        self.install_cmd = None
        self.check_cmd = None

        if isinstance(pkg_info, str):
            pkg_info = {"name": pkg_info}

        self.attr = parent_attr.copy_update(pkg_info)
        try:
            if self.attr.install_fmt is not None:
                self.install_cmd = self.attr.install_fmt.format(**pkg_info)
        except KeyError:
            print(f"Can't format install format. {self.attr.install_fmt}, {pkg_info}")
            raise

        try:
            if self.attr.check_fmt is not None:
                self.check_cmd = self.attr.check_fmt.format(**pkg_info)
        except KeyError:
            print(f"Can't format check format. {self.attr.check_fmt}, {pkg_info}")
            raise

        self.name = pkg_info.get("name", None)
        self.wrk_dir = (
            os.path.expanduser(pkg_info["dir"]) if "dir" in pkg_info else None
        )
        self.pre_cmds = listify_element(pkg_info, "pre_cmds")
        self.cmds = listify_element(pkg_info, "cmds")

    def __str__(self):
        return stringify(vars(self))

    def check(self) -> bool:
        installed = False
        try:
            if self.check_cmd is None:
                print(f"No check command for {self._key_name}")
            else:
                ret = subprocess.run(self.check_cmd, shell=True, capture_output=True)
                if ret.returncode == 0:
                    installed = True

        except subprocess.CalledProcessError:
            print(f"Failed to run check command: {self.check_cmd}")
            print(str(self), end="\n\n")
            raise
        return installed

    def _run_cmds(self, cmds: List[str]):
        for cmd in cmds:
            cmd_list = cmd.split()
            if cmd_list[0] == "cd":
                assert len(cmd_list) == 2, f"Too many arguments for cd command: {cmd}"
                dest = os.path.expanduser(cmd_list[1])
                dest = glob(dest)[0]
                print(f"cd'ing to {dest}")
                os.chdir(dest)
            else:
                subprocess.run(cmd, shell=True, check=True)

    def install(self, pkg_dict, forced: bool = False) -> List[str]:
        """Install if not already installed

        return: list of newly installed packages
        """
        if self.is_installed and not forced:
            print(f"{self._key_name} already installed")
            return []

        print(f"\nInstalling {self._key_name}")
        new_pkgs = [self._key_name]

        # Install all depends
        for pkg in self.attr.depends:
            new_pkgs += pkg_dict[pkg].install(pkg_dict)

        if self.wrk_dir is not None:
            if not os.path.exists(self.wrk_dir):
                os.makedirs(self.wrk_dir)
            os.chdir(self.wrk_dir)
            print(f"cd'ing to {os.getcwd()}")

        # Install self
        try:
            if len(self.pre_cmds) > 0:
                print("Running pre-commands")
                self._run_cmds(self.pre_cmds)

            if self.install_cmd is not None:
                print("Running install command")
                subprocess.run(self.install_cmd, shell=True, check=True)

            if len(self.cmds) > 0:
                print("Running commands")
                self._run_cmds(self.cmds)

        except subprocess.CalledProcessError:
            print(f"\n===Failed to install {self._key_name}===")
            print(str(self), end="\n\n")
            raise

        # Install RDEPENDS
        for pkg in self.attr.rdepends:
            new_pkgs += pkg_dict[pkg].install(pkg_dict)

        print(f"Finished installing {self._key_name}\n")
        return new_pkgs


class LocalStateHandler:
    def __init__(self):
        self.install_yml = Path(
            os.path.expanduser("~/.local/state/pkg_env/installed.yml")
        )
        self.install_yml.parent.mkdir(parents=True, exist_ok=True)

        self.installed_list = self._read_yaml()

    def _read_yaml(self) -> List[str]:
        """Get currently install objects from cfg file"""
        if not self.install_yml.exists():
            return []

        with self.install_yml.open("r") as stream:
            return yaml.load(stream, Loader=Loader)

    def add_pkgs(self, pkgs: List[str], quiet: bool = False):
        """Update yaml with newly installed packages"""
        if not quiet:
            for pkg in filter(lambda x: x in self.installed_list, pkgs):
                print(f"{pkg} is already in yaml")
        self.installed_list = list(set(self.installed_list + pkgs))
        self.installed_list.sort()

        try:
            with self.install_yml.open("w") as stream:
                yaml.dump(self.installed_list, stream, Dumper=Dumper)
        except Exception:
            print(f"Failed to add {self.installed_list}")
            raise

    def remove_pkgs(self, pkgs: Set[str], quiet: bool = False):
        if not quiet:
            for pkg in filter(lambda x: x not in self.installed_list, pkgs):
                print(f"{pkg} not in yaml")
        self.installed_list = list(set(self.installed_list) - pkgs)
        self.installed_list.sort()

        try:
            with self.install_yml.open("w") as stream:
                yaml.dump(self.installed_list, stream, Dumper=Dumper)
        except Exception:
            print(f"Failed to remove {self.installed_list}")
            raise


class PackageManager:
    def __init__(self):
        self.local_state = LocalStateHandler()
        self.pkg_dict = build_dependency_dict()

        self.update_pkg_dict(adds=self.local_state.installed_list, quiet=True)

    def get_list(self, sub_cmd: str) -> List[str]:
        if sub_cmd == "curr":
            pkgs_list = self.local_state.installed_list
        elif sub_cmd == "new":
            pkgs_list = set(self.pkg_dict.keys()) - set(self.local_state.installed_list)
        else:
            pkgs_list = self.pkg_dict.keys()
        pkgs = list(pkgs_list)
        pkgs.sort()
        return pkgs

    def cmd_check(self, pkgs: List[str]):
        add_pkgs: List[str] = []
        remove_pkgs: List[str] = []

        if "all" in pkgs:
            pkgs = list(self.pkg_dict.keys())
        elif "new" in pkgs:
            new = set(self.pkg_dict.keys()) - set(self.local_state.installed_list)
            pkgs = list(new)

        for pkg in pkgs:
            assert pkg in self.pkg_dict, f'"{pkg}" is not a valid package'

            pkg_node: PackageNode = self.pkg_dict[pkg]
            if pkg_node.check_cmd is None:
                print(f"{pkg}:\t{pkg_node.is_installed}")
            else:
                stored_val = pkg_node.is_installed
                installed = self.pkg_dict[pkg].check()
                print(f"{pkg}:\t{installed}")
                if installed != stored_val:
                    if installed:
                        add_pkgs.append(pkg)
                    else:
                        remove_pkgs.append(pkg)

        if len(add_pkgs + remove_pkgs) > 0:
            print("Updating installed state")
            if len(add_pkgs) > 0:
                print(f"adds: {add_pkgs}")
            if len(remove_pkgs) > 0:
                print(f"removes: {remove_pkgs}")
        self.update_pkg_dict(add_pkgs, remove_pkgs)

    def cmd_install(self, pkgs: List[str]):
        for pkg in pkgs:
            assert pkg in self.pkg_dict, f'"{pkg}" is not a valid package'
            self.local_state.add_pkgs(self.pkg_dict[pkg].install(self.pkg_dict))

    def cmd_update(self, cmd, pkgs: List[str]):
        old_list = set(self.local_state.installed_list)
        if cmd == "add":
            self.update_pkg_dict(adds=pkgs)
            diff = set(self.local_state.installed_list) - old_list
            print(f"Added {diff}")
        elif cmd == "remove":
            self.update_pkg_dict(removes=pkgs)
            diff = old_list - set(self.local_state.installed_list)
            print(f"Removed {diff}")

    def update_pkg_dict(
        self,
        adds: List[str] = [],
        removes: List[str] = [],
        quiet: bool = False,
    ):
        if len(adds) > 0:
            self.local_state.add_pkgs(adds, quiet)
            for pkg in adds:
                if pkg in self.pkg_dict:
                    self.pkg_dict[pkg].is_installed = True

        if len(removes) > 0:
            self.local_state.remove_pkgs(set(removes), quiet)
            for pkg in removes:
                if pkg in self.pkg_dict:
                    self.pkg_dict[pkg].is_installed = False


class PackageCompleter(NestedCompleter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.packages: Dict[str, List[str]] = {}

    def add_list_cmd(self, cmd):
        self.get_list = cmd

    def add_pkg_list(self, entry: str, list_cmd):
        self.packages[entry] = list_cmd

    def get_completions(self, document, complete_event):
        yield from super().get_completions(document, complete_event)

        if len(document.text.split()) > 0:
            text = document.text
            for command, list_cmd in self.packages.items():
                if text.startswith(command):
                    cmp = WordCompleter(self.get_list(list_cmd))
                    yield from cmp.get_completions(document, complete_event)


def listify_element(ele_dict, name) -> List[str]:
    """Returns list version of a specific entry"""
    entry: Union[List[str], str] = ele_dict.get(name, [])
    return [entry] if isinstance(entry, str) else entry


def stringify(class_dict: dict) -> str:
    """Convert class dict to string"""
    is_valid = lambda n, v: not (
        n.startswith("__")
        or (v is None)
        or (isinstance(v, (list, tuple)) and len(v) == 0)
    )
    return ", ".join([f"{k}: {v}" for (k, v) in class_dict.items() if is_valid(k, v)])


def parse_category(packages: dict) -> dict:
    """Parse packge descriptions"""

    # Get archetype attributes
    pkg_dict: dict = {}
    arch_attr = NodeAttributes(packages)
    for key, value in packages.items():
        if key[0] == "_":
            continue

        pkg_dict[key] = PackageNode(key, value, arch_attr)

    return pkg_dict


def build_dependency_dict() -> Dict[str, PackageNode]:
    """Parse insalls yaml and build package dependency dict"""
    with open(INSTALLS_FILE, "r") as stream:
        installs = yaml.load(stream, Loader=Loader)

    # Delete tmp dir
    tmp_dir = os.path.expanduser(installs["_dirs_aliases"][0])
    if os.path.exists(tmp_dir):
        print(f"Deleteing previous tmp dir: {tmp_dir}")
        shutil.rmtree(tmp_dir)

    # archetype
    pkg_dict: dict = {}
    for archetype, packages in installs.items():
        if archetype[0] == "_":
            continue
        pkg_dict.update(parse_category(packages))

    return pkg_dict


HELP_STR = """
This script is used to manage system packages so they are sync'd across systems.

\thelp        Shows this message
\texit        Exists this program
\tlist        Lists packages {"all", "curr", "new"}
\tcheck       Checks to see if package is installed
\tinstall     Install given list of packages

The following are only used to manipulate the yaml file that tracks the installed packages.
\tadd         Adds package to yaml, won't install
\tremove      Removes package to yaml, won't uninstall
"""


def main():
    """Main Entry Point"""
    parser = argparse.ArgumentParser("Package Installer")
    parser.add_argument(
        "-l",
        "--list",
        choices=["all", "curr", "new"],
        default=None,
        help="List packages",
    )
    args = parser.parse_args()

    pkg = PackageManager()

    if args.list is not None:
        pkgs_list = pkg.get_list(args.list)
        print(", ".join(pkgs_list))
        return

    list_sub = {
        "all": None,
        "curr": None,
        "new": None,
    }

    base_cmds = {
        "list": list_sub,
        "check": {"all", "new"},
        "install": None,
        "add": None,
        "remove": None,
        "clean": None,
        "help": None,
        "exit": None,
    }

    completer = PackageCompleter.from_nested_dict(base_cmds)
    completer.add_list_cmd(pkg.get_list)
    completer.add_pkg_list("check", "all")
    completer.add_pkg_list("install", "new")
    completer.add_pkg_list("add", "new")
    completer.add_pkg_list("remove", "curr")

    try:
        while True:
            cmd = prompt(
                "Enter command: ", completer=FuzzyCompleter(completer)
            )  # , complete_in_thread=True)
            if cmd in ["exit", "stop", "quit"]:
                break
            print(f"Got: {cmd}\n")

            cmd_list = cmd.split()
            if len(cmd_list) == 0:
                continue

            cmd = cmd_list[0]
            if cmd == "help":
                print(HELP_STR)
            elif cmd == "list":
                assert len(cmd_list) <= 2
                sub_cmd = "all" if len(cmd_list) == 1 else cmd_list[1]
                pkgs_list = pkg.get_list(sub_cmd)
                print(", ".join(pkgs_list))
            elif cmd == "check":
                assert len(cmd_list) > 1
                pkg.cmd_check(cmd_list[1:])
            elif cmd == "install":
                assert len(cmd_list) > 1
                pkg.cmd_install(cmd_list[1:])
            elif cmd in ("add", "remove"):
                assert len(cmd_list) > 1
                pkg.cmd_update(cmd, cmd_list[1:])
            elif cmd == "clean":
                print("Remove packages is installed yaml if not in install list")
            else:
                print(f"{cmd} is an invalid command")

    except KeyboardInterrupt:
        print("\nCaught keyboard interrupt")
    except AssertionError as e:
        print(e)


if __name__ == "__main__":
    main()
