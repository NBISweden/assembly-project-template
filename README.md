# De novo assembly

## Project organisation

- *analyses*: Launch workflows
- *code*: Adhoc scripts and workflows
- *data*: Workflow inputs and outputs
- *docs*: Any kind of documentation
- *envs*: Custom environments

## Working in multiple places

Use `git clone` to clone the project repository on both your laptop and the hpc from Github.

Then on your laptop, link your hpc cloned repo with your laptop like:
```bash
git remote add hpc user@cluster:/path/to/cloned/repo/on/hpc
```
OR
```bash
pixi run git-link-hpc user@cluster:/path/to/cloned/repo/on/hpc
```

If you have set up your ssh config with this information, then you can replace the
`user@cluster` with your hpc cluster alias.

This allows you to fetch or sync files using pixi tasks (which takes advantage of `git remote get-url hpc`).
See the `pixi.toml` for details.
