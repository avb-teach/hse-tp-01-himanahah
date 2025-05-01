#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_dir output_dir"
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth="$3"

find "$input_dir" -maxdepth "$depth" -type f | while read -r file; do
    filename=$(basename "$file")
    target="$output_dir/$filename"

    if [ -e "$target" ]; then
        i=1
        name="${filename%.*}"
        ext="${filename##*.}"

        if [ "$name" = "$filename" ]; then
            while [ -e "$output_dir/${name}${i}" ]; do
                i=$((i + 1))
            done
            filename="${name}${i}"
        else
            while [ -e "$output_dir/${name}${i}.${ext}" ]; do
                i=$((i + 1))
            done
            filename="${name}${i}.${ext}"
        fi
    fi

    cp "$file" "$output_dir/$filename"
done