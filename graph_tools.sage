# Assortment of graph theoretic methods.


# Generate simple planar graphs with a particular number of edges.
# These correspond to Mondrian tilings with a particular number of rectangles.
def simple_planar_graphs(num_edges, verbose=False):

    # Because deg(v) >= 3 for each vertex, we have 2E = sum(deg(v)) >= 3V
    max_vertices = floor(2 * num_edges / 3)

    # Because 3F <= 2E and V-E+F = 2, we have V >= E/3 - 2
    min_vertices = ceil(num_edges / 3 - 2)

    if verbose:
        print('  Called simple_planar_graphs with num_edges =', num_edges)
        print('    Vertex range:', min_vertices, '<= # vertices <=', max_vertices)

    # SageMath doesn't support generating graphs with a particular number of EDGES. 
    # So instead, we generate graphs all graphs in a particular range of VERTICES,
    # filtering out graphs with the desired edge count along the way.
    for num_vertices in range(min_vertices, max_vertices + 1):
        if verbose:
            print('    Checking num_vertices =', num_vertices)

        # This is SageMath's built-in function.
        for G in graphs.planar_graphs(num_vertices):

            # We only want "simple" or "3-connected" graphs.
            if any(d < 3 for d in G.degree()):
                if verbose:
                    print('      Not simple:', G.edges(labels=False))
                continue

            # We only want graphs with a specific number of edges.
            if G.size() != num_edges:
                if verbose:
                    print('      Wrong # of edges:', G.edges(labels=False))
                continue

            if verbose:
                print('      FOUND ONE:', G.edges(labels=False))
            yield G


# Figure out how many "types" of edges the graph G has.
# Two edges are the same "type" if an automorphism moves one to the other.
# All edges of a single type are collectively called an "orbit".
# Example: Wheel graphs have two orbits: spokes and rims.

# Why do we care?...
# Mondrian tilings correspond to a simple planar graph G with a DISTINGUISHED EDGE.
# Like a "pointed space" in topology, or a "marked curve" in algebraic geometry.
# And if two edges are the same "type", their corresponding tilings are the same.
# Hence, we can avoid redundancy in our search for Mondrian tilings by checking
# only a single edge of each "type" (that is, one edge from each "orbit").

def edge_orbits(G, verbose=False):

    A = G.automorphism_group()

    if verbose:
        print('Called edge_orbits with G =', G.edges(labels=False))
        print('Aut(G) =', A)

    orbits = []

    for edge in G.edges(labels=False):

        if verbose:
            print('  Next edge:', edge)

        # Skip the edge if it's already in an orbit.
        if any(edge in orbit for orbit in orbits):
            if verbose:
                print('    In previous orbit.')
            continue

        new_orbit = set()

        for a in A:
            i = a(edge[0])
            j = a(edge[1])
            new_edge = (min(i, j), max(i, j))
            new_orbit.add(new_edge)
        
        if verbose:
            print('    New orbit:', new_orbit)

        orbits.append(new_orbit)

    return orbits
