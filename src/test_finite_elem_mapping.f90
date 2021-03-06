!******************************************************************************
!
!    This file is part of:
!    MC Kernel: Calculating seismic sensitivity kernels on unstructured meshes
!    Copyright (C) 2016 Simon Staehler, Martin van Driel, Ludwig Auer
!
!    You can find the latest version of the software at:
!    <https://www.github.com/tomography/mckernel>
!
!    MC Kernel is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    MC Kernel is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with MC Kernel. If not, see <http://www.gnu.org/licenses/>.
!
!******************************************************************************

!=========================================================================================
module test_finite_elem_mapping

   use global_parameters
   use finite_elem_mapping
   use ftnunit
   implicit none
   public

contains

!-----------------------------------------------------------------------------------------
subroutine test_inside_element()

   real(kind=dp)    :: s, z, xi, eta, xi_ref, eta_ref
   real(kind=dp)    :: nodes(4,2)
   logical          :: inside
   integer          :: element_type

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   ! spheroidal elements
   element_type = 0

   s = 1.5d0
   z = 1.5d0
   xi_ref  = 0
   eta_ref = 0
   inside = inside_element(s, z, nodes, element_type, xi, eta)
   call assert_true(inside, 'spheroidal, [1.5, 1.5]')
   
   call assert_comparable_real(1 + real(xi), 1 + real(xi_ref), &
                                 1e-7, 'speroidal, [1.5, 1.5], xi')
   call assert_comparable_real(1 + real(eta), 1 + real(xi_ref), &
                                 1e-7, 'speroidal, [1.5, 1.5], eta')

   s = .5d0
   z = .5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_false(inside, 'spheroidal, [.5, .5]')

   s = .5d0**.5d0
   z = .5d0**.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'spheroidal, [.5**2, .5**2]')

   s = .5d0**.5d0 * 3
   z = .5d0**.5d0 * 3
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'spheroidal, [.5**2, .5**2]')

   ! subpar elements
   element_type = 1

   s = 1.5d0
   z = 1.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'subpar, [1.5, 1.5]')

   s = .5d0
   z = .5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'subpar, [.5, .5]')

   s = .5d0**.5d0
   z = .5d0**.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'subpar, [.5**2, .5**2]')

   s = .5d0**.5d0 * 3
   z = .5d0**.5d0 * 3
   inside = inside_element(s, z, nodes, element_type)
   call assert_false(inside, 'subpar, [.5**2, .5**2]')

   ! semino elements
   element_type = 2

   s = 1.5d0
   z = 1.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semino, [1.5, 1.5]')

   s = .5d0
   z = .5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semino, [.5, .5]')

   s = .5d0**.5d0
   z = .5d0**.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semino, [.5**2, .5**2]')

   s = .5d0**.5d0 * 3
   z = .5d0**.5d0 * 3
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semino, [.5**2, .5**2]')

   ! semiso elements
   element_type = 3

   s = 1.5d0
   z = 1.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semiso, [1.5, 1.5]')

   s = .5d0
   z = .5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_false(inside, 'semiso, [.5, .5]')

   s = .5d0**.5d0
   z = .5d0**.5d0
   inside = inside_element(s, z, nodes, element_type)
   call assert_true(inside, 'semiso, [.5**2, .5**2]')

   s = .5d0**.5d0 * 3
   z = .5d0**.5d0 * 3
   inside = inside_element(s, z, nodes, element_type)
   call assert_false(inside, 'semiso, [.5**2, .5**2]')

end subroutine test_inside_element
!-----------------------------------------------------------------------------------------


!!!!!!! SEMI SPHEROIDAL MAPPING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!-----------------------------------------------------------------------------------------
subroutine test_mapping_semino_xieta_to_sz()
! semino: linear at bottom, curved at top

   real(kind=dp)    :: xi, eta, sz(2), sz_ref(2)
   real(kind=dp)    :: nodes(4,2)

