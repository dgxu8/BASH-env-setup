#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "pyyaml",
#   "prompt_toolkit",
#   "requests",
# ]
# ///

from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess

from fnmatch import fnmatch
from glob import glob
from copy import deepcopy
from pathlib import Path
from typing import Any, Callable, override

from prompt_toolkit.document import Document
import requests
from prompt_toolkit import prompt
from prompt_toolkit.completion import (
    CompleteEvent,
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
PULL_GH_API = "_pull_from_gh"

type pkg_t = dict[str, str]


class InstallFailedError(Exception):
    pass


class NodeAttributes:
    def __init__(self, pkg_info: pkg_t|str):
        self.depends: list[str] = []
        self.rdepends: list[str] = []
        self.install_fmt: str|None = None
        self.check_fmt: str|None = None
        self.pull_from_gh: str|bool = False
        if isinstance(pkg_info, dict):
            self.update_attr(pkg_info)

    def copy_update(self, pkg_info: pkg_t) -> NodeAttributes:
        """Returns a copy of itself with updated attributes"""
        new_attr = deepcopy(self)
        new_attr.update_attr(pkg_info)
        return new_attr

    def update_attr(self, pkg_info: pkg_t):
        """Update attributes of object with pkg_info"""
        self.depends += listify_element(pkg_info, DEPENDS_ATTR_KEY)
        self.rdepends += listify_element(pkg_info, RDEPENDS_ATTR_KEY)
        self.install_fmt = pkg_info.get(INSTALL_ATTR_KEY, self.install_fmt)
        self.check_fmt = pkg_info.get(CHECK_ATTR_KEY, self.check_fmt)
        self.pull_from_gh = pkg_info.get(PULL_GH_API, self.pull_from_gh)

    @override
    def __str__(self):
        mstr = stringify(vars(self))
        if len(mstr) == 0:
            return "none"
        return "[" + mstr + "]"


class PackageNode:
    def __init__(
        self, key_name: str, pkg_info: pkg_t|str, parent_attr: NodeAttributes
    ):
        self.is_installed: bool = False
        self._key_name: str = key_name
        self.install_cmd: str|None = None
        self.check_cmd: str|None = None
        self.gh_repo: str|None = None

        if isinstance(pkg_info, str):
            pkg_info = {"name": pkg_info}

        self.attr: NodeAttributes = parent_attr.copy_update(pkg_info)

        try:
            if self.attr.pull_from_gh:
                pkg_name, self.gh_repo = get_gh_latest(pkg_info["repo"], pkg_info["glob"])
                pkg_info = pkg_info.copy()
                pkg_info["pkg_name"] = pkg_name
        except KeyError:
            print("If you need to set pull_from_gh, you need to set repo and regex")
            raise

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

        self.name: str|None = pkg_info.get("name", None)
        self.wrk_dir: str|None = (
            os.path.expanduser(pkg_info["dir"]) if "dir" in pkg_info else None
        )
        self.pre_cmds: list[str] = listify_element(pkg_info, "pre_cmds")
        self.cmds: list[str] = listify_element(pkg_info, "cmds")

    @override
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

    def _run_cmds(self, cmds: list[str]):
        for cmd in cmds:
            cmd_list = cmd.split()
            if cmd_list[0] == "cd":
                assert len(cmd_list) == 2, f"Too many arguments for cd command: {cmd}"
                dest = os.path.expanduser(cmd_list[1])
                dest = glob(dest)[0]
                print(f"cd'ing to {dest}")
                os.chdir(dest)
            else:
                _ = subprocess.run(cmd, shell=True, check=True)

    def install(self, pkg_dict: dict[str, PackageNode], forced: bool = False) -> list[str]:
        """Install if not already installed

        return: list of newly installed packages
        """
        if self.is_installed and not forced:
            print(f"{self._key_name} already installed")
            return []

        print(f"\nInstalling {self._key_name}")
        new_pkgs: list[str] = []

        # Install all depends
        for pkg in self.attr.depends:
            new_pkgs += (pkg_dict[pkg].install(pkg_dict))

        if self.wrk_dir is not None:
            if not os.path.exists(self.wrk_dir):
                os.makedirs(self.wrk_dir)
            os.chdir(self.wrk_dir)
            print(f"cd'ing to {os.getcwd()}")

        # Install self
        try:
            if self.attr.pull_from_gh:
                print(f"Pulling {self.gh_repo}")
                _ = subprocess.run(f"wget {self.gh_repo}", shell=True, check=True)

            if len(self.pre_cmds) > 0:
                print("Running pre-commands")
                self._run_cmds(self.pre_cmds)

            if self.install_cmd is not None:
                print("Running install command")
                _ = subprocess.run(self.install_cmd, shell=True, check=True)

            if len(self.cmds) > 0:
                print("Running commands")
                self._run_cmds(self.cmds)

        except subprocess.CalledProcessError as e:
            print(f"\n===Failed to install {self._key_name}===")
            print(str(self), end="\n\n")
            raise InstallFailedError(
                f"Failed to install {self._key_name}", new_pkgs
            ) from e

        new_pkgs.append(self._key_name)

        # Install RDEPENDS
        for pkg in self.attr.rdepends:
            new_pkgs += pkg_dict[pkg].install(pkg_dict)

        print(f"Finished installing {self._key_name}\n")
        return new_pkgs


class LocalStateHandler:
    def __init__(self):
        self.install_yml: Path = Path(
            os.path.expanduser("~/.local/state/pkg_env/installed.yml")
        )
        self.install_yml.parent.mkdir(parents=True, exist_ok=True)

        self.installed_list: list[Any] = self._read_yaml()

    def _read_yaml(self) -> list[Any]:
        """Get currently install objects from cfg file"""
        if not self.install_yml.exists():
            return []

        with self.install_yml.open("r") as stream:
            return yaml.load(stream, Loader=Loader)

    def add_pkgs(self, pkgs: list[str], quiet: bool = False):
        """Update yaml with newly installed packages"""
        if len(pkgs) == 0:
            return

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

    def remove_pkgs(self, pkgs: set[str], quiet: bool = False):
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
    def __init__(self, installs_file: str):
        self.local_state: LocalStateHandler = LocalStateHandler()
        self.pkg_dict: dict[str, PackageNode] = build_dependency_dict(installs_file)

        self.update_pkg_dict(adds=self.local_state.installed_list, quiet=True)

    def get_list(self, sub_cmd: str) -> list[str]:
        if sub_cmd == "curr":
            pkgs_list = self.local_state.installed_list
        elif sub_cmd == "new":
            pkgs_list = set(self.pkg_dict.keys()) - set(self.local_state.installed_list)
        else:
            pkgs_list = self.pkg_dict.keys()
        pkgs = list(pkgs_list)
        pkgs.sort()
        return pkgs

    def cmd_check(self, pkgs: list[str]):
        add_pkgs: list[str] = []
        remove_pkgs: list[str] = []

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

    def cmd_install(self, pkgs: list[str]):
        for pkg in pkgs:
            assert pkg in self.pkg_dict, f'"{pkg}" is not a valid package'
            installed = []
            try:
                installed = self.pkg_dict[pkg].install(self.pkg_dict)
            except InstallFailedError as err:
                installed = err.args[1]
            finally:
                self.local_state.add_pkgs(installed)

    def cmd_update(self, cmd: str, pkgs: list[str]):
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
        adds: list[str]|None = None,
        removes: list[str]|None = None,
        quiet: bool = False,
    ):
        if adds is not None:
            self.local_state.add_pkgs(adds, quiet)
            for pkg in adds:
                if pkg in self.pkg_dict:
                    self.pkg_dict[pkg].is_installed = True

        if removes is not None:
            self.local_state.remove_pkgs(set(removes), quiet)
            for pkg in removes:
                if pkg in self.pkg_dict:
                    self.pkg_dict[pkg].is_installed = False


