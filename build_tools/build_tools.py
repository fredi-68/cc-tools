import os
from pathlib import Path
import argparse
import logging
from graphlib import TopologicalSorter
import re
import shutil

class Preprocessor():

    DIRECTIVE_RE = re.compile("--#([a-z]+?) (.+)$")

    logger = logging.getLogger("build_tools.Preprocessor")

    def __init__(self, base_directory: Path, relative_imports=True, link=False):

        self.do_link = link
        self.base_directory = base_directory
        self.tmp_directory = base_directory / "tmp"
        try:
            shutil.rmtree(self.tmp_directory)
        except OSError as e:
            pass
        self.relative_imports = relative_imports

        self.dependencies = TopologicalSorter({})
        self.visited = set()
        self.current_path = self.base_directory

        self.handlers = {"import": self._parse_import}

    def _parse_import(self, args):

        p = Path(args.strip("\"'"))
        if not p.is_absolute():
            if not self.relative_imports:
                self.logger.warning("Attempting relative import of '%s' but --relative-imports was not passed. Continuing anyway.", p)
            else:
                #try to figure out where we are
                relative_path = self.current_path.parent / p
                if not relative_path.exists():
                    self.logger.error("Attempting relative import of '%s': File could not be found (path resolved to: %s).", p, relative_path)
                else:
                    #rewrite to correct absolute pathlib
                    try:
                        p = (relative_path.resolve().relative_to(self.base_directory.absolute()))
                    except ValueError as e:
                        self.logger.error("Attempting relative import of '%s': %s (path resolved to: %s).", p, str(e), relative_path)
            self.dependencies.add(self.current_path.relative_to(self.base_directory), p)
            if self.do_link:
                self.logger.debug("Skipping relative import '%s' as 'link' parameter was set.", p)
                return "--#import \"%s\"" % args #do not write relative imports when linking because we will link to the same file anyways.
        
        self.logger.debug("Generated import to '%s'" % p)
        return "dofile(\"%s\")" % p

    def _parse_directives(self, line):

        m =  self.DIRECTIVE_RE.search(line)
        if m is None:
            return line
        dir = m[1]
        args = m[2]
        if not dir in self.handlers:
            self.logger.warning("Encountered unknown preprocessor directive '%s'", dir)
            return line
        return self.handlers[dir](args)

    def parse_file(self, path: Path):

        if path in self.visited:
            return

        t_path = self.tmp_directory / path
        os.makedirs(t_path.parent, exist_ok=True)

        self.current_path = path

        self.logger.debug("Parsing file '%s'...", path)
        with open(path, "r") as f:
            with open(t_path, "w") as g:
                for line in f.readlines():
                    g.write(self._parse_directives(line.rstrip("\n")))
                    g.write("\n")

        self.visited.add(path)

    def parse(self, path: Path):

        if path.is_dir():
            for p in path.iterdir():
                self.parse(p)
        else:
            self.parse_file(path)

    def link(self, name=None):

        if not self.do_link:
            self.logger.warning("Linking '%s' even though 'link' parameter was not set. This may break things.", self.base_directory)

        if name is None:
            name = "out.luac"

        self.logger.info("Linking files...")
        with open(self.base_directory / name, "w") as f:
            for p in self.dependencies.static_order():
                # if not p.is_relative_to(self.base_directory):
                #     self.logger.debug("Skipping external dependency '%s'...", p)
                #     continue
                with open(self.tmp_directory / self.base_directory / p, "r") as dep:
                    self.logger.debug("Linking '%s'...", p)
                    f.write("--[[===== BEGIN FILE %s =====]]\n\n\n" % p)
                    f.write(dep.read())
                    f.write("\n\n--[[===== END FILE =====]]\n\n")

    def cleanup(self):

        try:
            shutil.rmtree(self.tmp_directory)
        except OSError as e:
            pass

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-o", "--output", action="store", default=".")
    parser.add_argument("-s", "--startup-script", action="store", default=None)
    parser.add_argument("--relative-imports", action="store_true")
    parser.add_argument("--link", action="store_true")
    parser.add_argument("directories", nargs="+")

    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.WARNING)

    lib_paths = []
    for lib in args.directories:
        processor = Preprocessor(Path(args.output), args.relative_imports, args.link)
        processor.parse(Path(lib))
        if args.link:
            output_path = lib.replace("/", "").replace(".", "")
            processor.link(output_path)
            lib_paths.append(Path(args.output) / output_path)
        else:
            #TODO: copy from tmp to root and generate lib path entries.
            pass
        processor.cleanup()

    if args.startup_script is not None:
        logging.debug("Generating startup script...")
        with open(args.startup_script, "w") as f:
            f.write("--================================================================\n")
            f.write("-- build_tools.py Startup Script\n\n")
            f.write("-- This file was automatically generated. DO NOT EDIT.\n")
            f.write("--================================================================\n\n")
            f.write("if _apis_loaded == nil then\n")
            for i in lib_paths:
                f.write("  os.loadAPI(\"%s\")\n" % i)
            f.write("  _apis_loaded = true\n")
            f.write("end")