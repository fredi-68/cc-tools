# cc-tools

This repository contains a collection of libraries, scripts and tools I made for developing ComputerCraft programs.
This includes:
- a complete custom network stack (RedNet replacement) with support for assignable addresses, port multiplexing and other features
- a custom shell (`vsh`) with support for bash-like I/O redirection
- a class utility for creating classes
- a logging library
- various smaller libraries for command line I/O (`better_tabulate`, `cli_tools`, `easy_color`, `human_readable`)
- a framework for asynchronous programming with tasks based on coroutines
- a bootloader/init system for running service/process multiplexing
- a python script for resolving relative imports and linking multiple files into one API for easy loading during boot.

## FredNet

FredNet is a complete network stack created to replace RedNet as the network, transport and application layer protocol suite.
Like RedNet, FredNet offers ways to communicate with computers via addresses, however, these are not bound to a computer but
can instead be configured to any (virtual) host on the network. Networks can be divided into subnetwork ranges and connected
via routers. This allows for a more efficient, performant and secure networking infrastructure. DHCP is supported.

FredNet comes with a high level client/server development framework called Resource Transfer Protocol (RTP). It operates on
top of IPMC, FredNets network routing protocol and can interface with other network services to make communication between hosts
easier. RTP was designed to avoid boilerplate code but still allow to be integrated into larger applications.

### Planned features

- Non-authoritative DNS answers (and potentially recursive DNS)
- ARP (for local DNS resolution mostly, since we don't really have to care about computer IDs)
- sockets

## Vastly Superior sHell (VSH)

`vsh` replaces the builtin shell by default. It provides additional features such as I/O redirection with pipes and files.
Additionally, it modifies the search path to replace many of the builtin core utility commands, such as `ls` and `cp`, to
be more in line with those commonly found on *nix systems.

### Planned features

- pluggable tab-completions similarly to the default shell
- automatic history search and completion similarly to `zsh-autosuggestions`
- additional utility program ports (coreutils etc.)

## FredIO

FredIO is an asynchronous multitasking framework built on top of Lua coroutines. Expanding on the feature set of parallel, which
it replaces, FredIO provides utilities such as task cancellation, asynchronous function composition and queueing new tasks into
running event loops. It further provides a full abstraction on the concepts of asynchronous tasks and event loops, offering a lot
more control than CCs builtin tools.

FredIO does not natively offer JS style Promise support. For a FredIO compatible implementation, see https://github.com/marnixah/cc-tools

## CCd

CCd is a simple init system which adds the ability to run multiple programs simultaneously through the use of system services.
CCd is invoked at computer boot by hijacking the initial shell program and launching a service host which loads and executes
programs defined in service modules. CCd supports starting and stopping of services on demand, dependencies between services and
automatic restarting of services. System services can be enabled at boot at the users discretion.
All service logs are written to a journal file at `/var/log/ccd/journal`, which may be inspected with `journalctl`.

### Planned features

- Circular dependency detection
- Better error handling

## build_tools

The `build_and_link.sh` shell script handles the linking and deployment of the libraries in my custom source repository setup. 
It will most likely not work for other directory structures.