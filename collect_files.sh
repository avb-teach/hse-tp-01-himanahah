#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 input_dir output_dir [--max_depth N]"
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""

if [ "$3" == "--max_depth" ] && [ -n "$4" ]; then
    max_depth="$4"
fi

mkdir -p "$output_dir"

if [ -n "$max_depth" ]; then
    find_command=(find "$input_dir" -maxdepth "$max_depth" -type f)
else
    find_command=(find "$input_dir" -type f)
fi

while read -r file; do
    relative_path="${file#$input_dir/}"

    destination_dir="$output_dir/$(dirname "$relative_path")"

    mkdir -p "$destination_dir"

    filename=$(basename "$file")
    destination_file="$destination_dir/$filename"

    if [ -e "$destination_file" ]; then
        i=1
        name="${filename%.*}"
        ext="${filename##*.}"

        if [ "$name" = "$filename" ]; then
            while [ -e "$destination_dir/${name}${i}" ]; do
                i=$((i + 1))
            done
            filename="${name}${i}"
        else
            while [ -e "$destination_dir/${name}${i}.${ext}" ]; do
                i=$((i + 1))
            done
            filename="${name}${i}.${ext}"
        fi
        destination_file="$destination_dir/$filename"
    fi

    cp "$file" "$destination_file"
done < <("${find_command[@]}")