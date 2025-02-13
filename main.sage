load('graph_tools.sage')


num_rectangles = 10

verbose = False
rational_solutions_only = True
nondegenerate_solutions_only = True


print('# rectangles =', num_rectangles)
print('# graph edges =', num_rectangles + 1)
print(' ')
print('Potential polyhedral graphs:')


for G in polyhedral_graphs(num_rectangles + 1, verbose=False):

    # The Lexicographic orientation.
    L = DiGraph(G.edges(labels=False))

    # Fix an embedding.
    G.is_planar(set_embedding=True)

    # Take the dual: faces <-> vertices
    D = G.planar_dual()

    print(' ')
    print('Edges =', G.edges(labels=False))

    if verbose:
        print('~ Aut(G) =', G.automorphism_group().gens())
        print('~ Embedding:', G.get_embedding())
        print('~ Faces:', G.planar_dual().vertices())
    
    print('~ Battery choices:')

    for orbit in edge_orbits(G):

        special_edge = list(orbit)[0]

        kirch = kirchhoff_ideal(L, D, special_edge, verbose=False)

        print('  * Battery =', special_edge)
        if verbose:
            print('  * Kirchhoff ideal:', kirch)

        
        # Recover the variables from the ideal.
        variables = kirch.ring().gens()

        # Use these to check if any two variables are equal up to sign.
        variable_differences = [x - y for x in variables for y in variables if x != y]
        variable_sums = [x + y for x in variables for y in variables if x != y]

        found_solution = False

        # This is the computation bottleneck.
        primaries = kirch.primary_decomposition()

        # Inspect each primary ideal.
        for P in primaries:

            # The Groebner basis tells us whether our solution is rational,
            # and whether it corresponds to distinct rectangle sizes.
            grob = P.groebner_basis()

            # Skip any Groebner basis with quadratics, cubics, ...
            # I presume these correspond to irrational solutions.
            if rational_solutions_only and any(f.degree() > 1 for f in grob):
                continue

            if nondegenerate_solutions_only:
                found_zero_variable = False
                found_equal_variables = False

                # For each polynomial in the Groebner basis.
                for f in grob:
                    # For each term if f factorizes.
                    for term, power in f.factor():
                        if any(x == term for x in variables):
                            found_zero_variable = True
                            break
                        if any(d == term for d in variable_differences):
                            found_equal_variables = True
                            break
                        if any(s == term for s in variable_sums):
                            found_equal_variables = True
                            break

                # Skip rational points which yield congruent or infinite rectangles.
                if found_zero_variable or found_equal_variables:
                    continue

            # We believe we have a solution if we made it this far.
            found_solution = True
            
            # Print the Groebner basis.
            print('    > Solution:')
            for f in grob:
                print('     ', f)

        if not found_solution:
            print('    > No solutions...')

