import { copyFile, mkdir } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..");
const dist = resolve(root, "dist");

await mkdir(dist, { recursive: true });

const files = [
  [
    resolve(root, "node_modules/@astryxdesign/core/src/reset.css"),
    resolve(dist, "astryx-reset.css"),
  ],
  [
    resolve(root, "node_modules/@astryxdesign/core/dist/astryx.css"),
    resolve(dist, "astryx.css"),
  ],
  [
    resolve(root, "node_modules/@astryxdesign/theme-neutral/dist/theme.css"),
    resolve(dist, "astryx-theme.css"),
  ],
];

for (const [source, target] of files) {
  await copyFile(source, target);
  console.log(`Copied ${source} -> ${target}`);
}
