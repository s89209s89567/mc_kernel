!=========================================================================================
module master_module
  implicit none
  private
  public :: do_master
contains

!-----------------------------------------------------------------------------------------
subroutine do_master()
  use mpi
  use master_slave_parameters
  use work_type_mod
  use master_queue

  integer               :: nslaves, rank, ierror
  integer, allocatable  :: output(:,:), sendrequest(:), work_done(:)
  integer               :: mpistatus(MPI_STATUS_SIZE)
  integer               :: itask, ntasks, ioutput
  character(len=64)     :: fmtstring

  call init_queue(ntasks)

  allocate(output(ntasks,2))
  output = -1
  
  ! Find out how many processes there are in the default communicator
  call MPI_COMM_SIZE(MPI_COMM_WORLD, nslaves, ierror)
  nslaves = nslaves - 1 ! the master does not work
  allocate(sendrequest(nslaves))

  ! Format string for plotting status of slaves
  allocate(work_done(nslaves))
  work_done = 0
  write(fmtstring,"('(',I3,'('' '', I5),'' | '' F7.3''%'')')") nslaves + 1

  if (nslaves > ntasks) then
     write(6,*) 'ERROR: more slaves then tasks'
     stop
  elseif (nslaves < 1) then
     write(6,*) 'ERROR: need at least 1 slave'
     stop
  endif

 

  itask = 0
  ! Seed the slaves; send one unit of work to each slave.
  do rank=1, nslaves

     ! Find the next item of work to do
     itask = itask + 1

     ! fill sendbuffer
     call get_next_task(itask)

     ! Send it to each rank (blocking)
     call MPI_Send(wt,                & ! message buffer
                   1,                 & ! one data item
                   wt%mpitype,        & ! data item is an integer
                   rank,              & ! destination process rank
                   WORKTAG,           & ! user chosen message tag
                   MPI_COMM_WORLD,    & ! default communicator
                   sendrequest(rank), &
                   ierror)
  enddo

  ! Loop over tasks until there is no more work to be done
  ioutput = 0
  do itask=nslaves+1, ntasks

     ! Receive results from any !sic! slave (blocking!)
     ioutput = ioutput + 1
     call MPI_Recv(wt,               & ! message buffer
                   1,                & ! one data item
                   wt%mpitype,       & ! data item is an integer
                   MPI_ANY_SOURCE,   & ! receive from any sender
                   MPI_ANY_TAG,      & ! any type of message
                   MPI_COMM_WORLD,   & ! default communicator
                   mpistatus,        & ! info about the received message
                   ierror)

     call extract_receive_buffer(wt%itask)
     
     ! Plot status of slaves
     work_done(mpistatus(MPI_SOURCE)) = work_done(mpistatus(MPI_SOURCE)) + 1          
     write(6,fmtstring) work_done, sum(work_done), real(sum(work_done)) / real(ntasks) * 100.

     ! fill sendbuffer
     call get_next_task(itask)

     ! Send the same slave some more work to do (blocking)
     call MPI_Send(wt,               & ! message buffer
                   1,                & ! one data item
                   wt%mpitype,       & ! data item is an integer
                   mpistatus(MPI_SOURCE), & ! to who we just received from
                   WORKTAG,          & ! user chosen message tag
                   MPI_COMM_WORLD,   & ! default communicator
                   sendrequest(mpistatus(MPI_SOURCE)), &
                   ierror)
  enddo

  ! There's no more work to be distributed, so receive all the outstanding results 
  ! from the slaves (blocking, so when this loop is finished, work is done and
  ! results received in the buffer!).
  do rank=1, nslaves
     ioutput = ioutput + 1
     call MPI_Recv(wt,              & ! message buffer
                   1,               & ! one data item
                   wt%mpitype,      & ! data item is an integer
                   MPI_ANY_SOURCE,  & ! receive from any sender
                   MPI_ANY_TAG,     & ! any type of message
                   MPI_COMM_WORLD,  & ! default communicator
                   mpistatus,       & ! info about the received message
                   ierror)
     
     call extract_receive_buffer(wt%itask)
     
     ! Plot status of slaves
     work_done(mpistatus(MPI_SOURCE)) = work_done(mpistatus(MPI_SOURCE)) + 1          
     write(6, fmtstring) work_done, sum(work_done), real(sum(work_done)) / real(ntasks) * 100.

  enddo


  ! Tell all the slaves to exit by sending an empty message with the DIETAG.
  do rank=1, nslaves
     call MPI_Send(0,               & !
                   0,               & ! empty message
                   MPI_INTEGER,     & !
                   rank,            & ! destination
                   DIETAG,          & ! the tag conatains the actual information
                   MPI_COMM_WORLD,  & ! default communicator
                   sendrequest(rank), &
                   ierror)
  enddo

  call finalize()

end subroutine
!-----------------------------------------------------------------------------------------

end module
!=========================================================================================
