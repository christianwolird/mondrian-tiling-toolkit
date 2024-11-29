# This is how we import something in SageMath apparently.
# I believe this causes SageMath to "repythonize" graph_tools.
load('graph_tools.sage')


verbose = True


# I set the number of rectangles by hand.
num_rectangles = 10
if verbose:
    print('# rectangles =', num_rectangles)
    print('# vertices =', num_rectangles + 1)


for G in simple_planar_graphs(num_rectangles + 1, verbose=False):

    # If G is disconnected by 2 vertices, then it's tiling contains
    # a tiling of an interior rectangle.
    if not G.is_triconnected():
        continue
    
    # The embedding is used to compute the Kirkhoff ideal.
    G.is_planar(set_embedding=True)

    if verbose:
        print('  Graph (orientation):') 
        print('   ', G.get_embedding())
        print('  Automorphisms:')
        print('   ', G.automorphism_group())
        print('  Marked edges:')

    for orbit in edge_orbits(G):
        marked_edge = list(orbit)[0]
        if verbose:
            print('   ', marked_edge)



# TODO
# - Find components of the Kirkhoff ideal.
# - Determine which can be realized as tilings.
# - Prove new bound on Mondrian dissections.
