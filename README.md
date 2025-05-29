# find_most_distant_pints
This is a bach function to selects a set of x points that are more distant in relation to each other. This can be used for example to select a number of points that are more distant to each other in a PCA or DAPC space. 

## Usage

~~~
source find_most_distant_points.sh
find_most_distant_points [input_file] [num_to_select] [output_file]
~~~

## Parameters
~~~
input_file
       A tab separated text file with point coordinates.
       [Default: NULL]

num_to_select
       The number of most distant points to be selected from a group of points.
       [Default: 5]

output_file (optional)
       Name of the output file. If no name is provided the default name is outputed.
       [Default: selected_points.txt]
~~~
