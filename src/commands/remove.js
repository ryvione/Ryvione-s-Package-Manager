// Copyright (c) 2026 Ryvione. All rights reserved.

import { fetchKitMeta, getRegistryBase } from "../registry.js";
import { isInstalled, recordRemoval } from "../state.js";
import { runRemoveScript } from "../runner.js";
import { spinner, color } from "../utils/ui.js";
import https from "https";
import http from "http";

function getRemoveScriptUrl(kitName) {
  const ext = process.platform === "win32" ? "ps1" : "sh";
  return `${getRegistryBase()}/kits/${kitName}/remove.${ext}`;
}

export async function remove(args) {
  const kitName = args[0];

  if (!kitName) {
    console.error(color("Error: Please specify a kit to remove.", "red"));
    console.error(`Usage: ${color("ryv remove <kit>", "cyan")}`);
    process.exit(1);
  }

  const name = kitName.toLowerCase();

  if (!isInstalled(name)) {
    console.error(
      `${color("✖", "red")} ${color(name, "cyan")} is not installed.`
    );
    process.exit(1);
  }

  const spin = spinner(`Removing ${color(name, "cyan")}...`);

  const scriptUrl = getRemoveScriptUrl(name);

  try {
    spin.succeed(`Running remove script for ${color(name, "cyan")}`);
    await runRemoveScript(scriptUrl);
    recordRemoval(name);
    console.log(`\n${color("✔", "green")} ${color(name, "cyan")} removed successfully.`);
  } catch (err) {
    if (err.message.includes("not found")) {
      recordRemoval(name);
      console.log(
        `\n${color("✔", "green")} ${color(name, "cyan")} removed from registry (no uninstall script found).`
      );
    } else {
      console.error(`\n${color("✖", "red")} Remove failed: ${err.message}`);
      process.exit(1);
    }
  }
}
