module data_arrays

  use global_parameters, ONLY : realkind

  implicit none

  public 

!  include 'mesh_params.h'
!  include 'mesh_params_kernel.h'

  logical                   :: do_rho,do_lam,do_mu
  logical                   :: do_vp,do_vs,do_imped

! Wavefields read from the SEM-database
  real(kind=realkind), allocatable, dimension(:) :: usrc,urec
  real(kind=realkind), allocatable, dimension(:,:) :: vsrc,vrec,vrot,vrot2
  real(kind=realkind), allocatable, dimension(:,:) :: devstrain 

! kernels
  character(len=8) :: kernmesh_type
  real(kind=4), allocatable, dimension(:) :: kernel,kern_cell
  real(kind=4), allocatable, dimension(:) :: lamkernel
  real(kind=4), allocatable, dimension(:) :: lamttkern,lamampkern
  real(kind=4), allocatable, dimension(:) :: mukernel
  real(kind=4), allocatable, dimension(:) :: muttkern,muampkern
  real(kind=4), allocatable, dimension(:) :: rhokernel
  real(kind=4), allocatable, dimension(:) :: rhottkern,rhoampkern
  real(kind=4), allocatable, dimension(:) :: vpkernel
  real(kind=4), allocatable, dimension(:) :: vpttkern,vpampkern
  real(kind=4), allocatable, dimension(:) :: vskernel
  real(kind=4), allocatable, dimension(:) :: vsttkern,vsampkern
  real(kind=4), allocatable, dimension(:) :: impkernel
  real(kind=4), allocatable, dimension(:) :: impttkern,impampkern
  real(kind=4), allocatable, dimension(:,:) :: srcmij_kern,srcloc_kern 
  complex(kind=4), allocatable, dimension(:,:) :: srcmij_kern_spec,srcloc_kern_spec 
  real(kind=4), allocatable, dimension(:) :: srcstf_kern

  double precision, allocatable, dimension(:) :: time_mean
  double precision, allocatable, dimension(:) :: usrc_time_mean
  double precision, allocatable, dimension(:) :: urec_time_mean

  real(kind=realkind), dimension(:), allocatable :: uzrec,vzrec
  real(kind=realkind) :: prefact
  logical :: readkxt,savekxt
  character(len=200) :: meshtype

! for time-frequency plots only
  complex(kind=8), allocatable, dimension(:,:,:) :: ufwd1,ubwd1

! The expensive folks: space-time/frequency arrays
  real(kind=4), allocatable, dimension(:,:) :: lamkern_kxt,mukern_kxt,rhokern_kxt
  real(kind=4), allocatable, dimension(:,:,:) :: field_phys_dim

  real(kind=8), allocatable, dimension(:,:) :: kerphys
  complex(kind=8), allocatable, dimension(:,:,:) :: ugd_src_spec,ugd_rec_spec
  complex(kind=8), allocatable, dimension(:,:) :: kerspec

  real(kind=8), allocatable, dimension(:,:) :: srckern_all_phys

! posteriori only:
  real(kind=8), allocatable, dimension(:,:) :: kern_all_phys
  complex(kind=8), allocatable, dimension(:,:) :: kern_all_spec 

end module data_arrays