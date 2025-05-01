#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/input_dir /path/to/output_dir"
    exit 1
fi

input_dir="$1"
output_dir="$2"

find "$input_dir" -type f | while read -r file; do
    cp "$file" "$output_dir/$(basename "$file")"
done
