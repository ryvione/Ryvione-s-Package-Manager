// Copyright (c) 2026 Ryvione. All rights reserved.

import { execSync } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";

async function downloadToTemp(url) {
  let res;
  try {
    res = await fetch(url);
  } catch (err) {
    throw new Error(`Network error: ${err.message}`);
  }
  if (res.status === 404) throw new Error("Install script not found in registry");
  if (!res.ok) throw new Error(`Failed to download script: HTTP ${res.status}`);

  const ext = url.endsWith(".ps1") ? ".ps1" : ".sh";
  const tmpFile = path.join(os.tmpdir(), `rpkg_install_${Date.now()}${ext}`);
  const buffer = await res.arrayBuffer();
  fs.writeFileSync(tmpFile, Buffer.from(buffer));
  return tmpFile;
}

export async function runInstallScript(scriptUrl) {
  const tmpFile = await downloadToTemp(scriptUrl);
  try {
    if (process.platform === "win32") {
      execSync(`powershell -ExecutionPolicy Bypass -File "${tmpFile}"`, { stdio: "inherit" });
    } else {
      fs.chmodSync(tmpFile, 0o755);
      execSync(`bash "${tmpFile}"`, { stdio: "inherit" });
    }
  } finally {
    fs.unlink(tmpFile, () => {});
  }
}

export async function runRemoveScript(scriptUrl) {
  const tmpFile = await downloadToTemp(scriptUrl);
  try {
    if (process.platform === "win32") {
      execSync(`powershell -ExecutionPolicy Bypass -File "${tmpFile}"`, { stdio: "inherit" });
    } else {
      fs.chmodSync(tmpFile, 0o755);
      execSync(`bash "${tmpFile}"`, { stdio: "inherit" });
    }
  } finally {
    fs.unlink(tmpFile, () => {});
  }
}
