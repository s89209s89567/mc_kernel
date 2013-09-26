!=========================================================================================
module inversion_mesh

  implicit none
  private
  public :: inversion_mesh_type
  public :: inversion_mesh_data_type

  integer, parameter :: sp = 4, dp = 8

  type :: inversion_mesh_type
     private
     integer                            :: nelements, nvertices
     integer, allocatable               :: connectivity(:,:)
     real(kind=sp), allocatable         :: vertices(:,:)
     logical                            :: initialized = .false.
     contains
     procedure, pass :: get_nelements
     procedure, pass :: get_nvertices
     procedure, pass :: get_vertices
     procedure, pass :: read_tet_mesh
     procedure, pass :: dump_tet_mesh_xdmf
     procedure, pass :: freeme
  end type

  type, extends(inversion_mesh_type)    :: inversion_mesh_data_type
     private
     integer                            :: ntimes
     real(kind=sp), allocatable         :: datat(:,:)
     character(len=16), allocatable     :: data_names(:)
     contains
     procedure, pass :: get_ntimes
     procedure, pass :: init_data
     procedure, pass :: set_data_snap
     procedure, pass :: dump_tet_mesh_data_xdmf
  end type

contains

!-----------------------------------------------------------------------------------------
integer function get_nelements(this)
  class(inversion_mesh_type)        :: this
  if (.not. this%initialized) &
     stop 'ERROR: accessing inversion mesh type that is not initialized'
  get_nelements = this%nelements
end function
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
integer function get_nvertices(this)
  class(inversion_mesh_type)        :: this
  if (.not. this%initialized) &
     stop 'ERROR: accessing inversion mesh type that is not initialized'
  get_nvertices = this%nvertices
end function
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
function get_vertices(this)
  class(inversion_mesh_type)        :: this
  real(kind=sp)                     :: get_vertices(3,this%nvertices)
  if (.not. this%initialized) &
     stop 'ERROR: accessing inversion mesh type that is not initialized'
  get_vertices = this%vertices
end function
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
integer function get_ntimes(this)
  class(inversion_mesh_data_type)        :: this
  if (.not. this%initialized) &
     stop 'ERROR: accessing inversion mesh data type that is not initialized'
  get_ntimes = this%ntimes
end function
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine read_tet_mesh(this, filename_vertices, filename_connectivity)
  class(inversion_mesh_type)        :: this
  character(len=*), intent(in)      :: filename_vertices
  character(len=*), intent(in)      :: filename_connectivity
  integer                           :: iinput_vertices, iinput_connectivity
  integer                           :: i

  ! read vertices
  open(newunit=iinput_vertices, file=trim(filename_vertices), status='old', action='read')

  read(iinput_vertices,*) this%nvertices

  allocate(this%vertices(3,this%nvertices))
  do i=1, this%nvertices
     read(iinput_vertices,*) this%vertices(:,i)
  enddo

  close(iinput_vertices)

  ! read connectivity (tetrahedral elements)
  open(newunit=iinput_connectivity, file=trim(filename_connectivity), status='old', &
       action='read')

  read(iinput_connectivity,*) this%nelements

  allocate(this%connectivity(4,this%nelements))
  do i=1, this%nelements
     read(iinput_connectivity,*) this%connectivity(:,i)
  enddo

  close(iinput_connectivity)

  this%initialized = .true.
