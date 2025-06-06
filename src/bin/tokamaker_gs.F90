!------------------------------------------------------------------------------
! Flexible Unstructured Simulation Infrastructure with Open Numerics (Open FUSION Toolkit)
!
! SPDX-License-Identifier: LGPL-3.0-only
!------------------------------------------------------------------------------
!> @file tokamaker_gs.F90
!
!> @defgroup doxy_tokamaker TokaMaker
!! TokaMaker drivers for axisymmetric equilibrium modeling
!! @ingroup doxy_oft_bin
!
!> Driver program for GS equilibria
!!
!! @authors Chris Hansen
!! @date March 2014
!! @ingroup doxy_tokamaker
!------------------------------------------------------------------------------
program tokamaker_gs
USE oft_base
USE multigrid, ONLY: multigrid_mesh, multigrid_reset
USE multigrid_build, ONLY: multigrid_construct_surf
USE fem_base, ONLY: oft_afem_type, oft_ml_fem_type
USE fem_composite, ONLY: oft_ml_fem_comp_type
USE oft_la_base, ONLY: oft_vector
USE oft_lag_basis, ONLY: oft_lag_setup_bmesh, oft_scalar_bfem, oft_lag_setup
USE mhd_utils, ONLY: mu0
USE oft_gs, ONLY: gs_eq, gs_save_fields, gs_save_fgrid, gs_setup_walls, gs_save_prof, &
  gs_fixed_vflux, gs_load_regions
USE oft_gs_util, ONLY: gs_save, gs_load, gs_analyze, gs_save_eqdsk, &
  gs_profile_load
IMPLICIT NONE
#include "local.h"
INTEGER(4) :: i,ierr,io_unit,npts,iostat
REAL(8) :: theta
LOGICAL :: file_exists
REAL(8), ALLOCATABLE, DIMENSION(:,:) :: pts
TYPE(gs_eq) :: mygs
CLASS(oft_afem_type), POINTER :: lag_fem
real(r8), POINTER :: vals_tmp(:)
TYPE(multigrid_mesh) :: mg_mesh
TYPE(oft_ml_fem_type), TARGET :: ML_oft_lagrange,ML_oft_blagrange
TYPE(oft_ml_fem_comp_type), TARGET :: ML_oft_vlagrange
!---Input options
INTEGER(4) :: order = 1
INTEGER(4) :: maxits = 30
INTEGER(4) :: ninner = 4
INTEGER(4) :: mode = 0
INTEGER(4) :: eqdsk_nr = -1
INTEGER(4) :: eqdsk_nz = -1
LOGICAL :: pm = .FALSE.
REAL(8) :: urf = .3d0
REAL(8) :: nl_tol = 1.d-6
REAL(8) :: pnorm = 0.d0
REAL(8) :: alam = 0.d0
REAL(8) :: beta_mr = .3d0
REAL(8) :: f_offset = 0.d0
REAL(8) :: itor_target = -1.d0
REAL(8) :: estore_target = -1.d0
REAL(8) :: rmin = 0.d0
REAL(8) :: R0_target = -1.d0
REAL(8) :: V0_target = -1.d99
! REAL(8) :: rbounds(2) = (/-1.d99,1.d99/)
! REAL(8) :: zbounds(2) = (/-1.d99,1.d99/)
REAL(8) :: lim_zmax = 1.d99
REAL(8) :: eqdsk_rbounds(2) = (/-1.d99,1.d99/)
REAL(8) :: eqdsk_zbounds(2) = (/-1.d99,1.d99/)
REAL(8) :: eqdsk_lcfs_pad = 0.01d0
REAL(8) :: init_r0(2)=[-1.d0,0.d0]
REAL(8) :: init_a=-1.d0
REAL(8) :: init_kappa=1.d0
REAL(8) :: init_delta=0.d0
LOGICAL :: free_boundary = .FALSE.
LOGICAL :: has_plasma = .TRUE.
LOGICAL :: save_mug = .FALSE.
LOGICAL :: fast_boundary = .TRUE.
CHARACTER(LEN=OFT_PATH_SLEN) :: coil_file = 'none'
CHARACTER(LEN=OFT_PATH_SLEN) :: limiter_file = 'none'
CHARACTER(LEN=OFT_PATH_SLEN) :: eqdsk_filename = 'gTokaMaker'
CHARACTER(LEN=40) :: eqdsk_run_info = ''
CHARACTER(LEN=OFT_PATH_SLEN) :: eqdsk_limiter_file = ''
NAMELIST/tokamaker_options/order,pm,mode,maxits,ninner,urf,nl_tol,itor_target,pnorm, &
alam,beta_mr,free_boundary,coil_file,limiter_file,f_offset,has_plasma,rmin,R0_target, &
V0_target,save_mug,fast_boundary,eqdsk_filename,eqdsk_nr,eqdsk_nz,eqdsk_rbounds, &
eqdsk_zbounds,eqdsk_run_info,eqdsk_limiter_file,eqdsk_lcfs_pad,init_r0,init_a,init_kappa, &
init_delta,lim_zmax,estore_target
!------------------------------------------------------------------------------
! Initialize enviroment
!------------------------------------------------------------------------------
CALL oft_init
NULLIFY(vals_tmp)
!------------------------------------------------------------------------------
! Load settings
!------------------------------------------------------------------------------
OPEN(NEWUNIT=io_unit,FILE=oft_env%ifile)
READ(io_unit,tokamaker_options,IOSTAT=ierr)
CLOSE(io_unit)
IF(ierr<0)CALL oft_abort('No "tokamaker_options" found in input file.', &
  'tokamaker_gs',__FILE__)
