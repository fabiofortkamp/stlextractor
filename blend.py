# Script by Andrea Insinga

# this enables testing the top-level functions
# in environments without Blender

import bpy

import random
import array as arr
import numpy as np

def main():
    # Delete all existing mesh objects
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.object.select_by_type(type="MESH")
    bpy.ops.object.delete()


    radius = 1;
    thickness = 1;
    x = y = z = 0;

    bpy.ops.mesh.primitive_cylinder_add(
                    vertices=6,
                    radius=radius,
                    depth=thickness,
                    enter_editmode=False,
                    location=(
                        (x,y,z)
                    ),
                )

    # Get the active object (the newly created cube)
    cube = bpy.context.active_object

    # Assign a random rotation to the cube
    # cube.rotation_euler = (
    #                 random.uniform(0, 6.283185),
    #                 random.uniform(0, 6.283185),
    #                 random.uniform(0, 6.283185),
    #)

if __name__ == "__main__":
    main()
