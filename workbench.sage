# I set the number of rectangles by hand.
num_rectangles = 7
print('# rectangles =', num_rectangles)

num_edges = num_rectangles + 1
print('# edges =', num_edges)

# Because deg(v) >= 3 for each vertex, we have 2E = sum(deg(v)) >= 3V
max_vertices = floor(2 * num_edges / 3)

# Because 3F <= 2E and V-E+F = 2, we have V >= E/3 - 2
min_vertices = ceil(num_edges / 3 - 2)
print('implies:', min_vertices, '<= # vertices <=', max_vertices)


for num_vertices in range(min_vertices, max_vertices + 1):
    print('Checking # vertices =', num_vertices, '...')
    for G in graphs.planar_graphs(num_vertices):

        # We only want graphs with a specific number of edges.
        if G.size() != num_edges:
            continue

        # We only want "simple" or "3-connected" graphs.
        if any(d < 3 for d in G.degree()):
            continue

        # TODO
        # - Iterate over distinguished edges.
        # - Create dual graph / embedding.
        # - Create Kirkhoff polynomials.
        # - Find components of the Kirkhoff ideal.
        # - Determine which can be realized as tilings.
        # - Prove new bound on Mondrian dissections.
