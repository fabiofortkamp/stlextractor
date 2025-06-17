# stlextractor

MATLAB package to process a large STL file containing multiple hexagonal prisms 
(the only supported form at the moment) and parse each prism, identifying its geometric
parameters such as radius, axis, volume etc. 

Each individual prism can then be imported to its own STL file, or have their info
available to other MATLAB programs.

Motivation: we want to simulate packing of particles, but want to assign different 
properties to each prism. With `STLExtractor`, we can generate the packing
in a geometric modeling software, and have the library parse this purely geometric info;
the individual objects can then be part of a MATLAB project that recognizes the orientation, radius
or thickness as parameters for some other property (e.g. having all particles of given radius
have a certain mechanical strength). Alternatively, you can just use the project
to save the individual STL files and import them into a simulation software, manually setting
up different parameters.

## Installation

- Clone this repo to a location of choice;
- Add the folder to the MATLAB path

## Usage

See an example [Live Script](./docs/tutorials/Tutorial1_Extract.mlx) for examples of using
the package (you need to add the [tutorials](./docs/tutorials/) folder to the MATLAB
path for it to run correctly, or to change the current folder to this path).

## Testing

Run `runtests("tests")` in the MATLAB Command Window to run the test suite.
