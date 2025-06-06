import { appendFile, readFile } from "node:fs/promises";
import { resolve } from "node:path";

// past result (개발일지.txt)
const year = new Date().getFullYear().toString().slice(-2)
const month = new Date().getMonth() + 1
const date = new Date().getDate()
const today = `${year}.${month}.${date}.`

const msg_path = resolve('./commit-msg.txt');
const msg = await readFile(msg_path, { encoding: 'utf8' });
await appendFile('./work-log.txt', `\n${today}\n${msg}\n`, { encoding: 'utf-8' });