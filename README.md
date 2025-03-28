# stlextractor

MATLAB package to process a large STL file containing multiple hexagonal prisms 
(the only supported form at the moment) and parse each prism, identifying its geometric
parameters such as radius, normal vector, volume etc. Each individual prism is then written
to its own STL file.

Motivation: we want to simulate packing of particles, but want to be able to assign different 
properties to each hexagon. This package allows you treat each STL file separately, by importing them 
in simulation software for instance.

## Installation

- Clone this repo to a location of choice;
- Add the folder to the MATLAB path

## Usage

See an example [Live Script](./docs/tutorials/Tutorial1_Extract.mlx) for examples of using
the package.
