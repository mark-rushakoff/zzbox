# zzbox

zzbox is intended to be a core collection of Unix utilities that pedantically follow
[POSIX.1-2024](https://pubs.opengroup.org/onlinepubs/9799919799/nframe.html).

What do we mean by pedantic?
For one example, check the
[Exit Status section of the specification for `false`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/false.html):

> The false utility shall always exit with a value between 1 and 125, inclusive.

Most implementations of `false` will always exit 1.
`zzbox`'s false interprets the specification literally,
and it returns a random value in that range.

## How do I use it?

Build it from source for now (`zig build` with the current `master` branch of Zig).

Use it like [BusyBox](https://www.busybox.net/)
or [toybox](https://landley.net/toybox/about.html):
if the basename matches a supported utility,
it is as though you executed that utility directly.
That is, if the `zzbox` binary is `/bin/cat`
or if `/bin/cat` is a symlink to the `zzbox` binary,
then the executable acts like `cat`.
Otherwise, the first positional argument is treated as the name of the utility to execute.

## Why?

1. I have, for a long time, thought it would be interesting to write several Unix utilities from scratch.
2. This looked like a good excuse to try out [Zig](https://ziglang.org/).

## Status

| Command | Status   | Notes                   |
|---------|----------|-------------------------|
| cat     | Partial  | No argument support yet |
| true    | Complete |                         |
| false   | Partial  | Hardcoded to exit 1     |
