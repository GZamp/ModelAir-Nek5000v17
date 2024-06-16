!> @file frame_usr.f
!! @ingroup frame
!! @brief User interface routines for framework
!! @author Adam Peplinski
!! @date Sep 17, 2018
!======================================================================
!> @brief Register user specified modules
      subroutine frame_usr_register
      implicit none

      include 'SIZE'
      include 'FRAMELP'
!-----------------------------------------------------------------------
      call trip_register
      call stat_register
      call chkpt_register
      call io_register
      call tsrs_register

      return
      end subroutine
!======================================================================
!> @brief Initialise user specified modules
      subroutine frame_usr_init
      implicit none

      include 'SIZE'
      include 'FRAMELP'
!-----------------------------------------------------------------------
      call trip_init
      call stat_init
      call chkpt_init
      call tsrs_init


      return
      end subroutine
!======================================================================
!> @brief Provide element coordinates and local numbers (user interface)
!! @param[out]  idir              mapping (uniform) direction
!! @param[out]  ctrs              2D element centres
!! @param[out]  cell              local element numberring
!! @param[in]   lctrs1,lctrs2     array sizes
!! @param[out]  nelsort           number of local 3D elements to sort
!! @param[out]  map_xm1, map_ym1  2D coordinates of mapped elements
!! @param[out]  ierr              error flag
      subroutine user_map2d_get(idir,ctrs,cell,lctrs1,lctrs2,nelsort,
     $     map_xm1,map_ym1,ierr)
      implicit none

      include 'SIZE'
      include 'INPUT'           ! [XYZ]C
      include 'GEOM'            ! [XYZ]M1

!     argument list
      integer idir
      integer lctrs1,lctrs2
      real ctrs(lctrs1,lctrs2)  ! 2D element centres  and diagonals 
      integer cell(lctrs2)      ! local element numberring
      integer nelsort           ! number of local 3D elements to sort
      real map_xm1(lx1,lz1,lelt), map_ym1(lx1,lz1,lelt)
      integer ierr              ! error flag

!     local variables
      integer ntot              ! tmp array size for copying
      integer el ,il ,jl        ! loop indexes
      integer nvert             ! vertex number
      real rnvert               ! 1/nvert
      real xmid,ymid            ! 2D element centre
      real xmin,xmax,ymin,ymax  ! to get approximate element diagonal
      integer ifc               ! face number

!     dummy arrays
      real xcoord(8,LELT), ycoord(8,LELT) ! tmp vertex coordinates

#ifdef DEBUG
!     for testing
      character*3 str1, str2
      integer iunit, ierrl
      ! call number
      integer icalldl
      save icalldl
      data icalldl /0/
#endif

!-----------------------------------------------------------------------
!     initial error flag
      ierr = 0
!     set important parameters
!     uniform direction; should be taken as input parameter
!     x-> 1, y-> 2, z-> 3
      idir = 3
      
!     get element midpoints
!     vertex number
      nvert = 2**NDIM
      rnvert= 1.0/real(nvert)

!     eliminate uniform direction
      ntot = 8*NELV
      if (idir.EQ.1) then  ! uniform X
         call copy(xcoord,YC,ntot) ! copy y
         call copy(ycoord,ZC,ntot) ! copy z
      elseif (idir.EQ.2) then  ! uniform Y
         call copy(xcoord,XC,ntot) ! copy x
         call copy(ycoord,ZC,ntot) ! copy z
      elseif (idir.EQ.3) then  ! uniform Z
         call copy(xcoord,XC,ntot) ! copy x
         call copy(ycoord,YC,ntot) ! copy y
      endif

!     set initial number of elements to sort
      nelsort = 0
      call izero(cell,NELT)

!     for every element
      do el=1,NELV
!     element centre
         xmid = xcoord(1,el)
         ymid = ycoord(1,el)
!     element diagonal
         xmin = xmid
         xmax = xmid
         ymin = ymid
         ymax = ymid
         do il=2,nvert
            xmid=xmid+xcoord(il,el)
            ymid=ymid+ycoord(il,el)
            xmin = min(xmin,xcoord(il,el))
            xmax = max(xmax,xcoord(il,el))
            ymin = min(ymin,ycoord(il,el))
            ymax = max(ymax,ycoord(il,el))
         enddo
         xmid = xmid*rnvert
         ymid = ymid*rnvert

!     count elements to sort
            nelsort = nelsort + 1
!     2D position
!     in general this coud involve some curvilinear transform
            ctrs(1,nelsort)=xmid
            ctrs(2,nelsort)=ymid
