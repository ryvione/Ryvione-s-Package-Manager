// Copyright (c) 2026 Ryvione. All rights reserved.

import { fetchKitList } from "../registry.js";
import { getInstalledKits } from "../state.js";
import { spinner, color, printKitRow } from "../utils/ui.js";

export async function search(args) {
  const query = args.join(" ").toLowerCase().trim();
  const spin = spinner("Fetching kit list from registry...");

  let kitList;
  try {
    kitList = await fetchKitList();
    spin.succeed("Registry fetched");
  } catch (err) {
    spin.fail(`Registry error: ${err.message}`);
    process.exit(1);
  }

  const installed = getInstalledKits();

  const results = query
    ? kitList.filter(
        (kit) =>
          kit.name.toLowerCase().includes(query) ||
          (kit.description || "").toLowerCase().includes(query) ||
          (kit.tags || []).some((t) => t.toLowerCase().includes(query))
      )
    : kitList;

  if (results.length === 0) {
    console.log(
      `\n${color("→", "gray")} No kits found${query ? ` matching "${query}"` : ""}.\n`
    );
    return;
  }

  const header = query
    ? `\n${color("Search Results", "bold")} for "${color(query, "cyan")}"\n`
    : `\n${color("All Available Kits", "bold")}\n`;

  console.log(header);
  console.log(
    `  ${"KIT".padEnd(18)} ${"VERSION".padEnd(10)} ${"DESCRIPTION"}`
  );
  console.log(
    `  ${color("─".repeat(18), "gray")} ${color("─".repeat(10), "gray")} ${color("─".repeat(30), "gray")}`
  );

  for (const kit of results) {
    const suffix = installed[kit.name] ? color(" ✔", "green") : "";
    printKitRow(kit.name + suffix, kit.version, kit.description);
  }

  console.log(
    `\n  ${color(results.length + " kit(s) found", "gray")}  ${color("✔ = installed", "green")}\n`
  );
}
