// Copyright (c) 2026 Ryvione. All rights reserved.

import { fetchKitMeta } from "../registry.js";
import { isInstalled, getInstalledKits } from "../state.js";
import { spinner, color } from "../utils/ui.js";

export async function info(args) {
  const kitName = args[0];

  if (!kitName) {
    console.error(color("Error: Please specify a kit.", "red"));
    console.error(`Usage: ${color("ryv info <kit>", "cyan")}`);
    process.exit(1);
  }

  const name = kitName.toLowerCase();
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

  spin.succeed(`Found ${color(name, "cyan")}`);

  const installed = getInstalledKits();
  const localData = installed[name];
  const installedBadge = localData
    ? color(" INSTALLED ", "green") + (localData.version !== meta.version ? color(" (update available)", "yellow") : "")
    : color(" NOT INSTALLED ", "gray");

  console.log(`
${color(meta.name || name, "bold", "cyan")}  ${installedBadge}

  ${color("Description:", "bold")}  ${meta.description || "No description provided."}
  ${color("Version:", "bold")}      ${color(meta.version, "yellow")}
  ${color("Author:", "bold")}       ${meta.author || "Unknown"}
  ${color("License:", "bold")}      ${meta.license || "Unknown"}
  ${color("Tags:", "bold")}         ${(meta.tags || []).join(", ") || "None"}
  ${color("Registry:", "bold")}     https://pkg.ryvione.dev/kits/${name}
`);

  if (meta.dependencies && meta.dependencies.length > 0) {
    console.log(`  ${color("Dependencies:", "bold")}  ${meta.dependencies.join(", ")}\n`);
  }

  if (!localData) {
    console.log(`  Run ${color("ryv install " + name, "cyan")} to install this kit.\n`);
  } else if (localData.version !== meta.version) {
    console.log(`  Run ${color("ryv update " + name, "cyan")} to update from ${color(localData.version, "gray")} → ${color(meta.version, "yellow")}.\n`);
  }
}
