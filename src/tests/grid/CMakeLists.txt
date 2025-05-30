if( OFT_BUILD_TESTS )
  # Quadrature tests
  oft_add_test( test_quad.F90 )
  configure_file( test_quad.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( quad_1d.tests ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( quad_2d.tests ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( quad_3d.tests ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )

  # Mapping tests
  oft_add_test( test_mapping_find.F90 )
  oft_add_test( test_mapping_jac.F90 )
  configure_file( test_mapping.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( mapping_jac.tests ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )

  # T3D tests
  oft_add_test( test_t3d.F90 )
  configure_file( test_t3d.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( cyl.inp ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( cyl.t3d ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )

  # Cubit tests
  oft_add_test( test_cubit.F90 )
  configure_file( test_cubit.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_test.3dm ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tet4_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tet4_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tet10_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tet10_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_hex8_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_hex8_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_hex27_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_hex27_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tri3_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_tri6_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_quad4_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( ref_quad9_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_test.3dm ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tet4_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tet4_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tet10_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tet10_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_hex8_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_hex8_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_hex27_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_hex27_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_cut_test.3dm ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_cut_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_cut_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_tri3_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_tri3_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_tri6_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_tri6_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_quad4_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_quad4_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_quad9_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( circle_quad9_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tri3_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tri3_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tri6_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_tri6_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_quad4_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_quad4_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_quad9_test.g ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( sphere_quad9_test.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )

  # GMSH tests
  oft_add_test( test_gmsh.F90 )
  configure_file( test_gmsh.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( cyl.mesh ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
  configure_file( cyl_gmsh.h5 ${CMAKE_CURRENT_BINARY_DIR} COPYONLY )
endif()