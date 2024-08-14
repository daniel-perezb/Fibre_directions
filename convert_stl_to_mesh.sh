#!/bin/bash

# Specify the directory where your STL files are located
stl_dir="cutfiles/"

# Specify the directory where you want to save the mesh files
mesh_dir="cutfiles/mesh_files"

# Specify the path to the size_vertices.csv file
csv_file="cutfiles/size_vertices.csv"

# Initialize a variable to keep track of the STL file number
stl_index=1

# Loop through each line in the CSV file
while IFS= read -r targeted_num_v; do
    stl_file="${stl_dir}/file_${stl_index}.stl"
    mesh_file="${mesh_dir}/file_${stl_index}.mesh"

    if [ -f "$stl_file" ]; then
        # Calculate the adjusted targeted-num-v as a percentage out of 500,000
        

        # Run the TetWild command with the adjusted targeted-num-v
        TetWild "$stl_file" "$mesh_file" --targeted-num-v 800

        echo "Processed: $stl_file with targeted-num-v = 800"
   fi

    # Increment the STL file number
    ((stl_index++))
done < "$csv_file"

# Use a for loop to iterate through the files in the directory
for file in "$mesh_dir"/*.csv "$mesh_dir"/*.obj; do
    # Check if the file exists and is a regular file
    if [ -f "$file" ]; then
        # Remove the file
        rm "$file"
        echo "Removed: $file"
    fi
done

echo "File removal completed."

