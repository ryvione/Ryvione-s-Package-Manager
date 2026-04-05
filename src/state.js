// Copyright (c) 2026 Ryvione. All rights reserved.

import fs from "fs";
import path from "path";
import os from "os";

function getStateDir() {
  const platform = process.platform;
  if (platform === "win32") {
    return path.join(process.env.APPDATA || os.homedir(), "rpkg");
  }
  return path.join(os.homedir(), ".local", "share", "rpkg");
}

function getStatePath() {
  return path.join(getStateDir(), "installed.json");
}

export function loadState() {
  const statePath = getStatePath();
  if (!fs.existsSync(statePath)) return { kits: {} };
  try {
    return JSON.parse(fs.readFileSync(statePath, "utf8"));
  } catch {
    return { kits: {} };
  }
}

export function saveState(state) {
  const stateDir = getStateDir();
  if (!fs.existsSync(stateDir)) {
    fs.mkdirSync(stateDir, { recursive: true });
  }
  fs.writeFileSync(getStatePath(), JSON.stringify(state, null, 2), "utf8");
}

export function isInstalled(kitName) {
  const state = loadState();
  return !!state.kits[kitName];
}

export function recordInstall(kitName, meta) {
  const state = loadState();
  state.kits[kitName] = {
    version: meta.version,
    installedAt: new Date().toISOString(),
    description: meta.description || "",
  };
  saveState(state);
}

export function recordRemoval(kitName) {
  const state = loadState();
  delete state.kits[kitName];
  saveState(state);
}

export function getInstalledKits() {
  const state = loadState();
  return state.kits;
}
