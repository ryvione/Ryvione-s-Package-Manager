// Copyright (c) 2026 Ryvione. All rights reserved.

import { getInstalledKits } from "../state.js";
import { color, printKitRow } from "../utils/ui.js";

export function list(_args) {
  const kits = getInstalledKits();
  const entries = Object.entries(kits);

  if (entries.length === 0) {
    console.log(`${color("→", "gray")} No kits installed yet.`);
    console.log(`   Run ${color("ryv install <kit>", "cyan")} to get started.`);
    return;
  }

  console.log(`\n${color("Installed Kits", "bold")}\n`);
  console.log(
    `  ${"KIT".padEnd(18)} ${"VERSION".padEnd(10)} ${"DESCRIPTION"}`
  );
  console.log(
    `  ${color("─".repeat(18), "gray")} ${color("─".repeat(10), "gray")} ${color("─".repeat(30), "gray")}`
  );

  for (const [name, data] of entries) {
    printKitRow(name, data.version, data.description);
  }

  console.log(`\n  ${color(entries.length + " kit(s) installed", "gray")}\n`);
}
