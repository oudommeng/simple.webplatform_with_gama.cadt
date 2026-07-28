import fs from "node:fs/promises";

export function parseCsv(text) {
	const rows = [];
	let row = [];
	let value = "";
	let quoted = false;

	const input = text.replace(/^\uFEFF/, "");
	for (let index = 0; index < input.length; index += 1) {
		const character = input[index];

		if (character === '"') {
			if (quoted && input[index + 1] === '"') {
				value += '"';
				index += 1;
			} else {
				quoted = !quoted;
			}
		} else if (character === "," && !quoted) {
			row.push(value);
			value = "";
		} else if ((character === "\n" || character === "\r") && !quoted) {
			if (character === "\r" && input[index + 1] === "\n") {
				index += 1;
			}
			row.push(value);
			if (row.some((cell) => cell !== "")) {
				rows.push(row);
			}
			row = [];
			value = "";
		} else {
			value += character;
		}
	}

	if (value !== "" || row.length > 0) {
		row.push(value);
		rows.push(row);
	}

	if (rows.length === 0) {
		return [];
	}

	const headers = rows[0];
	return rows.slice(1).map((cells) =>
		Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? ""])),
	);
}

function escapeCsv(value) {
	const text = String(value ?? "");
	return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

export async function writeCsv(path, headers, rows) {
	const lines = [headers, ...rows.map((row) => headers.map((header) => row[header] ?? ""))];
	const csv = `${lines.map((line) => line.map(escapeCsv).join(",")).join("\n")}\n`;
	await fs.writeFile(path, csv, "utf8");
}

export async function readCsv(path) {
	return parseCsv(await fs.readFile(path, "utf8"));
}
