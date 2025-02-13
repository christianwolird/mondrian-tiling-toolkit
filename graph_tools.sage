# Assortment of graph theoretic methods.


def polyhedral_graphs(E, verbose=False):
    """
    Generate polyhedral graphs with exactly 'E' edges.
    These correspond to irreducible Mondrian tilings with 'E - 1' rectangles.

    SageMath doesn't support generating graphs with a fixed number of edges.
    To work around this, we generate all graphs within a specific range of vertices 
    and filter out the ones with the desired edge count.
    
    Bounds on the vertex count:
    - Upper bound: Polyhedral graphs are 3-connected, meaning every vertex 
                   has degree ≥ 3. Therefore, the sum of degrees is at least 
                   3V, and since 2E = sum(deg(v)), we have:
                     2E ≥ 3V  ⟹   V ≤ 2/3 * E
        
    - Lower bound: Planar graphs satisfy Euler’s formula V - E + F = 2.
                   Every face has at least 3 edges, and each edge is shared by 
                   two faces: 3F ≤ 2E  ⟹   F ≤ 2/3 * E
                   Substituting F = 2 - V + E:
                     3(2 - V + E) ≤ 2E  ⟹   3V ≥ E + 6  ⟹   V ≥ E/3 + 2
    """

    # Set the range of possible vertex counts.
    max_vertices = floor(2/3 * E)
    min_vertices = ceil(1/3 * E - 2)

    if verbose:
        print(f'  Called polyhedral_graphs with E = {E}')
        print(f'    Vertex range: {min_vertices} <= # vertices <= {max_vertices}')

    for num_vertices in range(min_vertices, max_vertices + 1):
        if verbose:
            print(f'    Checking num_vertices = {num_vertices}')

        # Iterate over all planar graphs with the given number of vertices.
        # This is SageMath's built-in function.
        for G in graphs.planar_graphs(num_vertices):

            # Skip graphs that aren't "simple" (i.e. have degree=2 vertices).
            if any(d < 3 for d in G.degree()):
                if verbose:
                    print(f'      Not simple: {G.edges(labels=False)}')
                continue

            # Skip graphs that don't have exactly 'E' edges.
            if G.size() != E:
                if verbose:
                    print('      Wrong # of edges: {G.edges(labels=False)}')
                continue

            # Skip non-3-connected graphs (i.e. reducible rectangulations).
            if not G.is_triconnected():
                continue

            if verbose:
                print('      Valid graph: {G.edges(labels=False)}')
            yield G


def edge_orbits(G, verbose=False):
    """
    Determine the edge orbits of a graph G.

    Two edges belong to the same "orbit" if an automorphism of the graph
    moves one edge to the other. Each orbit represents a "type" of edge.

    Example:
        In a wheel graph, there are two edge orbits: spokes and rims.

    Why this matters:
        Mondrian tilings correspond to a simple planar graph G 
        with a distinguished edge. 

        This is similar to:
            - A "pointed space" in topology
            - A "marked curve" in algebraic geometry

        If two edges are in the same orbit, their corresponding tilings are equivalent.
        To avoid redundancy, we only need to check one edge from each orbit.
    """

    # The symmetries of G.
    aut_group = G.automorphism_group()
    orbits = []

    if verbose:
        print(f"Called edge_orbits with G = {G.edges(labels=False)}")
        print(f"Aut(G) = {A}")

    for edge in G.edges(labels=False):
        if verbose:
            print('  Next edge:', edge)

        # Skip edges already assigned to an orbit.
        if any(edge in orbit for orbit in orbits):
            if verbose:
                print('    In previous orbit.')
            continue

        # Build a new orbit by applying each automorphism to the current edge.
        new_orbit = {
            tuple(sorted([a(edge[0]), a(edge[1])])) for a in aut_group
        }

        if verbose:
            print('    New orbit: {new_orbit}')

        orbits.append(new_orbit)

    return orbits


def kirchhoff_ideal(L, D, special_edge, verbose=False):
    # Input: 
    #  L = a directed graph
    #  D = the dual of L
    #  special_edge
    # Output:
    #  (vertex_polynomials, face_polynomials)

    if verbose:
        print('Running kirchoff_ideal on graph...')
        print(L.edges(labels=False))
        print('with special edge:', special_edge)
    
    variable_names = list()
    
    # Every edge besides 'e' corresponds to a rectangle.
    # So we create a variable for each, representing width.
    for edge in L.edges(labels=False):

        # Skip the special edge.
        if edge == special_edge:
            continue

        # E.g. the variable x74 represents the current from vertex 7 to vertex 4.
        variable_name = 'x' + str(edge[0]) + str(edge[1])
        variable_names.append(variable_name)

    # Create polynomial ring dynamically.
    R = PolynomialRing(QQ, variable_names)

    # Use this to look up the variable associated to each edge.
    edge_variables = dict()

    for x in R.gens():
        head = int(str(x)[2])
        tail = int(str(x)[1])

        # E.g. (1,2) points to the variable x_12.
        edge_variables[(tail, head)] = x
        # E.g. (2,1) points to -x_12.
        edge_variables[(head, tail)] = -x

    if verbose:
        print('edge_variables =', edge_variables)
        print(' ')
        print('Getting vertex polynomials...')

    vertex_polynomials = list()
    
    # The current entering each vertex equals the current exiting.
    for v in L.vertices():
    
        if verbose:
            print('v =', v)

        # The top/bottom borders of the rectangle dissection do not impose constraints.
        if v in special_edge:
            if verbose:
                print('  Skipped: in the special_edge.')
            continue

        current_sum = R(0)

        # Get adjacent edges.
        v_edges = L.incoming_edges(v, labels=False)
        # Flip the sign of outgoing edges.
        v_edges += [(e[1], e[0]) for e in L.outgoing_edges(v, labels=False)]

        # Ingoing current = outgoing current.
        for edge in v_edges:
            current_sum += edge_variables[edge]

        if verbose:
            print('current_sum =', current_sum)

        vertex_polynomials.append(current_sum)

    if verbose:
        print(' ')
        print('Getting face polynomials...')

    face_polynomials = list()

    for face in D:
        if verbose:
            print('face =', face)

        # The left/right borders of the rectangle dissection do not impose constraints.
        if special_edge in face or (special_edge[1], special_edge[0]) in face:
            if verbose:
                print('  Skipped: contained special_edge.')
            continue

        # The constraint for this face.
        voltage_sum = R(0)

        for edge in face:
            voltage_sum += 1 / edge_variables[edge]

            if verbose:
                print('  rational_sum =', voltage_sum)
        
        if verbose:
            print('  numerator =', voltage_sum.numerator())
        
        face_polynomials.append(voltage_sum.numerator())
        
    return R.ideal(vertex_polynomials + face_polynomials)
