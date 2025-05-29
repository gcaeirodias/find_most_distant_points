#!/bin/bash

select_points() {
  local input_file="$1"
  local num_to_select="$2"
  local output_file="${3:-selected_points.txt}"

  # Function to calculate Euclidean distance between two points
  distance() {
    local x1=$1 y1=$2 x2=$3 y2=$4
    echo "sqrt(($x1 - $x2)^2 + ($y1 - $y2)^2)" | bc -l
  }

  # Read all points into an array
  local points=()
  while IFS=$'\t' read -r x y; do
    # Check if both coordinates are numbers (including negative and decimals)
    if [[ $x =~ ^-?[0-9]+(\.[0-9]+)?$ && $y =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
      points+=("$x $y")
    else
      echo "Warning: Skipping malformed line: $x $y" >&2
    fi
  done < "$input_file"

  local num_points=${#points[@]}

  # Basic validation
  if [[ $num_points -eq 0 ]]; then
    echo "Error: No valid points found in input file." >&2
    return 1
  fi

  if [[ $num_to_select -gt $num_points ]]; then
    echo "Error: Cannot select $num_to_select points from $num_points available." >&2
    return 1
  fi

  local selected_points=()

  # Find the two farthest points
  local max_dist=0 max_i=0 max_j=1
  for (( i=0; i<num_points; i++ )); do
    for (( j=i+1; j<num_points; j++ )); do
      local point1=(${points[i]})
      local point2=(${points[j]})
      local dist=$(distance ${point1[0]} ${point1[1]} ${point2[0]} ${point2[1]})
      if (( $(echo "$dist > $max_dist" | bc -l) )); then
        max_dist=$dist
        max_i=$i
        max_j=$j
      fi
    done
  done

  selected_points+=("$max_i" "$max_j")

  # Greedy selection of remaining points
  while [[ ${#selected_points[@]} -lt $num_to_select ]]; do
    local max_min_dist=0 next_index=-1
    for (( i=0; i<num_points; i++ )); do
      if [[ " ${selected_points[@]} " =~ " $i " ]]; then
        continue
      fi
      
      local min_dist_to_subset=999999
      for idx in "${selected_points[@]}"; do
        local point1=(${points[i]})
        local point2=(${points[idx]})
        local dist=$(distance ${point1[0]} ${point1[1]} ${point2[0]} ${point2[1]})
        if (( $(echo "$dist < $min_dist_to_subset" | bc -l) )); then
          min_dist_to_subset=$dist
        fi
      done

      if (( $(echo "$min_dist_to_subset > $max_min_dist" | bc -l) )); then
        max_min_dist=$min_dist_to_subset
        next_index=$i
      fi
    done
    selected_points+=("$next_index")
  done

  # Output results
  echo "Selected Points:" > "$output_file"
  for idx in "${selected_points[@]}"; do
    echo "${points[idx]}" >> "$output_file"
  done

  echo "Successfully selected $num_to_select points to $output_file"
}

# If executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input_file> <num_points> [output_file]"
    exit 1
  fi
  select_points "$1" "$2" "$3"
fi
