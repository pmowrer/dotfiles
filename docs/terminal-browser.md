# terminal-browser on a headless Ubuntu 24.04 workspace

This is the known-working setup for `terminal-browser` on the headless Coder
machine tested on 2026-08-25:

- Ubuntu 24.04.1 LTS
- terminal-browser v0.6.0
- Electron 43.3.0
- AppArmor 4.0.1
- no X11 or Wayland display

The machine needs three accommodations beyond the standard installer:

1. Ubuntu 24.04 calls the GTK package `libgtk-3-0t64`, not
   `libgtk-3-0` as printed by the v0.6.0 installer.
2. AppArmor is enabled by the kernel, but `securityfs` is not mounted in the
   workspace by default.
3. The headless GPU path cannot initialize EGL, so terminal-browser must use
   software rendering.

## Clean installation

Install the Electron runtime libraries and AppArmor userspace tools first:

```bash
sudo apt-get update
sudo apt-get install -y \
  apparmor \
  libnss3 \
  libgtk-3-0t64 \
  libasound2t64 \
  libgbm1
```

Expose the kernel's AppArmor control interface inside the workspace:

```bash
if ! mountpoint -q /sys/kernel/security; then
  sudo mount -t securityfs securityfs /sys/kernel/security
fi
```

Install terminal-browser:

```bash
curl -fsSL https://terminal-browser.sh/install | bash
```

Keep the bundled Chromium sandbox helper as a normal, non-setuid file. A fresh
installation already has the correct state. This repair command is only needed
if it was previously changed while troubleshooting:

```bash
sudo chown "$(id -un):$(id -gn)" \
  "$HOME/.local/share/terminal-browser/app/electron/chrome-sandbox"
sudo chmod 0755 \
  "$HOME/.local/share/terminal-browser/app/electron/chrome-sandbox"
```

Generate and load terminal-browser's AppArmor profile:

```bash
terminal-browser setup
```

`no vscode-family editors found` is harmless. It only means that setup found no
VS Code settings file to modify.

## Verify the installation

```bash
terminal-browser --version

ldd "$HOME/.local/share/terminal-browser/app/electron/electron" \
  | grep 'not found'

findmnt -t securityfs
sudo apparmor_status | grep -E 'profiles are loaded|terminal-browser'

stat -c '%U:%G %a %n' \
  "$HOME/.local/share/terminal-browser/app/electron/chrome-sandbox"
```

Expected results:

- `ldd | grep 'not found'` prints nothing.
- `securityfs` is mounted at `/sys/kernel/security`.
- AppArmor lists a generated `terminal-browser-<hash>` profile.
- `chrome-sandbox` is owned by the workspace user and has mode `755`, not
  `4755`.

## Launch and use with a coding agent

This applies to any terminal coding agent, Codex and Claude Code alike. The
split it depends on is not agent-specific: browser *control* travels over
terminal-browser's CLI and works from anywhere, while browser *rendering*
belongs to a terminal pane that speaks the Kitty graphics protocol.

The visible browser must therefore be launched from a real terminal pane that
supports that protocol, such as Ghostty or Kitty. The reliable workflow is:

1. Open a sibling terminal pane outside Herdr.
2. Launch the browser directly from that pane:

   ```bash
   TERMINAL_BROWSER_DISABLE_GPU=1 \
     terminal-browser open https://play.grafana.org/explore
   ```

3. Leave the browser pane open and ask the agent to attach to it.

An agent can find and control the directly launched browser from another
session:

```bash
terminal-browser ls --all --json
terminal-browser action --browser <browser-key> --tab <tab-id> -- snapshot
```

After taking a fresh snapshot, the agent can use the generated element
references with `click`, `fill`, and `eval`, or open another tab:

```bash
terminal-browser action --browser <browser-key> --tab <tab-id> -- click @e22
terminal-browser action --browser <browser-key> --tab <tab-id> -- fill @e56 '3'
terminal-browser new-tab --browser <browser-key> https://terminal-browser.com
```

Browser keys, tab IDs, and element references are generated at runtime and
must not be hard-coded. Agents should run terminal-browser commands with
host/escalated permission because their sandboxes can block pane detection.

### Herdr and resumed agent sessions

On this workspace, Herdr 0.8.2 creates a terminal-browser split and an agent
can successfully use `snapshot`, `click`, and `eval`, but the Herdr browser
pane renders empty. This is a terminal graphics transport problem, not a
Chromium or browser-control failure.

Treat Herdr as unsupported for the visible renderer here. Herdr can still host
the agent session that controls a browser launched from a separate
Ghostty/Kitty pane.

