#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import subprocess

from copy import deepcopy
from pathlib import Path
from typing import List, Optional, Union

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


class InstalledHandler:
    def __init__(self):
        self.install_yml = Path(os.path.expanduser("~/.config/custom_env/installed.yml"))
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


def build_dependency_dict():
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


def main():
    """Main Entry Point"""
    parser = argparse.ArgumentParser("Package Installer")
    parser.add_argument("-l", "--list", choices=["all", "current", "new"], default=None, help="List packages")
    args = parser.parse_args()

    ilist = InstalledHandler()
    pkg_dict = build_dependency_dict()

    if args.list is not None:
        if args.list == "all":
            pkgs_list = pkg_dict.keys()
        elif args.list == "current":
            pkgs_list = ilist.installed_list
        else:
            pkgs_list = set(pkg_dict.keys()) - set(ilist.installed_list)
        print(", ".join(pkgs_list))
        return

    ilist.update_pkg_dict(pkg_dict)

    new_pkgs = pkg_dict["lazygit"].install(pkg_dict)

    print(f"Installed {new_pkgs}")
    ilist.update_installed_packages(new_pkgs)


if __name__ == "__main__":
    main()
