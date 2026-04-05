#!/usr/bin/env node
// Copyright (c) 2026 Ryvione. All rights reserved.

import { createRequire } from "module";
import { fileURLToPath } from "url";
import path from "path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

import("../src/main.js");