! 4 - - - - - - - 3
! |       ^       |
! |   eta |       |
! |       |       |
! |        --->   |
! |        xi     |
! |               |
! |               |
! 1 - - - - - - - 2
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]
   
   xi = 0
   eta = 1
   sz_ref = [3 / 2**.5, 3 / 2**.5]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [0,1]')
   
   xi = 0
   eta = -1
   sz_ref = [.5, .5]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [0,-1]')
   

   xi = -1
   eta = -1
   sz_ref = [0, 1]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [-1,-1]')
   

   xi = 1
   eta = -1
   sz_ref = [1, 0]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [1,-1]')
   

   xi = 1
   eta = 1
   sz_ref = [3, 0]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [1,1]')
   

   xi = -1
   eta = 1
   sz_ref = [0, 3]
   sz = mapping_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semino element 1, [-1,1]')
   

end subroutine test_mapping_semino_xieta_to_sz
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_mapping_semino_sz_to_xieta
! semino: linear at bottom, curved at top
   real(kind=dp)    :: s, z, xieta(2), xieta_ref(2)
   real(kind=dp)    :: nodes(4,2)
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   s = 0 
   z = 1
   xieta_ref = [-1, -1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [-1,-1]')
   
   s = 0 
   z = 3
   xieta_ref = [-1, 1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [-1,1]')
   
   s = 1
   z = 0
   xieta_ref = [1, -1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [1,-1]')

   s = 3
   z = 0
   xieta_ref = [1, 1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [1,1]')
   
   s = .5
   z = .5
   xieta_ref = [0, -1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [0,0]')

   s = .5**.5 * 3.
   z = .5**.5 * 3.
   xieta_ref = [0, 1]
   xieta = inv_mapping_semino(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'inv seminoal element1, [0,0]')

end subroutine test_inv_mapping_semino_sz_to_xieta
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_jacobian_semino()
! semino: linear at bottom, curved at top

   real(kind=dp)    :: xi, eta, jacobian(2,2), jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!            | ds / dxi  ds / deta |
! jacobian = |                     |
!            | dz / dxi  dz / deta |

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = 1
   jacobian_ref(1,:) = [datan(1d0) * 3,0d0]
   jacobian_ref(2,:) = [           0d0,1d0]
   jacobian = jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semino jacobian element 1, [-1,1]')

   xi = 1
   eta = 1
   jacobian_ref(1,:) = [0d0,1d0]
   jacobian_ref(2,:) = [-datan(1d0) * 3,0d0]
   jacobian = jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semino jacobian element 1, [1,1]')
   
   xi = -1
   eta = -1
   jacobian_ref(1,:) = [0.5d0,0d0]
   jacobian_ref(2,:) = [-.5d0,1d0]
   jacobian = jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semino jacobian element 1, [-1,-1]')

   xi = 1
   eta = -1
   jacobian_ref(1,:) = [0.5d0,1d0]
   jacobian_ref(2,:) = [-.5d0,0d0]
   jacobian = jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semino jacobian element 1, [1,-1]')

end subroutine test_jacobian_semino
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_jacobian_semino()
! semino: linear at bottom, curved at top

   real(kind=dp)    :: xi, eta, inv_jacobian(2,2), inv_jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!                | dxi  / ds  dxi  / dz |
! inv_jacobian = |                      |
!                | deta / ds  deta / dz |

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = -1
   inv_jacobian_ref(1,:) = [2d0,0d0]
   inv_jacobian_ref(2,:) = [1d0,1d0]
   inv_jacobian = inv_jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semino jacobian element 1, [-1,-1]')

   xi = -1
   eta = 1
   inv_jacobian_ref(1,:) = [4d0 / 3d0 / pi,0d0]
   inv_jacobian_ref(2,:) = [           0d0,1d0]
   inv_jacobian = inv_jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semino jacobian element 1, [-1,1]')

   xi = 1
   eta = 1
   inv_jacobian_ref(1,:) = [0d0,-4d0 / 3d0 / pi ]
   inv_jacobian_ref(2,:) = [1d0,0d0]
   inv_jacobian = inv_jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semino jacobian element 1, [1,1]')

   xi = 1
   eta = -1
   inv_jacobian_ref(1,:) = [0d0,-2d0]
   inv_jacobian_ref(2,:) = [1d0, 1d0]
   inv_jacobian = inv_jacobian_semino(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semino jacobian element 1, [1,-1]')

end subroutine test_inv_jacobian_semino
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_mapping_semiso_xieta_to_sz()
! semiso: linear at top, curved at bottom

   real(kind=dp)    :: xi, eta, sz(2), sz_ref(2)
   real(kind=dp)    :: nodes(4,2)

! 4 - - - - - - - 3
! |       ^       |
! |   eta |       |
! |       |       |
! |        --->   |
! |        xi     |
! |               |
! |               |
! 1 - - - - - - - 2
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]
   
   xi = 0
   eta = 1
   sz_ref = [1.5, 1.5]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [0,1]')
   
   xi = 0
   eta = -1
   sz_ref = [.5**.5, .5**.5]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [0,-1]')
   

   xi = -1
   eta = -1
   sz_ref = [0, 1]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [-1,-1]')
   

   xi = 1
   eta = -1
   sz_ref = [1, 0]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [1,-1]')
   

   xi = 1
   eta = 1
   sz_ref = [3, 0]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [1,1]')
   

   xi = -1
   eta = 1
   sz_ref = [0, 3]
   sz = mapping_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'semiso element 1, [-1,1]')
   

end subroutine test_mapping_semiso_xieta_to_sz
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_mapping_semiso_sz_to_xieta
! semiso: linear at top, curved at bottom
   real(kind=dp)    :: s, z, xieta(2), xieta_ref(2)
   real(kind=dp)    :: nodes(4,2)
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   s = 0 
   z = 1
   xieta_ref = [-1, -1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [-1,-1]')
   
   s = 0 
   z = 3
   xieta_ref = [-1, 1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [-1,1]')
   
   s = 1
   z = 0
   xieta_ref = [1, -1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [1,-1]')

   s = 3
   z = 0
   xieta_ref = [1, 1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [1,1]')
   
   s = 1.5
   z = 1.5
   xieta_ref = [0, 1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [0,0]')

   s = .5**.5
   z = .5**.5
   xieta_ref = [0, -1]
   xieta = inv_mapping_semiso(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'inv semisoal element1, [0,0]')

end subroutine test_inv_mapping_semiso_sz_to_xieta
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_jacobian_semiso()
! semiso: linear at top, curved at bottom

   real(kind=dp)    :: xi, eta, jacobian(2,2), jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!            | ds / dxi  ds / deta |
! jacobian = |                     |
!            | dz / dxi  dz / deta |

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = 1
   jacobian_ref(1,:) = [ 1.5d0,0d0]
   jacobian_ref(2,:) = [-1.5d0,1d0]
   jacobian = jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semiso jacobian element 1, [-1,1]')

   xi = 1
   eta = 1
   jacobian_ref(1,:) = [ 1.5d0,1d0]
   jacobian_ref(2,:) = [-1.5d0,0d0]
   jacobian = jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semiso jacobian element 1, [1,1]')
   
   xi = -1
   eta = -1
   jacobian_ref(1,:) = [pi / 4d0,0d0]
   jacobian_ref(2,:) = [     0d0,1d0]
   jacobian = jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semiso jacobian element 1, [-1,-1]')

   xi = 1
   eta = -1
   jacobian_ref(1,:) = [      0d0,1d0]
   jacobian_ref(2,:) = [-pi / 4d0,0d0]
   jacobian = jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'semiso jacobian element 1, [1,-1]')

end subroutine test_jacobian_semiso
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_jacobian_semiso()
! semiso: linear at top, curved at bottom

   real(kind=dp)    :: xi, eta, inv_jacobian(2,2), inv_jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!                | dxi  / ds  dxi  / dz |
! inv_jacobian = |                      |
!                | deta / ds  deta / dz |

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = -1
   inv_jacobian_ref(1,:) = [4d0 / pi,0d0]
   inv_jacobian_ref(2,:) = [     0d0,1d0]
   inv_jacobian = inv_jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semiso jacobian element 1, [-1,-1]')

   xi = -1
   eta = 1
   inv_jacobian_ref(1,:) = [2d0 / 3d0,0d0]
   inv_jacobian_ref(2,:) = [      1d0,1d0]
   inv_jacobian = inv_jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semiso jacobian element 1, [-1,1]')

   xi = 1
   eta = 1
   inv_jacobian_ref(1,:) = [0d0,-2d0 / 3d0]
   inv_jacobian_ref(2,:) = [1d0, 1d0]
   inv_jacobian = inv_jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semiso jacobian element 1, [1,1]')

   xi = 1
   eta = -1
   inv_jacobian_ref(1,:) = [0d0,-4d0 / pi ]
   inv_jacobian_ref(2,:) = [1d0,0d0]
   inv_jacobian = inv_jacobian_semiso(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv semiso jacobian element 1, [1,-1]')
    
end subroutine test_inv_jacobian_semiso
!-----------------------------------------------------------------------------------------

!!!!!!! SPHEROIDAL MAPPING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!-----------------------------------------------------------------------------------------
subroutine test_mapping_spheroidal_xieta_to_sz()

   real(kind=dp)    :: xi, eta, sz(2), sz_ref(2)
   real(kind=dp)    :: nodes(4,2)

! 4 - - - - - - - 3
! |       ^       |
! |   eta |       |
! |       |       |
! |        --->   |
! |        xi     |
! |               |
! |               |
! 1 - - - - - - - 2
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = 0
   eta = 0
   sz_ref = [2**.5, 2**.5]
   sz = mapping_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'spheroidal element 1, [0 ,0]')

   xi = 1
   eta = 1
   sz_ref = [3, 0]
   sz = mapping_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'spheroidal element 1, [1 ,1]')

   xi = -1
   eta = -1
   sz_ref = [0, 1]
   sz = mapping_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'spheroidal element 1, [-1,-1]')


end subroutine test_mapping_spheroidal_xieta_to_sz
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_mapping_spheroidal_sz_to_xieta
   real(kind=dp)    :: s, z, xieta(2), xieta_ref(2)
   real(kind=dp)    :: nodes(4,2)
    
   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   s = 0 
   z = 1
   xieta_ref = [-1, -1]
   xieta = inv_mapping_spheroid(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv spheroidal element1, [-1,-1]')
   
   s = 0 
   z = 3
   xieta_ref = [-1, 1]
   xieta = inv_mapping_spheroid(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv spheroidal element1, [-1,1]')
   
   s = 1
   z = 0
   xieta_ref = [1, -1]
   xieta = inv_mapping_spheroid(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv spheroidal element1, [1,-1]')

   s = 3
   z = 0
   xieta_ref = [1, 1]
   xieta = inv_mapping_spheroid(s, z, nodes)

   call assert_comparable_real1d(real(xieta), real(xieta_ref), &
                                 1e-7, 'inv spheroidal element1, [1,1]')
   
   s = 2**.5
   z = 2**.5
   xieta_ref = [0, 0]
   xieta = inv_mapping_spheroid(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'inv spheroidal element1, [0,0]')

end subroutine test_inv_mapping_spheroidal_sz_to_xieta
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_jacobian_spheroidal()

   real(kind=dp)    :: xi, eta, jacobian(2,2), jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!            | ds / dxi  ds / deta |
! jacobian = |                     |
!            | dz / dxi  dz / deta |

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = -1
   jacobian_ref(1,:) = [datan(1d0),0d0] ! pi / 4
   jacobian_ref(2,:) = [       0d0,1d0]
   jacobian = jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'spheroidal jacobian element 1, [-1,-1]')

   xi = -1
   eta = 1
   jacobian_ref(1,:) = [datan(1d0) * 3.d0,0d0] ! pi / 4 * 3
   jacobian_ref(2,:) = [              0d0,1d0]
   jacobian = jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'spheroidal jacobian element 1, [-1,1]')

   xi = 1
   eta = -1
   jacobian_ref(1,:) = [0d0        ,1d0]
   jacobian_ref(2,:) = [-datan(1d0),0d0] ! -pi / 4
   jacobian = jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'spheroidal jacobian element 1, [1,-1]')

   xi = 1
   eta = 1
   jacobian_ref(1,:) = [0d0            ,1d0]
   jacobian_ref(2,:) = [-datan(1d0) * 3,0d0] ! -pi / 4 * 3
   jacobian = jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'spheroidal jacobian element 1, [1,1]')

end subroutine test_jacobian_spheroidal
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_jacobian_spheroid()

!                | dxi  / ds  dxi  / dz |
! inv_jacobian = |                      |
!                | deta / ds  deta / dz |

   real(kind=dp)    :: xi, eta, inv_jacobian(2,2), inv_jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

   nodes(1,:) = [0,1]
   nodes(2,:) = [1,0]
   nodes(3,:) = [3,0]
   nodes(4,:) = [0,3]

   xi = -1
   eta = -1
   inv_jacobian_ref(1,:) = [1d0 / datan(1d0),0d0]
   inv_jacobian_ref(2,:) = [0d0             ,1d0]
   inv_jacobian = inv_jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv spheroidal jacobian element 1, [-1,-1]')
   
   xi = -1
   eta = 1
   inv_jacobian_ref(1,:) = [1d0 / datan(1d0) / 3d0,0d0]
   inv_jacobian_ref(2,:) = [0d0                   ,1d0]
   inv_jacobian = inv_jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv spheroidal jacobian element 1, [-1,1]')
   
   xi = 1
   eta = -1
   inv_jacobian_ref(1,:) = [0d0,-1d0 / datan(1d0)]
   inv_jacobian_ref(2,:) = [1d0,0d0]
   inv_jacobian = inv_jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv spheroidal jacobian element 1, [1,-1]')

   xi = 1
   eta = 1
   inv_jacobian_ref(1,:) = [0d0,-1d0 / datan(1d0) / 3d0]
   inv_jacobian_ref(2,:) = [1d0,0d0]
   inv_jacobian = inv_jacobian_spheroid(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'inv spheroidal jacobian element 1, [1,1]')

end subroutine test_inv_jacobian_spheroid
!-----------------------------------------------------------------------------------------


!!!!!!! SUBPAR MAPPING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!-----------------------------------------------------------------------------------------
subroutine test_mapping_subpar_xieta_to_sz()

   real(kind=dp)    :: xi, eta, sz(2), sz_ref(2)
   real(kind=dp)    :: nodes(4,2)

! 4 - - - - - - - 3
! |       ^       |
! |   eta |       |
! |       |       |
! |        --->   |
! |        xi     |
! |               |
! |               |
! 1 - - - - - - - 2
    
   nodes(1,:) = [-1,-1]
   nodes(2,:) = [ 1,-1]
   nodes(3,:) = [ 1, 1]
   nodes(4,:) = [-1, 1]

   xi = 0
   eta = 0
   sz_ref = [xi, eta]
   sz = mapping_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'ref to ref is identity, [0 ,0]')

   call random_number(xi)
   call random_number(eta)
   xi  =  xi * 2 - 1
   eta = eta * 2 - 1
   sz_ref = [xi, eta]
   sz = mapping_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'ref to ref is identity, random xi, eta')

   nodes(1,:) = [0,0]
   nodes(2,:) = [2,0]
   nodes(3,:) = [2,2]
   nodes(4,:) = [0,2]

   call random_number(xi)
   call random_number(eta)
   xi  =  xi * 2 - 1
   eta = eta * 2 - 1
   sz_ref = [xi+1, eta+1]
   sz = mapping_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'pure translation, random xi, eta')
   
   nodes(1,:) = [ 0, 0]
   nodes(2,:) = [10, 0]
   nodes(3,:) = [10,20]
   nodes(4,:) = [ 0,20]

   call random_number(xi)
   call random_number(eta)
   xi  =  xi * 2 - 1
   eta = eta * 2 - 1
   sz_ref = [xi * 5 + 5, eta * 10 + 10]
   sz = mapping_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'stretching + translation, random xi, eta')
   
   nodes(2,:) = [ 0, 0]
   nodes(3,:) = [10, 0]
   nodes(4,:) = [10,20]
   nodes(1,:) = [ 0,20]

   call random_number(xi)
   call random_number(eta)
   xi  =  xi * 2 - 1
   eta = eta * 2 - 1
   sz_ref = [eta * 5 + 5, -xi * 10 + 10]
   sz = mapping_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(sz), 1 + real(sz_ref), &
                                 1e-7, 'rotation+ stretching + translation, random xi, eta')

