# Bin Directory Removal Verification

This document confirms that the legacy `bin/generate` and `bin/setup` scripts
that previously lived at the repository root remain removed. Verification was
performed by listing the repository root and confirming no `bin/` directory
exists, then querying Git for tracked files under the `bin/` path and verifying
that no entries are returned.

```bash
ls bin
```

The command above fails with `No such file or directory`, confirming there is no
`bin/` directory in the working tree.

```bash
git ls-tree HEAD bin
```

Git produces no output because the `bin` path is absent from the current commit,
demonstrating that neither `bin/generate` nor `bin/setup` are tracked in this
revision.
