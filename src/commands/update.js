// Copyright (c) 2026 Ryvione. All rights reserved.

import { fetchKitMeta, getInstallScriptUrl } from "../registry.js";
import { getInstalledKits, recordInstall } from "../state.js";
import { runInstallScript } from "../runner.js";
import { spinner, color } from "../utils/ui.js";

async function updateOne(name, installedData) {
  const spin = spinner(`Checking ${color(name, "cyan")}...`);

  let meta;
  try {
    meta = await fetchKitMeta(name);
  } catch (err) {
    spin.fail(`Could not reach registry for ${color(name, "cyan")}: ${err.message}`);
    return false;
  }

  if (!meta) {
    spin.fail(`${color(name, "cyan")} not found in registry`);
    return false;
  }

  if (meta.version === installedData.version) {
    spin.succeed(`${color(name, "cyan")} is already up to date ${color("v" + meta.version, "yellow")}`);
    return true;
  }

  spin.succeed(
    `Update available: ${color(name, "cyan")} ${color(installedData.version, "gray")} → ${color(meta.version, "yellow")}`
  );

  const scriptUrl = getInstallScriptUrl(name, process.platform);
  const spin2 = spinner(`Updating ${color(name, "cyan")}...`);

  try {
    spin2.succeed(`Running update for ${color(name, "cyan")}`);
    await runInstallScript(scriptUrl);
    recordInstall(name, meta);
    console.log(`${color("✔", "green")} ${color(name, "cyan")} updated to ${color("v" + meta.version, "yellow")}\n`);
    return true;
  } catch (err) {
    console.error(`${color("✖", "red")} Update failed for ${name}: ${err.message}\n`);
    return false;
  }
}

export async function update(args) {
  const kitName = args[0];
  const installed = getInstalledKits();
  const entries = Object.entries(installed);

  if (entries.length === 0) {
    console.log(`${color("→", "gray")} No kits installed to update.`);
    return;
  }

  if (kitName) {
    const name = kitName.toLowerCase();
    const data = installed[name];
    if (!data) {
      console.error(
        `${color("✖", "red")} ${color(name, "cyan")} is not installed.`
      );
      process.exit(1);
    }
    await updateOne(name, data);
  } else {
    console.log(`\n${color("Checking for updates...", "bold")}\n`);
    let updated = 0;
    for (const [name, data] of entries) {
      const ok = await updateOne(name, data);
      if (ok) updated++;
    }
    console.log(`\n${color("Done.", "green")} ${updated}/${entries.length} kits processed.\n`);
  }
}
