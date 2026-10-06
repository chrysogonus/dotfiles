# dotfiles

Bash configuration for Ubuntu and WSL. The distro's stock `~/.bashrc` stays in
place and sources `bash/bashrc` as its last step.

```
╭─ user@host  ~/path  main *>  myproject  v22.23.2  14s  ✗1
╰─❯
```

Prompt segments appear only when they have something to say: git state, active
virtualenv, Node version near a `package.json`, duration of commands over 2s,
non-zero exit status.

## Install

```bash
git clone https://github.com/chrysogonus/dotfiles ~/workspace/dotfiles
~/workspace/dotfiles/install.sh
```

`install.sh` appends one source line to `~/.bashrc` and backs the file up
first. It is safe to re-run, and needs re-running after moving the repo.

## What is in it

- Two-line prompt with truecolor, 256-color, 8-color and plain fallbacks
- Shared history across terminals, prefix search on Up/Down
- Aliases for git, Docker, GPU monitoring and Ollama
- `venv`, automatic `.venv` activation on `cd`, `extract`, `mkcd`, `up`,
  `ftext`, `fname`, `mkproject`
- Lazy-loaded nvm, fnm and pnpm paths, PATH de-duplication
- Startup banner with kernel, GPU, memory and disk (`BASHRC_NO_BANNER=1` turns
  it off)

## Machine-specific settings

`~/.bashrc.local` is sourced last and never committed. Paths, work-only
aliases and anything private go there.

## Optional tools

Everything degrades when a tool is missing, with one exception: the fzf
integration calls `fzf --bash`, which needs fzf 0.48 or newer.

- git (`git-sh-prompt`) for the git segment
- fzf 0.48+ and ripgrep for Ctrl-R, Ctrl-T and Alt-C
- `nvidia-smi` for the GPU aliases and banner line