end subroutine
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine dump_tet_mesh_xdmf(this, filename)
  class(inversion_mesh_type)        :: this
  character(len=*), intent(in)      :: filename
  integer                           :: iinput_xdmf, iinput_heavy_data
  integer                           :: i

  if (.not. this%initialized) &
     stop 'ERROR: trying to dump a non initialized mesh'

  ! XML Data
  open(newunit=iinput_xdmf, file=trim(filename)//'.xdmf')
  write(iinput_xdmf, 732) this%nelements, this%nelements, 'binary', &
                      trim(filename)//'_grid.dat', this%nvertices, 'binary', &
                      trim(filename)//'_points.dat'
  close(iinput_xdmf)

732 format(&    
    '<?xml version="1.0" ?>',/&
    '<!DOCTYPE Xdmf SYSTEM "Xdmf.dtd" []>',/&
    '<Xdmf xmlns:xi="http://www.w3.org/2003/XInclude" Version="2.2">',/&
    '<Domain>',/&
    '  <Grid GridType="Uniform">',/&
    '    <Topology TopologyType="Tetrahedron" NumberOfElements="',i10,'">',/&
    '      <DataItem Dimensions="',i10,' 4" NumberType="Int" Format="',A,'">',/&
    '        ',A,/&
    '      </DataItem>',/&
    '    </Topology>',/&
    '    <Geometry GeometryType="XYZ">',/&
    '      <DataItem Dimensions="',i10,' 3" NumberType="Float" Format="',A,'">',/&
    '        ',A/&
    '      </DataItem>',/&
    '    </Geometry>',/&
    '  </Grid>',/&
    '</Domain>',/&
    '</Xdmf>')

  ! VERTEX data
  open(newunit=iinput_heavy_data, file=trim(filename)//'_points.dat', access='stream', &
      status='replace', form='unformatted', convert='little_endian')
  write(iinput_heavy_data) this%vertices
  close(iinput_heavy_data)

  ! CONNECTIVITY data
  open(newunit=iinput_heavy_data, file=trim(filename)//'_grid.dat', access='stream', &
      status='replace', form='unformatted', convert='little_endian')
  write(iinput_heavy_data) this%connectivity
  close(iinput_heavy_data)
  
end subroutine
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine freeme(this)
  class(inversion_mesh_type)        :: this

  if (allocated(this%vertices)) deallocate(this%vertices)
  if (allocated(this%connectivity)) deallocate(this%connectivity)

  select type (this)
  type is (inversion_mesh_data_type)
     if (allocated(this%datat)) deallocate(this%datat)
  end select

  this%initialized = .false.

end subroutine
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine init_data(this, ntimes)
  class(inversion_mesh_data_type)   :: this
  integer, intent(in)               :: ntimes

  this%ntimes = ntimes

  allocate(this%datat(this%nvertices, ntimes))
  this%datat = 0

  allocate(this%data_names(ntimes))
  this%data_names = 'data'

end subroutine
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine set_data_snap(this, data_snap, isnap, data_name)
  class(inversion_mesh_data_type)           :: this
  real(kind=sp), intent(in)                 :: data_snap(:)
  integer, intent(in)                       :: isnap
  character(len=*), intent(in), optional    :: data_name

  if (.not. allocated(this%datat)) &
     stop 'ERROR: trying to write data without initialization!'

  if (size(data_snap) /= this%nvertices) &
     stop 'ERROR: wrong dimensions of input data_snap for writing vertex data'

  this%datat(:,isnap) = data_snap(:)

  if (present(data_name)) &
     this%data_names(isnap) = data_name

end subroutine
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine dump_tet_mesh_data_xdmf(this, filename)
  class(inversion_mesh_data_type)   :: this
  character(len=*), intent(in)      :: filename
  integer                           :: iinput_xdmf, iinput_heavy_data
  integer                           :: i

  if (.not. this%initialized) &
     stop 'ERROR: trying to dump a non initialized mesh'

  if (.not. allocated(this%datat)) &
     stop 'ERROR: no data to dump available'

  ! XML header
  open(newunit=iinput_xdmf, file=trim(filename)//'.xdmf')
  write(iinput_xdmf, 733) this%nelements, 'binary', trim(filename)//'_grid.dat', &
                          this%nvertices, 'binary', trim(filename)//'_points.dat'

  do i=1, this%ntimes
     write(iinput_xdmf, 734) this%data_names(i), dble(i), this%nelements, &
                             "'", "'", "'", "'", this%data_names(i), &
                             this%nvertices, i-1, this%nvertices, this%ntimes, &
                             this%nvertices, trim(filename)//'_data.dat'
  enddo

  write(iinput_xdmf, 736)
  close(iinput_xdmf)

733 format(&    
    '<?xml version="1.0" ?>',/&
    '<!DOCTYPE Xdmf SYSTEM "Xdmf.dtd" []>',/&
    '<Xdmf xmlns:xi="http://www.w3.org/2003/XInclude" Version="2.2">',/&
    '<Domain>',/,/&
    '<DataItem Name="grid" Dimensions="',i10,' 4" NumberType="Int" Format="',A,'">',/&
    '  ', A,/&
    '</DataItem>',/&
    '<DataItem Name="points" Dimensions="',i10,' 3" NumberType="Float" Format="',A,'">',/&
    '  ', A,/&
    '</DataItem>',/,/&
    '<Grid Name="CellsTime" GridType="Collection" CollectionType="Temporal">',/)

734 format(&    
    '    <Grid Name="', A,'" GridType="Uniform">',/&
    '        <Time Value="',F8.2,'" />',/&
    '        <Topology TopologyType="Tetrahedron" NumberOfElements="',i10,'">',/&
    '            <DataItem Reference="/Xdmf/Domain/DataItem[@Name=', A,'grid', A,']" />',/&
    '        </Topology>',/&
    '        <Geometry GeometryType="XYZ">',/&
    '            <DataItem Reference="/Xdmf/Domain/DataItem[@Name=', A,'points', A,']" />',/&
    '        </Geometry>',/&
    '        <Attribute Name="', A,'" AttributeType="Scalar" Center="Node">',/&
    '            <DataItem ItemType="HyperSlab" Dimensions="',i10,'" Type="HyperSlab">',/&
    '                <DataItem Dimensions="3 2" Format="XML">',/&
    '                    ', i10,'          0 ',/&
    '                             1          1 ',/&
    '                             1 ', i10,/&
    '                </DataItem>',/&
    '                <DataItem Dimensions="', i10, i10, '" NumberType="Float" Format="binary">',/&
    '                   ', A,/&
    '                </DataItem>',/&
    '            </DataItem>',/&
    '        </Attribute>',/&
    '    </Grid>',/)

736 format(&    
    '</Grid>',/&
    '</Domain>',/&
    '</Xdmf>')


  ! VERTEX data
  open(newunit=iinput_heavy_data, file=trim(filename)//'_points.dat', access='stream', &
      status='replace', form='unformatted', convert='little_endian')
  write(iinput_heavy_data) this%vertices
  close(iinput_heavy_data)

  ! CONNECTIVITY data
  open(newunit=iinput_heavy_data, file=trim(filename)//'_grid.dat', access='stream', &
      status='replace', form='unformatted', convert='little_endian')
  write(iinput_heavy_data) this%connectivity
  close(iinput_heavy_data)

  ! VERTEX data
  open(newunit=iinput_heavy_data, file=trim(filename)//'_data.dat', access='stream', &
      status='replace', form='unformatted', convert='little_endian')
  do i=1, this%ntimes
     write(iinput_heavy_data) this%datat(:,i)
  enddo
  close(iinput_heavy_data)

  
end subroutine
!-----------------------------------------------------------------------------------------

end module
!=========================================================================================

!=========================================================================================
program test_inversion_mesh
  use inversion_mesh
  implicit none
  type(inversion_mesh_data_type)    :: inv_mesh

  real(kind=4), allocatable         :: datat(:,:)
  integer                           :: npoints

  !call inv_mesh%read_tet_mesh('vertices.TEST', 'facets.TEST')
  call inv_mesh%read_tet_mesh('vertices.USA10', 'facets.USA10')

  call inv_mesh%init_data(10)

  npoints = inv_mesh%get_nvertices()
  allocate(datat(3,npoints))

  datat(:,:) = inv_mesh%get_vertices()
  call inv_mesh%set_data_snap(datat(1,:), 1, 'x')
  call inv_mesh%set_data_snap(datat(2,:), 2, 'y')
  call inv_mesh%set_data_snap(datat(3,:), 3, 'z')

  call inv_mesh%dump_tet_mesh_data_xdmf('testdata')
  
  call inv_mesh%freeme()

end program
!=========================================================================================