# cc-tools

This repository contains a collection of libraries, scripts and tools I made for developing ComputerCraft programs.
This includes:
- a complete custom network stack (RedNet replacement) with support for assignable addresses, port multiplexing and other features
- a class utility for creating classes
- a logging library
- a framework for asynchronous programming with tasks based on coroutines
- a python script for resolving relative imports and linking multiple files into one API for easy loading during boot.

## FredNet

FredNet is a complete network stack created to replace RedNet as the network, transport and application layer protocol suite.
Like RedNet, FredNet offers ways to communicate with computers via addresses, however, these are not bound to a computer but
can instead be configured to any (virtual) host on the network. Networks can be divided into subnetwork ranges and connected
via routers. This allows for a more efficient, performant and secure networking infrastructure.

FredNet comes with a high level client/server development framework called Resource Transfer Protocol (RTP). It operates on
top of IPMC, FredNets network routing protocol and can interface with other network services to make communication between hosts
easier. RTP was designed to avoid boilerplate code but still allow to be integrated into larger applications.

### Planned features

- DHCP autoconfigure
- DNS
- ARP (for local DNS resolution mostly, since we don't really have to care about computer IDs)
- sockets

## FredIO

FredIO is an asynchronous multitasking framework built on top of Lua coroutines. Expanding on the feature set of parallel, which
it replaces, FredIO provides utilities such as task cancellation, asynchronous function composition and queueing new tasks into
running event loops. It further provides a full abstraction on the concepts of asynchronous tasks and event loops, offering a lot
more control than CCs builtin tools.

FredIO does not natively offer JS style Promise support. For a FredIO compatible implementation, see https://github.com/marnixah/cc-tools

## build_tools

The `build_and_link.sh` shell script handles the linking and deployment of the libraries in my custom source repository setup. 
It will most likely not work for other directory structures.