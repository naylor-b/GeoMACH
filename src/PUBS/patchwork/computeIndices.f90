subroutine computeEdgeIndices(nedge, ngroup, edge_group, group_n, edge_index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) nedge, ngroup, edge_group, group_n
  !f2py intent(out) edge_index
  !f2py depend(nedge) edge_group
  !f2py depend(ngroup) group_n
  !f2py depend(nedge) edge_index

  !Input
  integer, intent(in) ::  nedge, ngroup
  integer, intent(in) ::  edge_group(nedge), group_n(ngroup)

  !Output
  integer, intent(out) ::  edge_index(nedge,2)

  !Working
  integer edge
  integer i1, i2

  i2 = 0
  do edge=1,nedge
     i1 = i2
     i2 = i2 + group_n(edge_group(edge)) - 2
     edge_index(edge,1) = i1
     edge_index(edge,2) = i2
  end do

end subroutine computeEdgeIndices



subroutine computeSurfIndices(nsurf, nedge, ngroup, surf_edge, edge_group, group_n,& 
           surf_index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) nsurf, nedge, ngroup, surf_edge, edge_group, group_n
  !f2py intent(out) surf_index
  !f2py depend(nsurf) surf_edge
  !f2py depend(nedge) edge_group
  !f2py depend(ngroup) group_n
  !f2py depend(nsurf) surf_index

  !Input
  integer, intent(in) ::  nsurf, nedge, ngroup
  integer, intent(in) ::  surf_edge(nsurf,2,2), edge_group(nedge), group_n(ngroup)

  !Output
  integer, intent(out) ::  surf_index(nsurf,2)

  !Working
  integer surf
  integer i1, i2

  i2 = 0
  do surf=1,nsurf
     i1 = i2
     i2 = i2 + (group_n(edge_group(abs(surf_edge(surf,1,1)))) - 2) * & 
          (group_n(edge_group(abs(surf_edge(surf,2,1)))) - 2)
     surf_index(surf,1) = i1
     surf_index(surf,2) = i2
  end do

end subroutine computeSurfIndices



subroutine computeEdgeIndicesQ(nsurf, nedge, ngroup, surf_edge, edge_group, & 
           group_n, surf_c1, edge_index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) nsurf, nedge, ngroup, surf_edge, edge_group, group_n, surf_c1
  !f2py intent(out) edge_index
  !f2py depend(nsurf) surf_edge
  !f2py depend(nedge) edge_group
  !f2py depend(ngroup) group_n
  !f2py depend(nsurf) surf_c1
  !f2py depend(nedge) edge_index

  !Input
  integer, intent(in) ::  nsurf, nedge, ngroup
  integer, intent(in) ::  surf_edge(nsurf,2,2), edge_group(nedge), & 
                          group_n(ngroup)
  logical, intent(in) ::  surf_c1(nsurf,3,3)

  !Output
  integer, intent(out) ::  edge_index(nedge,2)

  !Working
  integer surf,edge
  integer i1, i2
  logical dof

  edge_index(:,:) = 0
  i2 = 0
  do edge=1,nedge
     dof = .true.
     do surf=1,nsurf
        if ((surf_edge(surf,1,1) .eq. edge) .and. surf_c1(surf,2,1)) then
           dof = .false.
        end if
        if ((surf_edge(surf,1,2) .eq. edge) .and. surf_c1(surf,2,3)) then
           dof = .false.
        end if
        if ((surf_edge(surf,2,1) .eq. edge) .and. surf_c1(surf,1,2)) then
           dof = .false.
        end if
        if ((surf_edge(surf,2,2) .eq. edge) .and. surf_c1(surf,3,2)) then
           dof = .false.
        end if
     end do
     if (dof) then
        i1 = i2
        i2 = i2 + group_n(edge_group(edge)) - 2
        edge_index(edge,1) = i1
        edge_index(edge,2) = i2
     end if
  end do

end subroutine computeEdgeIndicesQ



