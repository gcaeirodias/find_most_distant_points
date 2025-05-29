#!/bin/bash

# Function to select spatially distributed points from a coordinate file
select_points() {
  local input_file="$1"
  local num_points="${2:-5}"
  local output_file="${3:-selected_points.txt}"

  # Validate input
  if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found." >&2
    return 1
  fi

  # Function to calculate Euclidean distance between two points
  distance() {
    local x1="$1"
    local y1="$2"
    local x2="$3"
    local y2="$4"
    awk -v x1="$x1" -v y1="$y1" -v x2="$x2" -v y2="$y2" \
      'BEGIN {printf "%.10f\n", sqrt((x1-x2)^2 + (y1-y2)^2)}'
  }

  # Read all points into an array (handling tabs or spaces)
  local all_points=()
  while IFS=$'\t ' read -r x y _; do
    # Skip empty lines and validate numbers
    if [[ -n "$x" && -n "$y" ]]; then
      all_points+=("$x $y")
    fi
  done < "$input_file"

  local points=${#all_points[@]}

  # Check if there is have enough points
  if [ "$points" -lt "$num_points" ]; then
    echo "Error: Only $points points available, but $num_points requested." >&2
    return 1
  fi

  # Create an empty array for the selected points
  local selected_points=()

  # Find the two farthest points
  local max_dist=0
  local max_i=0
  local max_j=0
  for (( i=0; i<points; i++ )); do
    for (( j=i+1; j<points; j++ )); do
      point1=(${all_points[i]})
      point2=(${all_points[j]})
      dist=$(distance "${point1[0]}" "${point1[1]}" "${point2[0]}" "${point2[1]}")
      if (( $(echo "$dist > $max_dist" | bc -l 2>/dev/null) )); then
        max_dist=$dist
        max_i=$i
        max_j=$j
      fi
    done
  done

  # Add the two farthest points to the selected points array
  selected_points+=("$max_i")
  selected_points+=("$max_j")

  # Greedy selection of remaining points
  while [ ${#selected_points[@]} -lt "$num_points" ]; do
    local max_min_dist=0
    local next_index=-1
    for (( i=0; i<points; i++ )); do
      if [[ " ${selected_points[*]} " =~ " $i " ]]; then
        continue
      fi
      local min_dist_to_subset=1000000
      for idx in "${selected_points[@]}"; do
        point1=(${all_points[i]})
        point2=(${all_points[idx]})
        dist=$(distance "${point1[0]}" "${point1[1]}" "${point2[0]}" "${point2[1]}")
        if (( $(echo "$dist < $min_dist_to_subset" | bc -l 2>/dev/null) )); then
          min_dist_to_subset=$dist
        fi
      done

      if (( $(echo "$min_dist_to_subset > $max_min_dist" | bc -l 2>/dev/null) )); then
        max_min_dist=$min_dist_to_subset
        next_index=$i
      fi
    done
    selected_points+=("$next_index")
  done

  # Output the selected points to the specified file
  : > "$output_file"
  for idx in "${selected_points[@]}"; do
    echo "${all_points[idx]}" >> "$output_file"
  done

  echo "Selected $num_points points have been written to $output_file."
}
