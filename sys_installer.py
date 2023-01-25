#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import subprocess

from copy import deepcopy
from pathlib import Path
from typing import List, Dict, Optional, Union

from prompt_toolkit import prompt
from prompt_toolkit.formatted_text import FormattedText
from prompt_toolkit.completion import Completer, NestedCompleter, FuzzyCompleter, Completion, WordCompleter

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
CHECK_ATTR_KEY = "__check_cmd"

class NodeAttributes:
    def __init__(self, pkg_info: Union[dict, str]):
        self.depends: List[str] = list()
        self.rdepends: List[str] = list()
        self.install_fmt = None
        self.check_cmd = None
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
        self.check_cmd = pkg_info.get(CHECK_ATTR_KEY, self.check_cmd)

    def __str__(self):
        mstr = stringify(vars(self))
        if len(mstr) == 0:
            return "none"
        return "[" + mstr + "]"


class PackageNode:
    def __init__(self, key_name: str, pkg_info: Union[dict, str], parent_attr: NodeAttributes):
        self.is_installed = False
        self._key_name = key_name
        self.install_cmd = None

        if isinstance(pkg_info, str):
            pkg_info = {"name": pkg_info}

        self.attr = parent_attr.copy_update(pkg_info)
        try:
            if self.attr.install_fmt is not None:
                self.install_cmd = self.attr.install_fmt.format(**pkg_info)
        except KeyError:
            print(f"Can't format install format. {self.attr.install_fmt}, {pkg_info}")
            raise

        self.name = pkg_info.get("name", None)
        self.wrk_dir = os.path.expanduser(pkg_info["dir"]) if "dir" in pkg_info else None
        self.pre_cmds = listify_element(pkg_info, "pre_cmds")
        self.cmds = listify_element(pkg_info, "cmds")

    def __str__(self):
        return stringify(vars(self))

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

        # TODO add _check_cmd handling

        if self.wrk_dir is not None:
            os.chdir(self.wrk_dir)
            print(f"cd'ing to {os.getcwd()}")

        # Install self
        try:
            if len(self.pre_cmds) > 0:
                print("Running pre-commands")
            for cmd in self.pre_cmds:
                subprocess.run(cmd, shell=True, check=True)

            if self.install_cmd is not None:
                print("Running install command")
                subprocess.run(self.install_cmd, shell=True, check=True)

            if len(self.pre_cmds) > 0:
                print("Running commands")
            for cmd in self.cmds:
                subprocess.run(cmd, shell=True, check=True)
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
        self.install_yml = Path(os.path.expanduser("~/.local/state/pkg_env/installed.yml"))
        self.install_yml.parent.mkdir(parents=True, exist_ok=True)

        self.installed_list = self.get_installed_packages()

    def get_installed_packages(self) -> List[str]:
        """Get currently install objects from cfg file"""
        if not self.install_yml.exists():
            return []

        with self.install_yml.open("r") as stream:
            return yaml.load(stream, Loader=Loader)

    def update_installed_packages(self, pkgs: List[str]):
        """Update yaml with newly installed packages"""
        updated_list = list(set(self.installed_list + pkgs))
        updated_list.sort()

        with self.install_yml.open("w") as stream:
            yaml.dump(updated_list, stream, Dumper=Dumper)

    def update_pkg_dict(self, pkg_dict: dict):
        """Sets is_installed to true on packages that are found in the yml cfg"""
        for pkg in self.installed_list:
            pkg_dict[pkg].is_installed = True


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
    pkg_dict: dict = dict()
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

    # archetype
    pkg_dict: dict = dict()
    for archetype, packages in installs.items():
        if archetype[0] == "_":
            continue
        pkg_dict.update(parse_category(packages))

    return pkg_dict


class PackageCompleter(NestedCompleter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.packages: Dict[str, List[str]] = dict()

    def add_pkg_list(self, entry: str, pkg_list: List[str]):
        self.packages[entry] = pkg_list

    def get_completions(self, document, complete_event):
        yield from super().get_completions(document, complete_event)

        text = document.text.split()
        if len(text) > 0 and text[0] in self.packages:
            cmp = WordCompleter(self.packages[text[0]])
            yield from cmp.get_completions(document, complete_event)

class PackageManager:
    def __init__(self):
        self.new_pkgs: List[str] = []
        self.local_state = LocalStateHandler()
        self.pkg_dict = build_dependency_dict()

        self.local_state.update_pkg_dict(self.pkg_dict)

    def save_new_pkgs(self):
        print(f"\nInstalled {self.new_pkgs}")
        self.local_state.update_installed_packages(self.new_pkgs)

    def get_prompt_dict(self):
        return {pkg_name: None for pkg_name in self.pkg_dict}

    def get_list(self, sub_cmd: str) -> List[str]:
        if sub_cmd == "current":
            pkgs_list = self.local_state.installed_list
        elif sub_cmd == "new":
            pkgs_list = set(self.pkg_dict.keys()) - set(self.local_state.installed_list)
        else:
            pkgs_list = self.pkg_dict.keys()
        pkgs = list(pkgs_list)
        pkgs.sort()
        return pkgs

    def cmd_check(self, pkgs: List[str]):
        for pkg in pkgs:
            assert pkg in self.pkg_dict, f'"{pkg}" is not a valid package'
            print(f"{pkg}:\t{self.pkg_dict[pkg].is_installed}")

    def cmd_install(self, pkgs: List[str]):
        for pkg in pkgs:
            assert pkg in self.pkg_dict, f'"{pkg}" is not a valid package'
            self.new_pkgs += self.pkg_dict[pkg].install(self.pkg_dict)


def main():
    """Main Entry Point"""
    parser = argparse.ArgumentParser("Package Installer")
    parser.add_argument("-l", "--list", choices=["all", "current", "new"], default=None, help="List packages")
    args = parser.parse_args()

    pkg = PackageManager()

    if args.list is not None:
        pkgs_list = pkg.get_list(args.list)
        print(", ".join(pkgs_list))
        return

    pkg_prompt_dict = pkg.get_prompt_dict()
    list_sub = {
        "all": None,
        "current": None,
        "new": None,
    }
    update_sub = {
        "add": None,
        "remove": None,
    }

    base_cmds = {
        "list": list_sub,
        "check": None,
        "install": None,
        "update": None,
        "exit": None,

    }

    completer = PackageCompleter.from_nested_dict(base_cmds)
    completer.add_pkg_list("check", pkg.get_list("all"))
    completer.add_pkg_list("install", pkg.get_list("new"))
    completer.add_pkg_list("update", pkg.get_list("current"))

    try:
        while True:
            cmd = prompt("Enter command: ", completer=FuzzyCompleter(completer))#, complete_in_thread=True)
            if cmd in ["exit", "stop", "quit"]:
                break
            print(f"Got: {cmd}\n")

            cmd_list = cmd.split(" ")
            if cmd_list[0] == "list":
                assert len(cmd_list) <= 2
                sub_cmd = "all" if len(cmd_list) == 1 else cmd_list[1]
                pkgs_list = pkg.get_list(sub_cmd)
                print(", ".join(pkgs_list))
            elif cmd_list[0] == "check":
                assert len(cmd_list) > 1
                pkg.cmd_check(cmd_list[1:])
            elif cmd_list[0] == "install":
                assert len(cmd_list) > 1
                pkg.cmd_install(cmd_list[1:])
            elif cmd_list[0] == "update":
                pass
    except KeyboardInterrupt:
        print("\nCaught keyboard interrupt")
    except AssertionError as e:
        print(e)
    finally:
        pkg.save_new_pkgs()


if __name__ == "__main__":
    main()
