# Bin Directory Removal Verification

This document confirms that the legacy `bin/generate` and `bin/setup` scripts no
longer live at the repository root. The verification performs two checks:
confirm that `bin/` is absent from the root, and validate that the supported
wrappers now reside under `infrastructure/bin/`.

```bash
ls bin
```

The command above fails with `No such file or directory`, confirming there is no
`bin/` directory in the working tree.

```bash
ls infrastructure/bin
```

This lists the active scripts (`generate`, `setup`, `plantweb-render`) so readers
know where to invoke the current tooling.

```bash
git ls-tree HEAD bin
```

Git produces no output because the `bin` path is absent from the current commit,
demonstrating that neither `bin/generate` nor `bin/setup` are tracked in this
revision.
