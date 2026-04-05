# RPKG — Ryvione's Package Manager

**RPKG** is a personal cross-platform package manager that installs curated kits from the registry at [pkg.ryvione.dev](https://pkg.ryvione.dev). Packages are called **kits**.

---

## Installation

### Linux / macOS

```bash
curl -fsSL https://pkg.ryvione.dev/install.sh | bash
```

Or clone and run locally:

```bash
bash install.sh
```

### Windows (PowerShell)

```powershell
irm https://pkg.ryvione.dev/install.ps1 | iex
```

Or run locally:

```powershell
.\install.ps1
```

---

## Requirements

- Node.js v18+

---

## Commands

| Command | Alias | Description |
|---|---|---|
| `ryv install <kit>` | `ryv i` | Install a kit |
| `ryv remove <kit>` | `ryv rm` | Remove an installed kit |
| `ryv list` | `ryv ls` | List installed kits |
| `ryv update [kit]` | `ryv up` | Update one or all kits |
| `ryv info <kit>` | | Show kit details |
| `ryv search <query>` | `ryv find` | Search the registry |
| `ryv help` | `ryv -h` | Show help |
| `ryv version` | `ryv -v` | Show version |

---

## Available Kits

| Kit | Description |
|---|---|
| `devkit` | Git, curl, vim, build tools, Node.js |
| `gamerkit` | Steam, Discord, Lutris, MangoHud |
| `dotkit` | Zsh, Oh My Zsh, Powerlevel10k, Neovim |
| `syskit` | htop, tmux, bat, ripgrep, neofetch |
| `winkit` | PowerToys, Windows tweaks, essentials *(Windows only)* |

---

## Project Structure

```
RyvPACKAGEMANAGER/
├── bin/
│   └── ryv.js              # CLI entry point (shebang)
├── src/
│   ├── main.js             # Command router
│   ├── registry.js         # Registry API client
│   ├── runner.js           # Cross-platform script runner
│   ├── state.js            # Installed kits state
│   ├── commands/
│   │   ├── install.js
│   │   ├── remove.js
│   │   ├── list.js
│   │   ├── update.js
│   │   ├── info.js
│   │   └── search.js
│   └── utils/
│       └── ui.js           # Colors, spinner, formatting
├── packages/               # Kit install scripts & metadata
│   ├── devkit/
│   ├── gamerkit/
│   ├── dotkit/
│   ├── syskit/
│   └── winkit/
├── install.sh              # Linux/macOS RPKG installer
├── install.ps1             # Windows RPKG installer
└── package.json
```

---

© 2026 Ryvione. All rights reserved.
