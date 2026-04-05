// Copyright (c) 2026 Ryvione. All rights reserved.

const c = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  cyan: "\x1b[36m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
  magenta: "\x1b[35m",
  blue: "\x1b[34m",
  white: "\x1b[37m",
  gray: "\x1b[90m",
};

export function color(str, ...colors) {
  return colors.map((col) => c[col] || "").join("") + str + c.reset;
}

export function printHelp() {
  console.log(`
${color("RPKG", "bold", "cyan")} ${color("— Ryvione's Package Manager", "gray")}

${color("USAGE", "bold")}
  ryv <command> [kit]

${color("COMMANDS", "bold")}
  ${color("install", "cyan")} <kit>    Install a kit from the registry
  ${color("remove", "cyan")}  <kit>    Remove an installed kit
  ${color("list", "cyan")}            List all installed kits
  ${color("update", "cyan")} [kit]    Update a kit or all installed kits
  ${color("info", "cyan")}   <kit>    Show details about a kit
  ${color("search", "cyan")} <query>  Search the registry for kits
  ${color("help", "cyan")}            Show this help message
  ${color("version", "cyan")}         Show RPKG version

${color("ALIASES", "bold")}
  i  → install   rm → remove   ls → list   up → update   find → search

${color("EXAMPLES", "bold")}
  ${color("ryv install gamerkit", "dim")}
  ${color("ryv remove devkit", "dim")}
  ${color("ryv update", "dim")}
  ${color("ryv info syskit", "dim")}
  ${color("ryv search kit", "dim")}

${color("Registry:", "gray")} https://pkg.ryvione.dev
`);
}

export function printVersion() {
  import("fs").then(({ readFileSync }) => {
    const pkg = JSON.parse(
      readFileSync(new URL("../../package.json", import.meta.url), "utf8")
    );
    console.log(`${color("ryv", "cyan")} ${color(pkg.version, "bold")} — Ryvione's Package Manager`);
  });
}

const spinnerFrames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

export function spinner(text) {
  let i = 0;
  const id = setInterval(() => {
    process.stdout.write(
      `\r${color(spinnerFrames[i % spinnerFrames.length], "cyan")} ${text}   `
    );
    i++;
  }, 80);

  return {
    succeed(msg) {
      clearInterval(id);
      process.stdout.write(`\r${color("✔", "green")} ${msg}        \n`);
    },
    fail(msg) {
      clearInterval(id);
      process.stdout.write(`\r${color("✖", "red")} ${msg}        \n`);
    },
    update(msg) {
      text = msg;
    },
  };
}

export function printKitRow(name, version, description) {
  const paddedName = name.padEnd(18);
  const paddedVer = (version || "").padEnd(10);
  console.log(
    `  ${color(paddedName, "cyan")} ${color(paddedVer, "yellow")} ${color(description || "", "gray")}`
  );
}