end subroutine test_mapping_subpar_xieta_to_sz
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_mapping_subpar_sz_to_xieta
   real(kind=dp)    :: s, z, xieta(2), xieta_ref(2)
   real(kind=dp)    :: nodes(4,2)
    
   nodes(1,:) = [-1,-1]
   nodes(2,:) = [ 1,-1]
   nodes(3,:) = [ 1, 1]
   nodes(4,:) = [-1, 1]

   s = 1
   z = -1
   xieta_ref = [s, z]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'ref to ref is identity, [0 ,0]')

   call random_number(s)
   call random_number(z)
   xieta_ref = [s, z]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'ref to ref is identity, random')

   
   nodes(1,:) = [0,0]
   nodes(2,:) = [2,0]
   nodes(3,:) = [2,2]
   nodes(4,:) = [0,2]

   call random_number(s)
   call random_number(z)
   xieta_ref = [s-1, z-1]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'pure translation, random')

   nodes(1,:) = [ 0, 0]
   nodes(2,:) = [10, 0]
   nodes(3,:) = [10,20]
   nodes(4,:) = [ 0,20]

   call random_number(s)
   call random_number(z)
   xieta_ref = [(s-5) / 5.d0, (z-10) / 10d0]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'stretching + translation, random')

   nodes(1,:) = [1,1]
   nodes(2,:) = [4,1]
   nodes(3,:) = [7,3]
   nodes(4,:) = [2,3]

   s = 1
   z = 1
   xieta_ref = [-1,-1]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 - real(xieta), 1 - real(xieta_ref), &
                                 1e-7, 'nonlinear element, [-1 ,-1]')
   
   s = 3
   z = 1.5
   xieta_ref = [0.d0,-0.5d0]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'nonlinear element, [0, -.5]')

   s = 4.5
   z = 2
   xieta_ref = [0.5d0,0.0d0]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'nonlinear element, [0.5, 0]')

   s = 7
   z = 3
   xieta_ref = [1,1]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'nonlinear element, [1 ,1]')

   nodes(1,:) = [-1,-1]
   nodes(2,:) = [ 1,-1]
   nodes(3,:) = [ 3, 3]
   nodes(4,:) = [-1, 1]

   s = -1
   z = -1
   xieta_ref = [-1,-1]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 - real(xieta), 1 - real(xieta_ref), &
                                 1e-7, 'nonlinear element2, [-1 ,-1]')

   s = 3
   z = 3
   xieta_ref = [1,1]
   xieta = inv_mapping_subpar(s, z, nodes)

   call assert_comparable_real1d(1 + real(xieta), 1 + real(xieta_ref), &
                                 1e-7, 'nonlinear element2, [1 ,1]')