!     reference distance
            ctrs(3,nelsort)=sqrt((xmax-xmin)**2 + (ymax-ymin)**2)
            if (ctrs(3,nelsort).eq.0.0) then
               ierr = 1
               return
            endif
!     element index
            cell(nelsort) = el
      enddo

!     provide 2D mesh
!     in general this coud involve some curvilinear transform
      if (idir.EQ.1) then  ! uniform X
         ifc = 4
         do el=1,NELV
            call ftovec(map_xm1(1,1,el),ym1,el,ifc,nx1,ny1,nz1)
            call ftovec(map_ym1(1,1,el),zm1,el,ifc,nx1,ny1,nz1)
         enddo
      elseif (idir.eq.2) then  ! uniform y
         ifc = 1
         do el=1,nelv
            call ftovec(map_xm1(1,1,el),xm1,el,ifc,nx1,ny1,nz1)
            call ftovec(map_ym1(1,1,el),zm1,el,ifc,nx1,ny1,nz1)
         enddo
      elseif (idir.eq.3) then  ! uniform z
         ifc = 5
         do el=1,nelv
            call ftovec(map_xm1(1,1,el),xm1,el,ifc,nx1,ny1,nz1)
            call ftovec(map_ym1(1,1,el),ym1,el,ifc,nx1,ny1,nz1)
         enddo
      endif

#ifdef DEBUG
!     testing
      ! to output refinement
      icalldl = icalldl+1
      call io_file_freeid(iunit, ierrl)
      write(str1,'(i3.3)') NID
      write(str2,'(i3.3)') icalldl
      open(unit=iunit,file='map2d_usr.txt'//str1//'i'//str2)
      
      write(iunit,*) idir, NELV, nelsort
      write(iunit,*) 'Centre coordinates and cells'
      do el=1,nelsort
         write(iunit,*) el, ctrs(:,el), cell(el)
      enddo
      write(iunit,*) 'GLL coordinates'
      do el=1,nelsort
         write(iunit,*) 'Element ', el
         write(iunit,*) 'XM1'
         do il=1,nz1
            write(iunit,*) (map_xm1(jl,il,el),jl=1,nx1)
         enddo
         write(iunit,*) 'YM1'
         do il=1,nz1
            write(iunit,*) (map_ym1(jl,il,el),jl=1,nx1)
         enddo
      enddo
      close(iunit)
#endif

      return
      end subroutine
!=======================================================================
!> @brief Provide velocity, deriv. and vort. in required coordinates
!! @param[out]  lvel             velocity
!! @param[out]  dudx,dvdx,dwdx   velocity derivatives
!! @param[out]  vort             vorticity
      subroutine user_stat_trnsv(lvel,dudx,dvdx,dwdx,vort)
      implicit none

      include 'SIZE'
      include 'SOLN'
      include 'INPUT'               ! if3d

!     argument list
      real lvel(LX1,LY1,LZ1,LELT,3) ! velocity array
      real dudx(LX1,LY1,LZ1,LELT,3) ! velocity derivatives; U
      real dvdx(LX1,LY1,LZ1,LELT,3) ! V
      real dwdx(LX1,LY1,LZ1,LELT,3) ! W
      real vort(LX1,LY1,LZ1,LELT,3) ! vorticity

!     local variables
      integer itmp              ! dummy variable
!-----------------------------------------------------------------------
!     Velocity transformation; simple copy
      itmp = NX1*NY1*NZ1*NELV
      call copy(lvel(1,1,1,1,1),VX,itmp)
      call copy(lvel(1,1,1,1,2),VY,itmp)
      call copy(lvel(1,1,1,1,3),VZ,itmp)

!     Derivative transformation
!     No transformation
      call gradm1(dudx(1,1,1,1,1),dudx(1,1,1,1,2),dudx(1,1,1,1,3),
     $      lvel(1,1,1,1,1))
      call gradm1(dvdx(1,1,1,1,1),dvdx(1,1,1,1,2),dvdx(1,1,1,1,3),
     $      lvel(1,1,1,1,2))
      call gradm1(dwdx(1,1,1,1,1),dwdx(1,1,1,1,2),dwdx(1,1,1,1,3),
     $      lvel(1,1,1,1,3))

!     get vorticity
      if (IF3D) then
!     curlx
         call sub3(vort(1,1,1,1,1),dwdx(1,1,1,1,2),
     $        dvdx(1,1,1,1,3),itmp)
!     curly
         call sub3(vort(1,1,1,1,2),dudx(1,1,1,1,3),
     $        dwdx(1,1,1,1,1),itmp)
      endif
!     curlz
      call sub3(vort(1,1,1,1,3),dvdx(1,1,1,1,1),dudx(1,1,1,1,2),itmp)

      return
      end subroutine
!======================================================================
