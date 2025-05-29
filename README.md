# find_most_distant_points
This is a bash function to select a set of x points that are more distant relatively to each other. This can be used for example to select a number of points that are more distant to each other in a PCA or DAPC space. 

## Usage
~~~
source find_most_distant_points.sh
find_most_distant_points [input_file] [num_to_select] [output_file]
# Example
find_most_distant_points input_file.txt 8 points.txt
~~~

## Parameters
~~~
input_file
       A tab or space separated text file with point coordinates.
       [Default: NULL]

num_to_select
       The number of most distant points to be selected from a group of points.
       [Default: 5]

output_file (optional)
       Name of the output file. If no name is provided the default name is outputed.
       [Default: selected_points.txt]
~~~

## Citation
For now cite the GitHub link.

## Contact
Send your questions, suggestions, or comments to gcaeirodias@unm.edu