subroutine computeVertIndicesQ(nsurf, nedge, nvert, surf_vert, surf_edge, surf_c1,& 
           edge_c1, vert_index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) nsurf, nedge, nvert, surf_vert, surf_edge, surf_c1, edge_c1
  !f2py intent(out) vert_index
  !f2py depend(nsurf) surf_vert, surf_edge
  !f2py depend(nsurf) surf_c1
  !f2py depend(nedge) edge_c1
  !f2py depend(nvert) vert_index

  !Input  
  integer, intent(in) ::  nsurf, nedge, nvert
  integer, intent(in) ::  surf_vert(nsurf,2,2), surf_edge(nsurf,2,2)
  logical, intent(in) ::  surf_c1(nsurf,3,3), edge_c1(nedge,2)

  !Output
  integer, intent(out) ::  vert_index(nvert)

  !Working
  integer vert, surf
  integer i,j
  logical dof(nvert)

  dof(:) = .true.
  do surf=1,nsurf
     do i=1,2
        do j=1,2
           if (surf_c1(surf,2*i-1,2*j-1)) then
              dof(surf_vert(surf,i,j)) = .false.
           end if
        end do
     end do
     do i=1,2
        do j=1,2
           if ((edge_c1(abs(surf_edge(surf,1,i)),j)) .and. (surf_edge(surf,1,i)& 
              .gt. 0)) then
              dof(surf_vert(surf,j,i)) = .false.
           end if
           if ((edge_c1(abs(surf_edge(surf,1,i)),j)) .and. (surf_edge(surf,1,i)&
              .lt. 0)) then
              dof(surf_vert(surf,3-j,i)) = .false.
           end if
           if ((edge_c1(abs(surf_edge(surf,2,i)),j)) .and. (surf_edge(surf,2,i)&
              .gt. 0)) then
              dof(surf_vert(surf,i,j)) = .false.
           end if
           if ((edge_c1(abs(surf_edge(surf,2,i)),j)) .and. (surf_edge(surf,2,i)&
              .lt. 0)) then
              dof(surf_vert(surf,i,3-j)) = .false.
           end if
        end do
     end do
  end do
  
  vert_index(:) = 0
  i = 1
  do vert=1,nvert
     if (dof(vert)) then
        vert_index(vert) = i
        i = i + 1
     end if
  end do

end subroutine computeVertIndicesQ



subroutine computeKnotIndices(ngroup, group_k, group_m, knot_index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) ngroup, group_k, group_m
  !f2py intent(out) knot_index
  !f2py depend(ngroup) group_k, group_m
  !f2py depend(ngroup) knot_index

  !Input
  integer, intent(in) ::  ngroup
  integer, intent(in) ::  group_k(ngroup), group_m(ngroup)

  !Output
  integer, intent(out) ::  knot_index(ngroup,2)

  !Working
  integer group, i

  i = 0
  do group=1,ngroup
     knot_index(group,1) = i
     i = i + group_k(group) + group_m(group)
     knot_index(group,2) = i
  end do

end subroutine computeKnotIndices



subroutine getIndex(surf, u, v, mu, mv, nsurf, nedge, nvert, surf_vert, &
           surf_edge, surf_index, edge_index, index)

  implicit none

  !Fortran-python interface directives
  !f2py intent(in) surf, u, v, mu, mv, nsurf, nedge, nvert, surf_vert, surf_edge, surf_index, edge_index
  !f2py intent(out) index
  !f2py depend(nsurf) surf_vert
  !f2py depend(nsurf) surf_edge
  !f2py depend(nsurf) surf_index
  !f2py depend(nedge) edge_index

  !Input
  integer, intent(in) ::  surf, u, v, mu, mv, nsurf, nedge, nvert
  integer, intent(in) ::  surf_vert(nsurf,2,2), surf_edge(nsurf,2,2)
  integer, intent(in) ::  surf_index(nsurf,2), edge_index(nedge,2)

  !Output
  integer, intent(out) ::  index
  
  !Working
  integer uu, vv
  integer edge

  if (u .eq. 1) then
     uu = 1
  else if (u .eq. mu) then
     uu = 2
  else
     uu = 0
  end if

  if (v .eq. 1) then
     vv = 1
  else if (v .eq. mv) then
     vv = 2
  else
     vv = 0
  end if

  if ((uu .eq. 0) .and. (vv .eq. 0)) then
     index = nvert + maxval(edge_index(:,2)) + surf_index(surf,1)
     index = index + (v-2)*(mu-2) + (u-1)
  else if (vv .eq. 0) then
     edge = surf_edge(surf,2,uu)
     if (edge .gt. 0) then
        index = nvert + edge_index(abs(edge),1) + v - 1
     else
        index = nvert + edge_index(abs(edge),1) + mv - v
     end if
  else if (uu .eq. 0) then
     edge = surf_edge(surf,1,vv)
     if (edge .gt. 0) then
        index = nvert + edge_index(abs(edge),1) + u - 1
     else
        index = nvert + edge_index(abs(edge),1) + mu - u
     end if
  else
     index = surf_vert(surf,uu,vv)
  end if

end subroutine getIndex
