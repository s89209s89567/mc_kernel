!=========================================================================================
program rdbm

  use readfields, only : semdata_type
  use commpi
  use global_parameters
  use source_class

  implicit none

  type(semdata_type)                  :: sem_data
  type(src_param_type)                :: source
  character(len=512)                  :: fwd_dir, bwd_dir
  character(len=4)                    :: model_param
  real(kind=dp)                       :: coordinates(3,3)
  real(kind=dp),    allocatable       :: fw_field(:,:,:)
  integer                             :: i

  verbose = 1

  write(*,*) '***************************************************************'
  write(*,*) ' Initialize and open AxiSEM wavefield files'
  write(*,*) '***************************************************************'

  fwd_dir = '/home/ex/local/src/axisem/SOLVER/50s_kernel_output'
  bwd_dir = ''

  model_param = 'vp'
  call sem_data%set_params(fwd_dir, bwd_dir, 100, model_param)
  call sem_data%open_files()
  call sem_data%read_meshes()
  call sem_data%build_kdtree()

  call source%init(90d0, 0d0, (/1d10, 1d10, 1d10, 0d0, 0d0, 0d0 /))


  allocate(fw_field(sem_data%ndumps, 1, 3))

  coordinates(:,1) = (/0d0, 0d0, 6d3/)
  coordinates(:,2) = (/0d0, 0d0, 5.9d3/)
  coordinates(:,3) = (/0d0, 0d0, 5.8d3/)

  fw_field = sem_data%load_fw_points_rdbm(coordinates, source)

  do i = 1, sem_data%ndumps
     write(111,*) fw_field(i,1,:)
  enddo

contains

!-----------------------------------------------------------------------------------------
subroutine start_clock
  !
  ! Driver routine to start the timing, using the clocks_mod module.
  !
  !-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
  use global_parameters
  use clocks_mod, only : clock_id, clocks_init
  
  implicit none
  
  character(len=8)  :: mydate
  character(len=10) :: mytime

  call date_and_time(mydate,mytime) 
  write(lu_out,11) mydate(5:6), mydate(7:8), mydate(1:4), mytime(1:2), mytime(3:4)

11 format('     Kerner started on ', A2,'/',A2,'/',A4,' at ', A2,'h ',A2,'min',/)


  call clocks_init(0)

  id_fft         = clock_id('FFT routines')
  id_fwd         = clock_id('Reading fwd field')
  id_netcdf      = clock_id(' - NetCDF routines')
  id_rotate      = clock_id(' - Rotate fields')
  id_buffer      = clock_id(' - Buffer routines')
  id_bwd         = clock_id('Reading bwd field')
  id_mc          = clock_id('Monte Carlo routines')
  id_filter_conv = clock_id('Filtering and convolution')
  id_inv_mesh    = clock_id('Inversion mesh routines')
  id_kernel      = clock_id('Kernel routines')
  id_init        = clock_id('Initialization per task')
  id_mpi         = clock_id('MPI communication with Master')

end subroutine start_clock
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine end_clock 
  !
  ! Wapper routine to end timing and display clock informations.
  !
  !-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  use global_parameters, only : lu_out
  use clocks_mod,        only : clocks_exit

  implicit none

  write(lu_out,*)
  write(lu_out,"(10x,'Summary of timing measurements:')")
  write(lu_out,*)

  call clocks_exit(0)

  write(lu_out,*)

end subroutine end_clock
!-----------------------------------------------------------------------------------------

end program
!=========================================================================================