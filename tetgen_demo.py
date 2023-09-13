# demo for the tetgen library
# https://pypi.org/project/tetgen/

# dependencies
# pip install tetgen
# pip install polyscope
# pip install open3d



import open3d as o3d
import polyscope as ps
import numpy as np
import tetgen

if __name__=="__main__":
    # set global variables
    global num_handles, w, color_index, animation, skeleton, tet
    load_precomputed_values = True

    mesh = o3d.io.read_triangle_mesh('data/fleece_12-09-1.stl') # open3d can read .ply files as well

    # run tetgen https://pypi.org/project/tetgen/
    mesh_triangles = np.asarray(mesh.triangles)
    mesh_vertices = np.asarray(mesh.vertices)
    tet = tetgen.TetGen(mesh_vertices, mesh_triangles)
    #tet.make_manifold()
    tet.tetrahedralize(order=1, mindihedral=20, minratio=1.5)

    # get the tetrahedra faces and points
    grid = tet.grid
    cells = grid.cells.reshape(-1, 5)[:, 1:]

    # get the points of the tetrahedral mesh
    tet_points = grid.points

    # get the tetrahedrons of the tetrahedral mesh
    tet_tets = cells

    # decompose each tetrahedron into 4 triangles
    tet_faces = np.concatenate(( cells[:, [1,0,2]], cells[:, [0,1,3]], cells[:, [0, 3, 2]], cells[:, [1, 2, 3]] ) , axis =0)

    # plot the tetrahedra with polyscope
    ps.init()
    ps.register_volume_mesh("tetrahedra", tet_points, tet_tets)
    ps_plane_1 = ps.add_scene_slice_plane()
    ps_plane_1.set_draw_plane(False) # render the semi-transparent gridded plane
    ps_plane_1.set_draw_widget(True) # use the red arrow to move the slice plane
    ps.show()

    # save the tetrahedral mesh as an stl
    tet_mesh = o3d.geometry.TriangleMesh()
    tet_mesh.vertices = o3d.utility.Vector3dVector(tet_points)
    tet_mesh.triangles = o3d.utility.Vector3iVector(tet_faces)
    tet_mesh.compute_vertex_normals()
    o3d.io.write_triangle_mesh("Fleece_mesh.stl", tet_mesh)
