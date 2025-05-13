import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

import analyzeWorkLog from "./ai-analyze-work-log.js";

// path
const diff_path = resolve('./diff-files.txt');
const status_path = resolve('./file-status.txt');

const git_diff_text = await readFile(diff_path, { encoding: 'utf8' });
const git_status_text = await readFile(status_path, { encoding: 'utf8' });

// API > fetch txt files 
await analyzeWorkLog({ git_diff_text, git_status_text });