An agent-issued `terminal-browser open` may also report `This terminal cannot
show images` because agent commands run through a tool pipe or PTY rather than
the human terminal's real input/output stream. Launching directly from the
human terminal avoids that problem.

Browser rendering belongs to its terminal PTY, not to the agent conversation.
Resuming the same thread elsewhere does not move or recreate the visible
browser. If its pane remains open, the resumed agent session can rediscover it
with `terminal-browser ls --all --json`; otherwise, launch it again directly.

When several browser sessions exist, always select the intended `--browser`
and `--tab` explicitly.

To make software rendering the default for interactive shells, add this to the
managed Zsh configuration:

```bash
export TERMINAL_BROWSER_DISABLE_GPU=1
```

## After a workspace or machine restart

The `securityfs` mount may disappear. Mount it again before launching:

```bash
if ! mountpoint -q /sys/kernel/security; then
  sudo mount -t securityfs securityfs /sys/kernel/security
fi
```

Then verify the terminal-browser profile is loaded:

```bash
sudo apparmor_status | grep terminal-browser
```

If the profile file exists but is not loaded, reload it explicitly:

```bash
sudo apparmor_parser -r /etc/apparmor.d/terminal-browser-*
```

Finally launch with software rendering:

```bash
TERMINAL_BROWSER_DISABLE_GPU=1 \
  terminal-browser open https://terminal-browser.com
```

## Grafana smoke test

From a real Ghostty/Kitty pane, open Grafana Play's public Explore page:

```bash
TERMINAL_BROWSER_DISABLE_GPU=1 \
  terminal-browser open https://play.grafana.org/explore
```

If a visible browser is already running, the agent can add the tab with:

```bash
terminal-browser new-tab --browser <browser-key> https://play.grafana.org/explore
```

In the `-- Grafana --` test datasource, select the **Random Walk** query and
use these example values:

- Series count: `3`
- Start value: `50`
- Min: `0`
- Max: `100`
- Spread: `5`
- Noise: `1`
- Drop: `0`
- Time range: Last 1 hour

Click **Run query**. The graph legend should show `A-series`, `A-series1`, and
`A-series2`, and the table should contain three numeric series.

An agent can inspect and operate the shared browser with:

```bash
terminal-browser ls --all --json
terminal-browser action --browser <browser-key> --tab <tab-id> -- snapshot
```

Browser keys, tab IDs, and snapshot element references are generated at runtime
and must not be hard-coded.

## Troubleshooting map

| Symptom | Cause | Fix |
| --- | --- | --- |
| `libatk-1.0.so.0: cannot open shared object file` | Electron runtime libraries are absent | Install the Ubuntu packages in **Clean installation** |
| `libgtk-3-0` has no installation candidate | Ubuntu 24.04 renamed the package | Install `libgtk-3-0t64` |
| `no supported AppArmor abi` | AppArmor userspace package is absent | Install `apparmor` |
| `unable to find a suitable fs in /proc/mounts` | `securityfs` is not mounted | Mount it at `/sys/kernel/security` |
| `credentials.cc:131 ... Permission denied (13)` | The setuid helper conflicts with this kernel's AppArmor user-namespace restriction | Restore `chrome-sandbox` to user-owned mode `0755`, mount `securityfs`, and load the AppArmor profile |
| `Could not open the default X display` or EGL initialization errors | No usable headless GPU path | Launch with `TERMINAL_BROWSER_DISABLE_GPU=1` |
| `daemon did not start` | Electron exited before opening its control socket | Inspect the daemon log described below |
| `no vscode-family editors found` | No VS Code settings were discovered | Harmless; continue |
| Herdr opens a split but the pane is empty | Herdr is not displaying the browser's terminal graphics stream in this environment | Launch the visible browser directly in Ghostty/Kitty and let the agent control it from Herdr |
| The agent reports `This terminal cannot show images` | The command is running through a tool pipe or PTY that cannot answer the Kitty graphics probe | Run `terminal-browser open` directly in a graphics-capable terminal pane |
| Browser control works but nothing is visible | The browser control plane is healthy but the terminal pixel transport failed | Relaunch the visible renderer directly from Ghostty/Kitty |
| The agent controls the wrong browser after a resume | Multiple browser sessions are registered | Run `terminal-browser ls --all --json` and explicitly select `--browser` and `--tab` |

The main daemon error log is under:

```bash
tail -n 100 "$HOME"/.local/state/terminal-browser-*/logs/stderr.log
```

Do not use Chromium's `--no-sandbox` flag. The working configuration keeps
Chromium's namespace and seccomp sandboxes enabled; terminal-browser's AppArmor
profile authorizes the user namespace they require.