IF(ierr>0)CALL oft_abort('Error parsing "tokamaker_options" in input file.', &
  'tokamaker_gs',__FILE__)
oft_env%pm=pm
!------------------------------------------------------------------------------
! Check input files
!------------------------------------------------------------------------------
IF(TRIM(coil_file)/='none')THEN
  INQUIRE(EXIST=file_exists,FILE=TRIM(coil_file))
  IF(.NOT.file_exists)CALL oft_abort('Specified "coil_file" cannot be found', &
    'tokamaker_gs', __FILE__)
END IF
IF(TRIM(limiter_file)/='none')THEN
  INQUIRE(EXIST=file_exists,FILE=TRIM(limiter_file))
  IF(.NOT.file_exists)CALL oft_abort('Specified "limiter_file" cannot be found', &
    'tokamaker_gs', __FILE__)
END IF
IF(TRIM(eqdsk_limiter_file)/='')THEN
  INQUIRE(EXIST=file_exists,FILE=TRIM(eqdsk_limiter_file))
  IF(.NOT.file_exists)CALL oft_abort('Specified "eqdsk_limiter_file" cannot be found', &
    'tokamaker_gs', __FILE__)
END IF
!------------------------------------------------------------------------------
! Setup Mesh
!------------------------------------------------------------------------------
CALL multigrid_construct_surf(mg_mesh)
CALL mygs%xdmf%setup("TokaMaker")
CALL mg_mesh%smesh%setup_io(mygs%xdmf,order)
!------------------------------------------------------------------------------
! Setup Lagrange Elements
!------------------------------------------------------------------------------
CALL oft_lag_setup(mg_mesh,order,ML_oft_lagrange,ML_oft_blagrange,ML_oft_vlagrange,-1)
CALL mygs%setup(ML_oft_blagrange)
!------------------------------------------------------------------------------
! Compute optimized smoother coefficients
!------------------------------------------------------------------------------
! CALL lag_mloptions
!------------------------------------------------------------------------------
! Setup experimental geometry
!------------------------------------------------------------------------------
! CALL exp_setup(mygs)
mygs%compute_chi=.FALSE.
mygs%free=free_boundary
mygs%lim_zmax=lim_zmax
mygs%rmin=rmin
mygs%estore_target=estore_target*mu0
IF(mygs%free)THEN
  mygs%itor_target=itor_target*mu0
  mygs%coil_file=coil_file
  CALL mygs%load_coils
ELSE
  CALL gs_load_regions(mygs)
  IF(f_offset/=0.d0)mygs%itor_target=itor_target*mu0
END IF
CALL gs_setup_walls(mygs)
!---Load isoflux targets
INQUIRE(EXIST=file_exists,FILE='gs_isoflux.in')
IF(file_exists)THEN
  OPEN(NEWUNIT=io_unit,FILE='gs_isoflux.in')
  READ(io_unit,*)mygs%isoflux_ntargets,mygs%saddle_ntargets
  ALLOCATE(mygs%isoflux_targets(2,mygs%isoflux_ntargets))
  DO i=1,mygs%isoflux_ntargets
    READ(io_unit,*)mygs%isoflux_targets(:,i)
  END DO
  ALLOCATE(mygs%saddle_targets(2,mygs%saddle_ntargets))
  DO i=1,mygs%saddle_ntargets
    READ(io_unit,*)mygs%saddle_targets(:,i)
  END DO
  CLOSE(io_unit)
  !---Read coil constraint matrix
  IF(.NOT.ASSOCIATED(mygs%coil_reg_mat))THEN
    ALLOCATE(mygs%coil_reg_mat(mygs%ncoils+1,mygs%ncoils+1))
    OPEN(NEWUNIT=io_unit,FILE='coil_reg_mat.dat')
    DO i=1,mygs%ncoils+1
      READ(io_unit,*)mygs%coil_reg_mat(i,:)
    END DO
    CLOSE(io_unit)
  END IF
