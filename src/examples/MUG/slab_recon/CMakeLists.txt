install(FILES oft.in DESTINATION examples/MUG/slab_recon COMPONENT examples)
configure_file( oft.in ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
install(FILES oft_in.xml DESTINATION examples/MUG/slab_recon COMPONENT examples)
configure_file( oft_in.xml ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
install(FILES slab_gem.inp DESTINATION examples/MUG/slab_recon COMPONENT examples)
configure_file( slab_gem.inp ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
install(FILES slab_gem.t3d DESTINATION examples/MUG/slab_recon COMPONENT examples)
configure_file( slab_gem.t3d ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
install(FILES plot_recon_flux.py DESTINATION examples/MUG/slab_recon COMPONENT examples)
configure_file( plot_recon_flux.py ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
oft_add_exe( MUG_slab_recon.F90 )