// Copyright (c) 2026 Ryvione. All rights reserved.

const REGISTRY_BASE = "https://pkg.ryvione.dev";
const GITHUB_RAW = "https://raw.githubusercontent.com/ryvione/Ryvione-s-Package-Manager/master";

async function fetchJSON(url) {
  let res;
  try {
    res = await fetch(url);
  } catch (err) {
    throw new Error(`Network error: ${err.message}`);
  }
  if (res.status === 404) throw new Error("NOT_FOUND");
  if (!res.ok) throw new Error(`Registry returned HTTP ${res.status}`);
  try {
    return await res.json();
  } catch {
    throw new Error("Invalid JSON from registry");
  }
}

export async function fetchKitMeta(kitName) {
  const url = `${REGISTRY_BASE}/kits/${kitName}/meta.json`;
  try {
    return await fetchJSON(url);
  } catch (err) {
    if (err.message === "NOT_FOUND") return null;
    throw err;
  }
}

export async function fetchKitList() {
  const url = `${REGISTRY_BASE}/kits/index.json`;
  return fetchJSON(url);
}

export function getInstallScriptUrl(kitName, platform) {
  const ext = platform === "win32" ? "ps1" : "sh";
  return `${GITHUB_RAW}/packages/${kitName}/install.${ext}`;
}

export function getRemoveScriptUrl(kitName) {
  const ext = process.platform === "win32" ? "ps1" : "sh";
  return `${GITHUB_RAW}/packages/${kitName}/remove.${ext}`;
}

export function getRegistryBase() {
  return REGISTRY_BASE;
}