end subroutine test_inv_mapping_subpar_sz_to_xieta
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_jacobian_subpar()

   real(kind=dp)    :: xi, eta, jacobian(2,2), jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

!            | ds / dxi  ds / deta |
! jacobian = |                     |
!            | dz / dxi  dz / deta |

   nodes(1,:) = [-1,-1]
   nodes(2,:) = [ 1,-1]
   nodes(3,:) = [ 1, 1]
   nodes(4,:) = [-1, 1]

   call random_number(xi)
   call random_number(eta)
   jacobian_ref(1,:) = [1,0]
   jacobian_ref(2,:) = [0,1]
   jacobian = jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'ref to ref, jacobian is identity')

   nodes(2,:) = [-1,-1]
   nodes(3,:) = [ 1,-1]
   nodes(4,:) = [ 1, 1]
   nodes(1,:) = [-1, 1]

   call random_number(xi)
   call random_number(eta)
   jacobian_ref(1,:) = [ 0,1]
   jacobian_ref(2,:) = [-1,0]
   jacobian = jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'pure rotation')
   
   nodes(1,:) = [0,0]
   nodes(2,:) = [2,0]
   nodes(3,:) = [2,2]
   nodes(4,:) = [0,2]

   call random_number(xi)
   call random_number(eta)
   jacobian_ref(1,:) = [1,0]
   jacobian_ref(2,:) = [0,1]
   jacobian = jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'pure translation, jacobian is identity')

   nodes(1,:) = [ 0, 0]
   nodes(2,:) = [10, 0]
   nodes(3,:) = [10,20]
   nodes(4,:) = [ 0,20]

   call random_number(xi)
   call random_number(eta)
   jacobian_ref(1,:) = [5, 0]
   jacobian_ref(2,:) = [0,10]
   jacobian = jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(jacobian, [4])), &
                                 1 + real(reshape(jacobian_ref, [4])), &
                                 1e-7, 'continuous stretching, jacobian is constant')