END IF
!------------------------------------------------------------------------------
! Setup profiles
!------------------------------------------------------------------------------
WRITE(*,*)
WRITE(*,'(2A)')oft_indent,'*** Loading flux and pressure profiles ***'
CALL gs_profile_load('f_prof.in',mygs%I)
mygs%I%f_offset=f_offset
CALL gs_profile_load('p_prof.in',mygs%P)
!------------------------------------------------------------------------------
! Initialize GS solution
!------------------------------------------------------------------------------
WRITE(*,*)
WRITE(*,'(2A)')oft_indent,'*** Initializing GS solution ***'
INQUIRE(EXIST=file_exists,FILE='tokamaker_psi_in.rst')
CALL mygs%init()!compute=(.NOT.file_exists),r0=init_r0,a=init_a,kappa=init_kappa,delta=init_delta)
IF(file_exists)THEN
  CALL ML_oft_blagrange%current_level%vec_load(mygs%psi,'tokamaker_psi_in.rst','psi')
ELSE
  CALl mygs%init_psi(ierr,r0=init_r0,a=init_a,kappa=init_kappa,delta=init_delta)
  IF(ierr/=0)CALL oft_abort("Flux initialization failed","tokamaker_gs",__FILE__)
END IF
!------------------------------------------------------------------------------
! Compute GS solution
!------------------------------------------------------------------------------
WRITE(*,*)
WRITE(*,'(2A)')oft_indent,'*** Computing GS solution ***'
mygs%mode=mode
mygs%urf=urf
mygs%maxits=maxits
mygs%nl_tol=nl_tol
mygs%pnorm=pnorm
mygs%R0_target=R0_target
mygs%V0_target=V0_target
mygs%limiter_file=limiter_file
CALL mygs%load_limiters
IF(mygs%free)THEN
  mygs%alam=alam
ELSE
  IF(f_offset/=0.d0)mygs%alam=alam
END IF
mygs%has_plasma=has_plasma
!---Load input equilibrium
INQUIRE(EXIST=file_exists,FILE='tokamaker_gs_in.rst')
IF(file_exists)CALL gs_load(mygs,'tokamaker_gs_in.rst')
!---Set
mygs%R0_target=R0_target
mygs%V0_target=V0_target
IF(mygs%free)mygs%alam=alam
!---Solve
CALL mygs%solve
!------------------------------------------------------------------------------
! Post-solution analysis
!------------------------------------------------------------------------------
WRITE(*,*)
WRITE(*,'(2A)')oft_indent,'*** Post-solution analysis ***'
!---Equilibrium information
CALL gs_analyze(mygs)
!---Save equilibrium and flux function
CALL gs_save(mygs,'tokamaker_gs.rst')
CALL ML_oft_blagrange%current_level%vec_save(mygs%psi,'tokamaker_psi.rst','psi')
!---Save final flux profiles
CALL gs_save_prof(mygs,'gs.prof')
!---Save output grid
IF(save_mug)THEN
  CALL mg_mesh%smesh%save_to_file('gs_trans_mesh.dat')
  CALL gs_save_fgrid(mygs,'gs_trans_fields.dat')
ELSE
  CALL gs_save_fgrid(mygs)
END IF
!---Sample fields at chosen locations
INQUIRE(EXIST=file_exists,FILE='tokamaker_fields.loc')
IF(file_exists)THEN
    OPEN(NEWUNIT=io_unit,FILE='tokamaker_fields.loc')
    READ(io_unit,*)npts
    ALLOCATE(pts(2,npts))
    DO i=1,npts
      READ(io_unit,*,IOSTAT=iostat)pts(:,i)
      IF(iostat<0)CALL oft_abort('EOF reached while reading "tokamaker_fields.loc"', &
                                 'tokamaker_gs',__FILE__)
    END DO
    CLOSE(io_unit)
    CALL gs_save_fields(mygs,pts,npts,'tokamaker_fields.dat')
    DEALLOCATE(pts)
ELSE
    WRITE(*,'(2A)')oft_indent,'No "tokamaker_fields.loc" file found, skipping field output'
END IF
!---Save gEQDSK file
IF(has_plasma)THEN
  IF((eqdsk_nr>0).AND.(eqdsk_nz>0))THEN
    IF(ANY(eqdsk_rbounds<0.d0))CALL oft_abort('Invalid or unset EQDSK radial extents', &
                                              'tokamaker_gs',__FILE__)
    IF(ANY(ABS(eqdsk_zbounds)>1.d90))CALL oft_abort('Invalid or unset EQDSK vertical extents', &
                                              'tokamaker_gs',__FILE__)
    CALL gs_save_eqdsk(mygs,eqdsk_filename,eqdsk_nr,eqdsk_nz,eqdsk_rbounds,eqdsk_zbounds, &
      eqdsk_run_info,eqdsk_limiter_file,eqdsk_lcfs_pad)
  END IF
END IF
!------------------------------------------------------------------------------
! Terminate
!------------------------------------------------------------------------------
CALL oft_finalize
end program tokamaker_gs
