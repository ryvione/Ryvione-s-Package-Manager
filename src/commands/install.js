// Copyright (c) 2026 Ryvione. All rights reserved.

import { fetchKitMeta, getInstallScriptUrl } from "../registry.js";
import { isInstalled, recordInstall } from "../state.js";
import { runInstallScript } from "../runner.js";
import { spinner, color } from "../utils/ui.js";

export async function install(args) {
  const kitName = args[0];

  if (!kitName) {
    console.error(color("Error: Please specify a kit to install.", "red"));
    console.error(`Usage: ${color("ryv install <kit>", "cyan")}`);
    process.exit(1);
  }

  const name = kitName.toLowerCase();

  if (isInstalled(name)) {
    console.log(
      `${color("→", "yellow")} ${color(name, "cyan")} is already installed. Run ${color("ryv update " + name, "cyan")} to update.`
    );
    return;
  }

  const spin = spinner(`Fetching info for ${color(name, "cyan")}...`);

  let meta;
  try {
    meta = await fetchKitMeta(name);
  } catch (err) {
    spin.fail(`Registry error: ${err.message}`);
    process.exit(1);
  }

  if (!meta) {
    spin.fail(`Kit ${color(name, "cyan")} was not found in the registry.`);
    process.exit(1);
  }

  spin.succeed(`Found ${color(meta.name || name, "cyan")} ${color("v" + meta.version, "yellow")}`);

  const scriptUrl = getInstallScriptUrl(name, process.platform);
  const spin2 = spinner(`Installing ${color(name, "cyan")}...`);

  try {
    spin2.update(`Running install script...`);
    spin2.succeed(`Starting install script for ${color(name, "cyan")}`);
    await runInstallScript(scriptUrl);
    recordInstall(name, meta);
    console.log(`\n${color("✔", "green")} ${color(name, "cyan")} installed successfully!`);
  } catch (err) {
    console.error(`\n${color("✖", "red")} Install failed: ${err.message}`);
    process.exit(1);
  }
}
