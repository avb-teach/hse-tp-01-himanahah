#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>  OR  $0 <input_dir> <output_dir> N" >&2
    exit 1
}

max_depth=-1
if [ "${1-}" = "--max_depth" ]; then
    if [ $# -lt 4 ]; then usage; fi
    if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: N must be a non-negative integer." >&2
        exit 1
    fi
    max_depth=$2
    shift 2
elif [ $# -eq 3 ] && [[ "$3" =~ ^[0-9]+$ ]]; then
    max_depth=$3
fi

if [ $# -ne 2 ]; then
    usage
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Error: '$input_dir' is not a directory." >&2
    exit 1
fi

mkdir -p "$output_dir"

while IFS= read -r -d '' file; do
    rel="${file#$input_dir/}"
    depth=$(grep -o "/" <<< "$rel" | wc -l)
    if [ "$max_depth" -ge 0 ]; then
        if [ "$depth" -gt "$max_depth" ]; then
            if [ "$max_depth" -gt 0 ]; then
                target_subdir=$(echo "$rel" | cut -d/ -f1-"$max_depth")
            else
                target_subdir=""
            fi
        else
            target_subdir=$(dirname "$rel")
            [ "$target_subdir" = "." ] && target_subdir=""
        fi
    else
        target_subdir=""
    fi
    dest_dir="$output_dir/$target_subdir"
    mkdir -p "$dest_dir"
    fname=$(basename "$file")
    dst="$dest_dir/$fname"
    if [ -e "$dst" ]; then
        base="${fname%.*}"
        ext="${fname##*.}"
        cnt=1
        while [ -e "$dest_dir/${base}_$cnt${ext:+.$ext}" ]; do
            cnt=$((cnt+1))
        done
        dst="$dest_dir/${base}_$cnt${ext:+.$ext}"
    fi
    cp "$file" "$dst"
done < <(find "$input_dir" -type f -print0)
