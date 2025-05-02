#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
fi

max_depth=-1
if [ "$1" = "--max_depth" ]; then
    max_depth="$2"
    shift 2
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Error: '$input_dir' not a directory"
    exit 1
fi

mkdir -p "$output_dir"

for file in $(find "$input_dir" -type f); do
    rel="${file#$input_dir/}"

    depth=$(echo "$rel" | awk -F"/" '{print NF-1}')

    if [ $max_depth -ge 0 ]; then
        if [ $depth -gt $max_depth ]; then
            if [ $max_depth -gt 0 ]; then
                prefix=$(echo "$rel" | cut -d/ -f1-$max_depth)
                target="$output_dir/$prefix"
            else
                target="$output_dir"
            fi
        else
            dname=$(dirname "$rel")
            if [ "$dname" = "." ]; then
                target="$output_dir"
            else
                target="$output_dir/$dname"
            fi
        fi
    else
        target="$output_dir"
    fi

    mkdir -p "$target"

    fname=$(basename "$rel")
    dst="$target/$fname"

    if [ -e "$dst" ]; then
        base="${fname%.*}"
        ext="${fname##*.}"
        cnt=1
        while [ -e "$target/${base}_$cnt.$ext" ]; do
            cnt=$((cnt+1))
        done
        dst="$target/${base}_$cnt.$ext"
    fi

    cp "$file" "$dst"
done
