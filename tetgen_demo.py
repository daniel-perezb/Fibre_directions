import open3d as o3d
import polyscope as ps
import numpy as np
import tetgen

def simplify_mesh(mesh, target_triangle_count):
    """
    Simplify a mesh to the target number of triangles.
    """
    mesh.simplify_quadric_decimation(target_triangle_count)
    mesh.remove_unreferenced_vertices()

if __name__ == "__main__":
    # Load the STL mesh using Open3D
    mesh = o3d.io.read_triangle_mesh('data/test2/fleece_test2_simp3.stl')  # Open3D can read .ply files as well
    mesh.compute_vertex_normals()
    # Simplify the mesh to reduce complexity
    target_triangle_count = 1000  # Adjust this value as needed
    simplify_mesh(mesh, target_triangle_count)
    # Run tetgen for tetrahedralization
    mesh_triangles = np.asarray(mesh.triangles)
    mesh_vertices = np.asarray(mesh.vertices)
    tet = tetgen.TetGen(mesh_vertices, mesh_triangles)
    #tet.make_manifold()
    tet.tetrahedralize(order=1, mindihedral=10, minratio=2.5)

    # Get the tetrahedral mesh data
    grid = tet.grid
    cells = grid.cells.reshape(-1, 5)[:, 1:]
    tet_points = grid.points
    tet_tets = cells
    tet_faces = np.concatenate((cells[:, [1, 0, 2]], cells[:, [0, 1, 3]], cells[:, [0, 3, 2]], cells[:, [1, 2, 3]]), axis=0)

    # Plot the tetrahedra with polyscope
    ps.init()
    ps.register_volume_mesh("tetrahedra", tet_points, tet_tets)
    ps_plane_1 = ps.add_scene_slice_plane()
    ps_plane_1.set_draw_plane(False)  # Render the semi-transparent gridded plane
    ps_plane_1.set_draw_widget(True)  # Use the red arrow to move the slice plane
    ps.show()

    # Save the tetrahedral mesh as an STL file
    tet_mesh = o3d.geometry.TriangleMesh()
    tet_mesh.vertices = o3d.utility.Vector3dVector(tet_points)
    tet_mesh.triangles = o3d.utility.Vector3iVector(tet_faces)
    tet_mesh.compute_vertex_normals()
    o3d.io.write_triangle_mesh("data/test2/final.stl", tet_mesh)
    print("New mesh saved")