end subroutine test_jacobian_subpar
!-----------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine test_inv_jacobian_subpar()

!                | dxi  / ds  dxi  / dz |
! inv_jacobian = |                      |
!                | deta / ds  deta / dz |

   real(kind=dp)    :: xi, eta, inv_jacobian(2,2), inv_jacobian_ref(2,2)
   real(kind=dp)    :: nodes(4,2)

   nodes(1,:) = [-1,-1]
   nodes(2,:) = [ 1,-1]
   nodes(3,:) = [ 1, 1]
   nodes(4,:) = [-1, 1]

   call random_number(xi)
   call random_number(eta)
   inv_jacobian_ref(1,:) = [1,0]
   inv_jacobian_ref(2,:) = [0,1]
   inv_jacobian = inv_jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'ref to ref, inv_jacobian is identity')

   nodes(2,:) = [-1,-1]
   nodes(3,:) = [ 1,-1]
   nodes(4,:) = [ 1, 1]
   nodes(1,:) = [-1, 1]

   call random_number(xi)
   call random_number(eta)
   inv_jacobian_ref(1,:) = [0,-1]
   inv_jacobian_ref(2,:) = [1, 0]
   inv_jacobian = inv_jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'pure rotation')
   
   nodes(1,:) = [0,0]
   nodes(2,:) = [2,0]
   nodes(3,:) = [2,2]
   nodes(4,:) = [0,2]

   call random_number(xi)
   call random_number(eta)
   inv_jacobian_ref(1,:) = [1,0]
   inv_jacobian_ref(2,:) = [0,1]
   inv_jacobian = inv_jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'pure translation, inv_jacobian is identity')

   nodes(1,:) = [ 0, 0]
   nodes(2,:) = [10, 0]
   nodes(3,:) = [10,20]
   nodes(4,:) = [ 0,20]

   call random_number(xi)
   call random_number(eta)
   inv_jacobian_ref(1,:) = [0.2d0, 0.0d0]
   inv_jacobian_ref(2,:) = [0.0d0, 0.1d0]
   inv_jacobian = inv_jacobian_subpar(xi, eta, nodes)

   call assert_comparable_real1d(1 + real(reshape(inv_jacobian, [4])), &
                                 1 + real(reshape(inv_jacobian_ref, [4])), &
                                 1e-7, 'continuous stretching, inv_jacobian is constant')

end subroutine test_inv_jacobian_subpar
!-----------------------------------------------------------------------------------------

end module
!=========================================================================================
