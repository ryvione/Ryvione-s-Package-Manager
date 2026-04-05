// Copyright (c) 2026 Ryvione. All rights reserved.

const GITHUB_RAW = "https://raw.githubusercontent.com/ryvione/Ryvione-s-Package-Manager/master";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Content-Type": "application/json",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: CORS });
}

function notFound(msg = "Not found") {
  return json({ error: msg }, 404);
}

async function proxyGithub(path) {
  const url = `${GITHUB_RAW}/${path}`;
  const res = await fetch(url);
  if (!res.ok) return null;
  return res.text();
}

export default {
  async fetch(req) {
    const url = new URL(req.url);
    const path = url.pathname;

    if (req.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS });
    }

    if (path === "/kits/index.json") {
      const raw = await proxyGithub("packages/index.json");
      if (!raw) return notFound("Kit index not found");
      return new Response(raw, { headers: CORS });
    }

    const kitMeta = path.match(/^\/kits\/([a-z0-9_-]+)\/meta\.json$/);
    if (kitMeta) {
      const kit = kitMeta[1];
      const raw = await proxyGithub(`packages/${kit}/meta.json`);
      if (!raw) return notFound(`Kit "${kit}" not found`);
      return new Response(raw, { headers: CORS });
    }

    if (path === "/" || path === "") {
      return json({ name: "RPKG Registry", url: "https://pkg.ryvione.dev", status: "ok" });
    }

    return notFound();
  },
};