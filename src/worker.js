// Copyright (c) 2026 Ryvione. All rights reserved.
const GITHUB_RAW = "https://raw.githubusercontent.com/ryvione/Ryvione-s-Package-Manager/master";

const CORS_JSON = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Content-Type": "application/json",
};
const CORS_PLAIN = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Content-Type": "text/plain",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: CORS_JSON });
}
function notFound(msg = "Not found") {
  return json({ error: msg }, 404);
}

async function proxyGithub(path, contentType = "text/plain") {
  const res = await fetch(`${GITHUB_RAW}/${path}`);
  if (!res.ok) return null;
  const text = await res.text();
  return new Response(text, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": contentType,
    },
  });
}

async function proxyBinary(fullUrl) {
  const res = await fetch(fullUrl);
  if (!res.ok) return null;
  return new Response(res.body, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/octet-stream",
      "Content-Disposition": `attachment; filename="${fullUrl.split("/").pop()}"`,
    },
  });
}

export default {
  async fetch(req) {
    const url = new URL(req.url);
    const path = url.pathname;

    if (req.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_JSON });
    }

    if (path === "/" || path === "") {
      return json({ name: "RPKG Registry", url: "https://pkg.ryvione.dev", status: "ok" });
    }

    if (path === "/install.sh") {
      const res = await proxyGithub("install.sh");
      if (!res) return notFound("install.sh not found");
      return res;
    }

    if (path === "/install.ps1") {
      const res = await proxyGithub("install.ps1");
      if (!res) return notFound("install.ps1 not found");
      return res;
    }

    if (path === "/kits/index.json") {
      const res = await proxyGithub("packages/index.json", "application/json");
      if (!res) return notFound("Kit index not found");
      return res;
    }

    const kitMeta = path.match(/^\/kits\/([a-z0-9_-]+)\/meta\.json$/);
    if (kitMeta) {
      const res = await proxyGithub(`packages/${kitMeta[1]}/meta.json`, "application/json");
      if (!res) return notFound(`Kit "${kitMeta[1]}" not found`);
      return res;
    }

    const kitInstallSh = path.match(/^\/kits\/([a-z0-9_-]+)\/install\.sh$/);
    if (kitInstallSh) {
      const res = await proxyGithub(`packages/${kitInstallSh[1]}/install.sh`);
      if (!res) return notFound(`install.sh for "${kitInstallSh[1]}" not found`);
      return res;
    }

    const kitInstallPs1 = path.match(/^\/kits\/([a-z0-9_-]+)\/install\.ps1$/);
    if (kitInstallPs1) {
      const res = await proxyGithub(`packages/${kitInstallPs1[1]}/install.ps1`);
      if (!res) return notFound(`install.ps1 for "${kitInstallPs1[1]}" not found`);
      return res;
    }

    const kitBin = path.match(/^\/kits\/([a-z0-9_-]+)\/bin\/(linux|macos|win)$/);
    if (kitBin) {
      const [, kit, platform] = kitBin;

      const metaRes = await fetch(`${GITHUB_RAW}/packages/${kit}/meta.json`);
      if (!metaRes.ok) return notFound(`Meta for "${kit}" not found`);
      const meta = await metaRes.json();

      const tag = meta.releaseTag;
      if (!tag) return notFound(`No releaseTag defined in meta.json for "${kit}"`);

      const filename = platform === "win" ? `${kit}-win.exe` : `${kit}-${platform}`;
      const releaseUrl = `https://github.com/ryvione/Ryvione-s-Package-Manager/releases/download/${tag}/${filename}`;

      const res = await proxyBinary(releaseUrl);
      if (!res) return notFound(`Binary for "${kit}" on ${platform} not found`);
      return res;
    }

    return notFound();
  },
};