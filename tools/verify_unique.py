#!/usr/bin/env python3
"""Exhaust all assignments using a two-half sum join; retain multiplicities."""
import argparse
import hashlib
import json
from collections import defaultdict
from pathlib import Path


def enumerate_sums(rows, start, stop):
    sums = [(0,) * len(rows)]
    for j in range(start, stop):
        sums += [tuple(s + row[j] for s, row in zip(v, rows)) for v in sums]
    return sums


def verify(path):
    data = json.loads(path.read_text())
    rows, targets = data['rows'], tuple(data['targets'])
    assert len(rows) == len(targets) and rows
    n = len(rows[0])
    assert all(len(row) == n and all(isinstance(v, int) for v in row) for row in rows)
    assert all(isinstance(t, int) for t in targets)
    mid = n // 2
    left = defaultdict(list)
    for mask, sums in enumerate(enumerate_sums(rows, 0, mid)):
        left[sums].append(mask)
    solutions = []
    for mask, sums in enumerate(enumerate_sums(rows, mid, n)):
        wanted = tuple(t - s for t, s in zip(targets, sums))
        solutions.extend(lo | (mask << mid) for lo in left.get(wanted, []))
    solutions.sort()
    assert all(tuple(sum(c * ((x >> j) & 1) for j, c in enumerate(row)) for row in rows) == targets for x in solutions)
    print(f'instance_sha256: {hashlib.sha256(path.read_bytes()).hexdigest()}')
    print(f'assignments_covered: {1 << n}')
    print(f'solutions: {len(solutions)}')
    for x in solutions:
        print(f'solution: 0x{x:08x}')
    return solutions


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('instance', type=Path)
    args = parser.parse_args()
    verify(args.instance)
