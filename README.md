# 🧬 De Novo Assembly Project Template

This repository provides a standardized and reproducible template for **de novo genome assembly projects**. It is designed to facilitate consistent project organization, environment management, and seamless synchronization between local machines and High-Performance Computing (HPC) environments.

---

## 📂 Project Structure

A clean, consistent directory layout is key for reproducible science. This template uses the following structure:

| Directory | Description |
| :--- | :--- |
| `analyses/` | **Execution hub.** Holds main workflow definitions (e.g., Nextflow, Snakemake) that launch the assembly and analysis pipelines. |
| `code/` | **Ad-hoc scripts.** Contains utility scripts, custom R/Python analysis scripts, and smaller, non-workflow code. |
| `data/` | **Input & Output.** Stores raw data (reads) and all generated results (contigs, alignment files, etc.). |
| `docs/` | **Documentation.** Project-specific notes, reports, lab book entries, diagrams, or detailed protocol write-ups. |
| `envs/` | **Custom Environments.** Definitions for custom software environments (e.g., Dockerfiles, Singularity recipes) if not using `pixi`. |

---

## 🛠️ Tools & Environments

This template leverages **pixi** for dependency management and command execution, ensuring your environment is fully reproducible across systems.

- **pixi:** Used to manage all project dependencies (via `pixi.toml`) and define convenient, portable tasks.
- **Git:** Essential for version control and file synchronization between your local machine and HPC.

---

## 💻 Seamless HPC Integration

This setup allows you to easily sync code and configurations between your local machine (e.g., laptop) and your HPC cluster using standard `git` and `pixi` commands.

### Initial Setup

1.  **Clone on both systems:** Use `git clone` to get the repository on both your local machine and your HPC cluster from Github.

2.  **Link your local repository to your HPC:** From your **local machine's** repository, execute one of the following commands to create a special git remote named `hpc`:

    * **Direct `git remote` command:**
        ```bash
        git remote add hpc user@cluster:/path/to/cloned/repo/on/hpc
        ```
    * **Using the `pixi` task:**
        ```bash
        pixi run git-link-hpc user@cluster:/path/to/cloned/repo/on/hpc
        ```

> **Tip:** If you've configured an alias for your HPC cluster in your `~/.ssh/config` file, you can replace `user@cluster` with your shorter alias (e.g., `hpc-alias`).

### Synchronization

Once linked, you can use standard Git commands and `pixi` tasks to move data and code.

-   To **fetch** remote changes (e.g., results generated on the HPC):
    ```bash
    git fetch hpc
    ```
-   For simplified syncing (see `pixi.toml` for task details):
    ```bash
    pixi run sync-to-hpc  # e.g., to push local data to the cluster
    pixi run fetch-report # e.g., to pull results from the cluster
    ```

Check the `pixi.toml` file to see how the `hpc` remote is used in these custom tasks.
