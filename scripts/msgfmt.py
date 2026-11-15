#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Minimal .po -> .mo compiler (no plurals), so building doesn't require gettext."""
import ast
import struct
import sys


def parse(path):
    entries, cur, field = {}, {}, None

    def flush():
        if "msgid" in cur and cur.get("msgstr"):
            key = cur["msgid"]
            if "msgctxt" in cur:
                key = cur["msgctxt"] + "\x04" + key
            entries[key] = cur["msgstr"]

    for raw in open(path, encoding="utf-8"):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith(("msgctxt ", "msgid ", "msgstr ")):
            kw, rest = line.split(" ", 1)
            if kw in ("msgctxt", "msgid") and "msgstr" in cur:
                flush()
                cur = {}
            field = kw
            cur[field] = ast.literal_eval(rest)
        elif line.startswith('"') and field:
            cur[field] += ast.literal_eval(line)
    flush()
    # the header (msgid "") must be kept
    return entries


def write_mo(entries, path):
    keys = sorted(entries)
    ids = b"".join(k.encode() + b"\0" for k in keys)
    strs = b"".join(entries[k].encode() + b"\0" for k in keys)
    n = len(keys)
    key_start = 7 * 4 + 16 * n
    val_start = key_start + len(ids)
    koffsets, voffsets, ko, vo = [], [], 0, 0
    for k in keys:
        kb, vb = k.encode(), entries[k].encode()
        koffsets += [len(kb), key_start + ko]
        voffsets += [len(vb), val_start + vo]
        ko += len(kb) + 1
        vo += len(vb) + 1
    header = struct.pack("Iiiiiii", 0x950412DE, 0, n, 7 * 4, 7 * 4 + 8 * n, 0, 0)
    with open(path, "wb") as f:
        f.write(header + struct.pack(f"{2 * n}i", *koffsets) + struct.pack(f"{2 * n}i", *voffsets) + ids + strs)


if __name__ == "__main__":
    po, mo = sys.argv[1], sys.argv[2]
    write_mo(parse(po), mo)