class PackageCompleter(NestedCompleter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.packages: dict[str, str] = {}

    def add_list_cmd(self, cmd: Callable[[str], list[str]]):
        self.get_list: Callable[[str], list[str]] = cmd

    def add_pkg_list(self, entry: str, list_cmd: str):
        self.packages[entry] = list_cmd

    @override
    def get_completions(self, document: Document, complete_event: CompleteEvent):
        yield from super().get_completions(document, complete_event)

        if len(document.text.split()) > 0:
            text = document.text
            for command, list_cmd in self.packages.items():
                if text.startswith(command):
                    cmp = WordCompleter(self.get_list(list_cmd))
                    yield from cmp.get_completions(document, complete_event)


def listify_element(ele_dict: pkg_t, name: str) -> list[str]:
    """Returns list version of a specific entry"""
    entry: list[str]|str = ele_dict.get(name, [])
    return [entry] if isinstance(entry, str) else entry


def stringify(class_dict: dict[str, Any]) -> str:
    """Convert class dict to string"""
    return ", ".join(
        [f"{k}: {v}" for (k, v) in class_dict.items()
         if (k.startswith("__") or (v is None) or (isinstance(v, (list, tuple)) and len(v) == 0))])


def parse_category(packages: dict) -> dict[str, PackageNode]:
    """Parse packge descriptions"""

    # Get archetype attributes
    pkg_dict = {}
    arch_attr = NodeAttributes(packages)
    for key, value in packages.items():
        if key[0] == "_":
            continue

        pkg_dict[key] = PackageNode(key, value, arch_attr)

    return pkg_dict


def build_dependency_dict(installs_file: str) -> dict[str, PackageNode]:
    """Parse insalls yaml and build package dependency dict"""
    with open(installs_file, "r") as stream:
        installs = yaml.load(stream, Loader=Loader)

    # Delete tmp dir
    tmp_dir = os.path.expanduser(installs["_dirs_aliases"][0])
    if os.path.exists(tmp_dir):
        print(f"Deleteing previous tmp dir: {tmp_dir}")
        shutil.rmtree(tmp_dir)

    # archetype
    pkg_dict = {}
    for archetype, packages in installs.items():
        if archetype[0] == "_":
            continue
        pkg_dict.update(parse_category(packages))

    return pkg_dict


def get_gh_latest(repo: str, pkg_glob: str) -> tuple[str, str]:
    """Uses github's api to search the releases for a package"""
    name = None
    addr = None

    # curl -s https://api.github.com/repos/{repo}/releases/latest
    resp = requests.get(f"https://api.github.com/repos/{repo}/releases/latest", timeout=5)
    assert resp.status_code == 200, f"github api request on {repo} failed"

    assets = resp.json()["assets"]
    for download in assets:
        if fnmatch(download["name"], pkg_glob):
            assert addr is None, f"Multiple matches found for {pkg_glob}"
            addr = download["browser_download_url"]
            name = download["name"]
    assert None not in (name, addr), f"No matches found for {pkg_glob} in {resp}"
    assert isinstance(name, str) and isinstance(addr, str)

    return name, addr


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
    os_id = platform.freedesktop_os_release()["ID"]
    if os_id == "ubuntu":
        default_yaml = "installs.yml"
    elif os_id in ("endeavouros", "arch"):
        default_yaml = "arch_installs.yml"
    else:
        print(f"OS {os_id} not supported")
        return 1

    parser = argparse.ArgumentParser("Package Installer")
    parser.add_argument(
        "-l",
        "--list",
        choices=["all", "curr", "new"],
        default=None,
        help="List packages",
    )
    parser.add_argument(
        "-i",
        "--install-file",
        default=default_yaml,
        help="Yaml install file",
    )
    args = parser.parse_args()

    print(f"Using {args.install_file}")

    pkg = PackageManager(args.install_file)

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

    completer: PackageCompleter = PackageCompleter.from_nested_dict(base_cmds)
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
