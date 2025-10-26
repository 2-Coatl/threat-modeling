# Agent Instructions (Repository Root)

These guidelines apply to the entire repository unless a directory provides a
more specific `AGENTS.md` file. We keep the canonical copy at the repository
root because the instructions must sit above every path they govern; placing
this file under `.github/` or `.codex/` would scope the rules to those
directories only and leave the rest of the tree without guidance. When working
in this project:

- Follow the documented workflow in `README.md` for provisioning the Vagrant
  environment and running threat model generation commands.
- Prefer updating documentation alongside infrastructure or workflow changes so
  that the bootstrap messages and user guides stay aligned.
- Respect directory-specific `AGENTS.md` files. They override this root file for
  files contained in their scope (for example, the guidance under `bin/`).

## Why `bin/AGENTS.md` exists

The threat-model entrypoints exposed to users live in `bin/`. Keeping their
styling and delegation rules close to the scripts themselves makes it easier to
validate updates and ensures wrappers remain thin. Use the bin-specific
instructions when modifying any script inside that directory; otherwise, rely on
this repository-level guidance.

## Related guidance files

- `.github/AGENTS.md` documents expectations for GitHub workflow assets (issue
  templates, CI helpers, etc.). Those directions apply only to files beneath
  `.github/`.
- Additional directories can add their own `AGENTS.md` as needed; each one
  overrides these root rules for the files inside its scope.
