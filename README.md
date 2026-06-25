# chromiumbb — Chromium build, but better

Written in GNU Guile for software freedom.

A modern replacement for Chromium's `depot_tools` / `gclient` / `gn` / `ninja` toolchain.
Sibling project to [machbb](https://github.com/spivanatalie64/machbb).

## Commands

```
Usage: chromiumbb COMMAND [ARGS...]

Commands:
  sync              Fetch/patch Chromium source (replaces gclient sync)
  patch-deps        Install build dependencies (replaces install-build-deps.sh)
  configure [ARGS]  Configure build (replaces gn gen)
  build [TARGET]    Build (replaces ninja)
  clean             Clean build artifacts
  status            Show build status
```

## Requirements

- GNU Guile 3.0+
- Chromium source tree

**Maintainer:** Natalie (AcreetionOS)  
**Part of:** [AcreetionOS](https://acreetionos.org)
