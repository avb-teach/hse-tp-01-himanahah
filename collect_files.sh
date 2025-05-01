#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_dir output_dir"
    exit 1
fi

input_dir="$1"
output_dir="$2"

find "$input_dir" -type f | while read -r file; do
    filename=$(basename "$file")
    target="$output_dir/$filename"

    if [ -e "$target" ]; then
        n=1
        name="${filename%.*}"
        ext="${filename##*.}"

        if [ "$name" = "$filename" ]; then
            while [ -e "$output_dir/${name}${n}" ]; do
                n=$((n + 1))
            done
            filename="${name}${n}"
        else
            while [ -e "$output_dir/${name}${n}.${ext}" ]; do
                n=$((n + 1))
            done
            filename="${name}${n}.${ext}"
        fi
    fi

    cp "$file" "$output_dir/$filename"
done
