// Copyright (c) 2026 Ryvione. All rights reserved.

import { install } from "./commands/install.js";
import { remove } from "./commands/remove.js";
import { list } from "./commands/list.js";
import { update } from "./commands/update.js";
import { info } from "./commands/info.js";
import { search } from "./commands/search.js";
import { printHelp, printVersion } from "./utils/ui.js";

const [,, command, ...args] = process.argv;

const commands = {
  install,
  i: install,
  remove,
  rm: remove,
  list,
  ls: list,
  update,
  up: update,
  info,
  search,
  find: search,
  help: printHelp,
  version: printVersion,
  "--help": printHelp,
  "-h": printHelp,
  "--version": printVersion,
  "-v": printVersion,
};

if (!command || !commands[command]) {
  if (command && !commands[command]) {
    console.error(`\x1b[31mUnknown command: ${command}\x1b[0m`);
    console.error(`Run \x1b[36mryv help\x1b[0m to see available commands.`);
    process.exit(1);
  }
  printHelp();
} else {
  commands[command](args);
}
