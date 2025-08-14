#!/usr/bin/env bash
commands="sed tr awk grep"
for ss in $commands; do
	man "$ss"
done
