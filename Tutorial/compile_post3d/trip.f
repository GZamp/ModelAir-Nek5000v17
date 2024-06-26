!> @file trip.f
!! @ingroup tripping
!! @brief Tripping function for AMR version of nek5000
!! @note  This version uses developed framework parts. This is because
!!   I'm in a hurry and I want to save some time writing the code. So
!!   I reuse already tested code and focuse important parts. For the
!!   same reason for now only lines parallel to z axis are considered. 
!! @author Adam Peplinski
!! @date May 03, 2018
!=======================================================================
!> @brief Register tripping module
!! @ingroup tripping
!! @note This routine should be called in userchk during first step
!!  between calls to frame_start and frame_rparam
      subroutine trip_register()
      implicit none

      include 'SIZE'
      include 'INPUT'
      include 'FRAMELP'
      include 'TRIPD'

!     local variables
      integer lpmid, il
      real ltim
      character*2 str

!     functions
      real dnekclock
!-----------------------------------------------------------------------
!     timing
      ltim = dnekclock()

!     check if the current module was already registered
      call mntr_mod_is_name_reg(lpmid,trip_name)
      if (lpmid.gt.0) then
         call mntr_warn(lpmid,
     $        'module ['//trim(trip_name)//'] already registered')
         return
      endif

!     find parent module
      call mntr_mod_is_name_reg(lpmid,'FRAME')
      if (lpmid.le.0) then
         lpmid = 1
         call mntr_abort(lpmid,
     $        'parent module ['//'FRAME'//'] not registered')
      endif

!     register module
      call mntr_mod_reg(trip_id,lpmid,trip_name,
     $      'Tripping along the line')

!     register timer
      call mntr_tmr_is_name_reg(lpmid,'FRM_TOT')
      call mntr_tmr_reg(trip_tmr_id,lpmid,trip_id,
     $     'TRIP_TOT','Tripping total time',.false.)

!     register and set active section
      call rprm_sec_reg(trip_sec_id,trip_id,'_'//adjustl(trip_name),
     $     'Runtime paramere section for tripping module')
      call rprm_sec_set_act(.true.,trip_sec_id)

!     register parameters
      call rprm_rp_reg(trip_nline_id,trip_sec_id,'NLINE',
     $     'Number of tripping lines',rpar_int,0,0.0,.false.,' ')

      call rprm_rp_reg(trip_tiamp_id,trip_sec_id,'TIAMP',
     $     'Time independent amplitude',rpar_real,0,0.0,.false.,' ')

      call rprm_rp_reg(trip_tdamp_id,trip_sec_id,'TDAMP',
     $     'Time dependent amplitude',rpar_real,0,0.0,.false.,' ')

      do il=1, trip_nline_max
         write(str,'(I2.2)') il

         call rprm_rp_reg(trip_spos_id(1,il),trip_sec_id,'SPOSX'//str,
     $     'Starting pont X',rpar_real,0,0.0,.false.,' ')
         
         call rprm_rp_reg(trip_spos_id(2,il),trip_sec_id,'SPOSY'//str,
     $     'Starting pont Y',rpar_real,0,0.0,.false.,' ')

         if (IF3D) then
            call rprm_rp_reg(trip_spos_id(ldim,il),trip_sec_id,
     $           'SPOSZ'//str,'Starting pont Z',
     $           rpar_real,0,0.0,.false.,' ')
         endif
        
         call rprm_rp_reg(trip_epos_id(1,il),trip_sec_id,'EPOSX'//str,
     $     'Ending pont X',rpar_real,0,0.0,.false.,' ')
         
         call rprm_rp_reg(trip_epos_id(2,il),trip_sec_id,'EPOSY'//str,
     $     'Ending pont Y',rpar_real,0,0.0,.false.,' ')

         if (IF3D) then
            call rprm_rp_reg(trip_epos_id(ldim,il),trip_sec_id,
     $           'EPOSZ'//str,'Ending pont Z',
     $           rpar_real,0,0.0,.false.,' ')
         endif

         call rprm_rp_reg(trip_smth_id(1,il),trip_sec_id,'SMTHX'//str,
     $     'Smoothing length X',rpar_real,0,0.0,.false.,' ')
         
         call rprm_rp_reg(trip_smth_id(2,il),trip_sec_id,'SMTHY'//str,
     $     'Smoothing length Y',rpar_real,0,0.0,.false.,' ')

         if (IF3D) then
            call rprm_rp_reg(trip_smth_id(ldim,il),trip_sec_id,
     $           'SMTHZ'//str,'Smoothing length Z',
     $           rpar_real,0,0.0,.false.,' ')
         endif
      
         call rprm_rp_reg(trip_rota_id(il),trip_sec_id,'ROTA'//str,
     $        'Rotation angle',rpar_real,0,0.0,.false.,' ')
         call rprm_rp_reg(trip_nmode_id(il),trip_sec_id,'NMODE'//str,
     $     'Number of Fourier modes',rpar_int,0,0.0,.false.,' ')
         call rprm_rp_reg(trip_tdt_id(il),trip_sec_id,'TDT'//str,
     $     'Time step for tripping',rpar_real,0,0.0,.false.,' ')
      enddo

!     set initialisation flag
      trip_ifinit=.false.
      
!     timing
      ltim = dnekclock() - ltim
      call mntr_tmr_add(trip_tmr_id,1,ltim)

      return
      end subroutine
!=======================================================================
!> @brief Initilise tripping module
!! @ingroup tripping
!! @note This routine should be called in userchk during first step
!!    after call to frame_rparam
      subroutine trip_init()
      implicit none

      include 'SIZE'
      include 'INPUT'
      include 'GEOM'
      include 'FRAMELP'
      include 'TRIPD'

!     local variables
      integer itmp
      real rtmp, ltim
      logical ltmp
      character*20 ctmp

      integer il, jl

!     functions
      real dnekclock
!-----------------------------------------------------------------------
!     timing
      ltim = dnekclock()      

!     check if the module was already initialised
      if (trip_ifinit) then
         call mntr_warn(trip_id,
     $        'module ['//trim(trip_name)//'] already initiaised.')
         return
      endif
      
!     get runtime parameters
      call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_nline_id,rpar_int)
      trip_nline = itmp
      call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_tiamp_id,rpar_real)
      trip_tiamp = rtmp
      call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_tdamp_id,rpar_real)
      trip_tdamp = rtmp
      do il=1,trip_nline
         do jl=1,LDIM
            call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_spos_id(jl,il),
     $           rpar_real)
            trip_spos(jl,il) = rtmp
            call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_epos_id(jl,il),
     $           rpar_real)
            trip_epos(jl,il) = rtmp
            call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_smth_id(jl,il),
     $           rpar_real)
            trip_smth(jl,il) = rtmp
         enddo
         call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_rota_id(il),
     $        rpar_real)
         trip_rota(il) = rtmp
         call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_nmode_id(il),
     $        rpar_int)
         trip_nmode(il) = itmp
         call rprm_rp_get(itmp,rtmp,ltmp,ctmp,trip_tdt_id(il),
     $        rpar_real)
         trip_tdt(il) = rtmp
      enddo

!     get inverse line lengths and smoothing radius
      do il=1,trip_nline
         trip_ilngt(il) = 0.0
         do jl=1,LDIM
            trip_ilngt(il) = trip_ilngt(il) + (trip_epos(jl,il)-
     $           trip_spos(jl,il))**2
         enddo
         if (trip_ilngt(il).gt.0.0) then
            trip_ilngt(il) = 1.0/sqrt(trip_ilngt(il))
         else
            trip_ilngt(il) = 1.0
         endif
         do jl=1,LDIM
            if (trip_smth(jl,il).gt.0.0) then
               trip_ismth(jl,il) = 1.0/trip_smth(jl,il)
            else
               trip_ismth(jl,il) = 1.0
            endif
         enddo
      enddo

!     get 1D projection and array mapping
      call trip_1dprj

!     initialise random generator seed and number of time intervals
      do il=1,trip_nline
         trip_seed(il) = -32*il
      enddo
      trip_ntdt = 1 - trip_nset_max
      trip_ntdt_old = trip_ntdt
      
!     generate random phases (time independent and time dependent)
      call trip_rphs_get

!     get forcing
      call trip_frcs_get(.true.)
      
!     everything is initialised
      trip_ifinit=.true.

!     timing
      ltim = dnekclock() - ltim
      call mntr_tmr_add(trip_tmr_id,1,ltim)

      return
      end subroutine
!=======================================================================
!> @brief Update tripping
!! @ingroup tripping
      subroutine trip_update()
      implicit none

      include 'SIZE'
      include 'TRIPD'

!     local variables
      real ltim
      
!     functions
      real dnekclock
!-----------------------------------------------------------------------
!     timing
      ltim = dnekclock()      

!     update random phases (time independent and time dependent)
      call trip_rphs_get

!     update forcing
      call trip_frcs_get(.false.)

!     timing
      ltim = dnekclock() - ltim
      call mntr_tmr_add(trip_tmr_id,1,ltim)

      return
      end subroutine      
!=======================================================================
!> @brief Reset tripping
!! @ingroup tripping
      subroutine trip_reset()
      implicit none

      include 'SIZE'
      include 'TRIPD'

!     local variables
      real ltim
      
!     functions
      real dnekclock
!-----------------------------------------------------------------------
!     timing
      ltim = dnekclock()      

!     get 1D projection and array mapping
      call trip_1dprj
      
!     update forcing
      call trip_frcs_get(.true.)

!     timing
      ltim = dnekclock() - ltim
      call mntr_tmr_add(trip_tmr_id,1,ltim)

      return
      end subroutine
!=======================================================================
!> @brief Get 1D projection, array mapping and forcing smoothing
!! @ingroup tripping
!! @details This routine is just a simple version supporting only lines
!!   paralles to z axis. In future it can be generalised.
!! @remark This routine uses global scratch space \a CTMP0 and \a CTMP1
      subroutine trip_1dprj()
      implicit none

      include 'SIZE'
      include 'INPUT'
      include 'GEOM'
      include 'TRIPD'

!     local variables
      integer npxy, npel, nptot, itmp, jtmp, ktmp, eltmp
      integer il, jl
      real xl, yl, xr, yr, rota, rtmp, epsl
      parameter (epsl = 1.0e-10)
      
      real lcoord(LX1*LY1*LZ1*LELT)
      common /CTMP0/ lcoord
      integer lmap(LX1*LY1*LZ1*LELT)
      common /CTMP1/ lmap
!-----------------------------------------------------------------------
      npxy = NX1*NY1
      npel = npxy*NZ1
      nptot = npel*NELV
      
!     for each line
      do il=1,trip_nline
!     Get coordinates and sort them
         call copy(lcoord,zm1,nptot)
         call sort(lcoord,lmap,nptot)

!     find unique entrances and provide mapping
         trip_npoint(il) = 1
         trip_prj(trip_npoint(il),il) = lcoord(1)
         itmp = lmap(1)-1
         eltmp = itmp/npel + 1
         itmp = itmp - npel*(eltmp-1)
         ktmp = itmp/npxy + 1
         itmp = itmp - npxy*(ktmp-1)
         jtmp = itmp/nx1 + 1
         itmp = itmp - nx1*(jtmp-1) + 1
         trip_map(itmp,jtmp,ktmp,eltmp,il) = trip_npoint(il)
         do jl=2,nptot
            if((lcoord(jl)-trip_prj(trip_npoint(il),il)).gt.
     $           max(epsl,abs(epsl*lcoord(jl)))) then
               trip_npoint(il) = trip_npoint(il) + 1
               trip_prj(trip_npoint(il),il) = lcoord(jl)
            endif

            itmp = lmap(jl)-1
            eltmp = itmp/npel + 1
            itmp = itmp - npel*(eltmp-1)
            ktmp = itmp/npxy + 1
            itmp = itmp - npxy*(ktmp-1)
            jtmp = itmp/nx1 + 1
            itmp = itmp - nx1*(jtmp-1) + 1
            trip_map(itmp,jtmp,ktmp,eltmp,il) = trip_npoint(il)
         enddo
             
!     rescale 1D array
         do jl=1,trip_npoint(il)
            trip_prj(jl,il) = (trip_prj(jl,il) - trip_spos(ldim,il))
     $           *trip_ilngt(il)
         enddo
         
!     get smoothing profile
         rota = trip_rota(il)
         
         do jl=1,nptot
            itmp = jl-1
            eltmp = itmp/npel + 1
            itmp = itmp - npel*(eltmp-1)
            ktmp = itmp/npxy + 1
            itmp = itmp - npxy*(ktmp-1)
            jtmp = itmp/nx1 + 1
            itmp = itmp - nx1*(jtmp-1) + 1

!     rotation
            xl = xm1(itmp,jtmp,ktmp,eltmp)-trip_spos(1,il)
            yl = ym1(itmp,jtmp,ktmp,eltmp)-trip_spos(2,il)

            xr = xl*cos(rota)+yl*sin(rota)
            yr = -xl*sin(rota)+yl*cos(rota)
            
            rtmp = (xr*trip_ismth(1,il))**2 + (yr*trip_ismth(2,il))**2
!     Gauss
!            trip_fsmth(itmp,jtmp,ktmp,eltmp,il) = exp(-4.0*rtmp)
!     limited support
            if (rtmp.lt.1.0) then
               trip_fsmth(itmp,jtmp,ktmp,eltmp,il) =
     $              exp(-rtmp)*(1-rtmp)**2
            else
               trip_fsmth(itmp,jtmp,ktmp,eltmp,il) = 0.0
            endif

         enddo
      enddo

      return
      end subroutine      
!=======================================================================
!> @brief Generate set of random phases
!! @ingroup tripping
      subroutine trip_rphs_get
      implicit none

      include 'SIZE'
      include 'TSTEP'
      include 'PARALLEL'
      include 'TRIPD'
      
!     local variables
      integer il, jl, kl
      integer itmp
      real trip_ran2

#ifdef DEBUG
      character*3 str1, str2
      integer iunit, ierr
      ! call number
      integer icalldl
      save icalldl
      data icalldl /0/
#endif
!-----------------------------------------------------------------------
!     time independent part
      if (trip_tiamp.gt.0.0.and..not.trip_ifinit) then
         do il = 1, trip_nline
            do jl=1, trip_nmode(il)
               trip_rphs(jl,1,il) = 2.0*pi*trip_ran2(il)
            enddo
         enddo
      endif

!     time dependent part
      do il = 1, trip_nline
         itmp = int(time/trip_tdt(il))
         call bcast(itmp,ISIZE) ! just for safety
         do kl= trip_ntdt+1, itmp
            do jl= trip_nset_max,3,-1
               call copy(trip_rphs(1,jl,il),trip_rphs(1,jl-1,il),
     $              trip_nmode(il))
            enddo
            do jl=1, trip_nmode(il)
               trip_rphs(jl,2,il) = 2.0*pi*trip_ran2(il)
            enddo
         enddo
      enddo
      
!     update time interval
      trip_ntdt_old = trip_ntdt
      trip_ntdt = itmp

#ifdef DEBUG
      ! for testing
      ! to output refinement
      icalldl = icalldl+1
      call io_file_freeid(iunit, ierr)
      write(str1,'(i3.3)') NID
      write(str2,'(i3.3)') icalldl
      open(unit=iunit,file='trp_rps.txt'//str1//'i'//str2)

      do il=1,trip_nmode(1)
         write(iunit,*) il,trip_rphs(il,1:4,1)
      enddo

      close(iunit)
#endif

      return
      end subroutine
!=======================================================================
!> @brief A simple portable random number generator
!! @ingroup tripping
!! @details  Requires 32-bit integer arithmetic. Taken from Numerical
!!   Recipes, William Press et al. Gives correlation free random
!!   numbers but does not have a very large dynamic range, i.e only
!!   generates 714025 different numbers. Set seed negative for
!!   initialization
!! @param[in]   il      line number
!! @return      ran
      real function trip_ran2(il)
      implicit none

      include 'SIZE'
      include 'TRIPD'
      
!     argument list
      integer il

!     local variables
      integer iff(trip_nline_max), iy(trip_nline_max)
      integer ir(97,trip_nline_max)
      integer m,ia,ic,j
      real rm
      parameter (m=714025,ia=1366,ic=150889,rm=1./m)
      save iff,ir,iy
      data iff /trip_nline_max*0/
!-----------------------------------------------------------------------
!     Initialize
      if (trip_seed(il).lt.0.or.iff(il).eq.0) then
         iff(il)=1
         trip_seed(il)=mod(ic-trip_seed(il),m)
         do j=1,97
            trip_seed(il)=mod(ia*trip_seed(il)+ic,m)
            ir(j,il)=trip_seed(il)
         end do
         trip_seed(il)=mod(ia*trip_seed(il)+ic,m)
         iy(il)=trip_seed(il)
      end if
      
!     Generate random number
      j=1+(97*iy(il))/m
      iy(il)=ir(j,il)
      trip_ran2=iy(il)*rm
      trip_seed(il)=mod(ia*trip_seed(il)+ic,m)
      ir(j,il)=trip_seed(il)

      end function
!=======================================================================
!> @brief Generate forcing alonf 1D line
!! @ingroup tripping
!! @param[in] ifreset    reset flag
      subroutine trip_frcs_get(ifreset)
      implicit none

      include 'SIZE'
      include 'INPUT'
      include 'TSTEP'
      include 'TRIPD'

!     argument list
      logical ifreset

#ifdef TRIP_PR_RST
!     variables necessary to reset pressure projection for P_n-P_n-2
      integer nprv(2)
      common /orthbi/ nprv

!     variables necessary to reset velocity projection for P_n-P_n-2
      include 'VPROJ'
#endif      
!     local variables
      integer il, jl, kl, ll
      integer istart
      real theta0, theta

#ifdef DEBUG
      character*3 str1, str2
      integer iunit, ierr
      ! call number
      integer icalldl
      save icalldl
      data icalldl /0/
#endif
!-----------------------------------------------------------------------
!     reset all
      if (ifreset) then
         if (trip_tiamp.gt.0.0) then
            istart = 1
         else
            istart = 2
         endif
         do il= 1, trip_nline
            do jl = istart, trip_nset_max
               call rzero(trip_frcs(1,jl,il),trip_npoint(il))
               do kl= 1, trip_npoint(il)
                  theta0 = 2*pi*trip_prj(kl,il)
                  do ll= 1, trip_nmode(il)
                     theta = theta0*ll
                     trip_frcs(kl,jl,il) = trip_frcs(kl,jl,il) +
     $                    sin(theta+trip_rphs(ll,jl,il))
                  enddo
               enddo
            enddo
         enddo
!     rescale time independent part
         if (trip_tiamp.gt.0.0) then
            do il= 1, trip_nline
               call cmult(trip_frcs(1,1,il),trip_tiamp,trip_npoint(il))
            enddo
         endif
      else
!     reset only time dependent part if needed
         if (trip_ntdt.ne.trip_ntdt_old) then
#ifdef TRIP_PR_RST
!     reset projection space
!     pressure
            if (int(PARAM(95)).gt.0) then
               PARAM(95) = ISTEP
               nprv(1) = 0      ! veloctiy field only
            endif
!     velocity
            if (int(PARAM(94)).gt.0) then
               PARAM(94) = ISTEP!+2
               ivproj(2,1) = 0
               ivproj(2,2) = 0
               if (IF3D) ivproj(2,3) = 0
            endif
#endif
            do il= 1, trip_nline
               do jl= trip_nset_max,3,-1
                  call copy(trip_frcs(1,jl,il),trip_frcs(1,jl-1,il),
     $                 trip_npoint(il))
               enddo
               call rzero(trip_frcs(1,2,il),trip_npoint(il))
               do jl= 1, trip_npoint(il)
                  theta0 = 2*pi*trip_prj(jl,il)
                  do kl= 1, trip_nmode(il)
                     theta = theta0*kl
                     trip_frcs(jl,2,il) = trip_frcs(jl,2,il) +
     $                    sin(theta+trip_rphs(kl,2,il))
                  enddo
               enddo
            enddo
         endif
      endif
      
!     get tripping for current time step
      if (trip_tiamp.gt.0.0) then
         do il= 1, trip_nline
           call copy(trip_ftrp(1,il),trip_frcs(1,1,il),trip_npoint(il))
         enddo
      else
         do il= 1, trip_nline
            call rzero(trip_ftrp(1,il),trip_npoint(il))
         enddo
      endif
!     interpolation in time
      do il = 1, trip_nline
         theta0= time/trip_tdt(il)-real(trip_ntdt)
         if (theta0.gt.0.0) then
            theta0=theta0*theta0*(3.0-2.0*theta0)
            !theta0=theta0*theta0*theta0*(10.0+(6.0*theta0-15.0)*theta0)
            do jl= 1, trip_npoint(il)
               trip_ftrp(jl,il) = trip_ftrp(jl,il) +
     $              trip_tdamp*((1.0-theta0)*trip_frcs(jl,3,il) +
     $              theta0*trip_frcs(jl,2,il))
            enddo
         else
            theta0=theta0+1.0
            theta0=theta0*theta0*(3.0-2.0*theta0)
            !theta0=theta0*theta0*theta0*(10.0+(6.0*theta0-15.0)*theta0)
            do jl= 1, trip_npoint(il)
               trip_ftrp(jl,il) = trip_ftrp(jl,il) +
     $              trip_tdamp*((1.0-theta0)*trip_frcs(jl,4,il) +
     $              theta0*trip_frcs(jl,3,il))
            enddo
         endif
      enddo


#ifdef DEBUG
      ! for testing
      ! to output refinement
      icalldl = icalldl+1
      call io_file_freeid(iunit, ierr)
      write(str1,'(i3.3)') NID
      write(str2,'(i3.3)') icalldl
      open(unit=iunit,file='trp_fcr.txt'//str1//'i'//str2)

      do il=1,trip_npoint(1)
         write(iunit,*) il,trip_prj(il,1),trip_ftrp(il,1),
     $        trip_frcs(il,1:4,1)
      enddo

      close(iunit)
#endif
      
      return
      end subroutine
!=======================================================================
!> @brief Compute tripping forcing
!! @ingroup tripping
!! @param[in] 

cc AT:
      subroutine trip_comp(ix,iy,iz,iel)
      
      include 'SIZE'
      include 'NEKUSE'
      include 'PARALLEL'
      include 'TRIPD'

      integer ix,iy,iz
      integer ipos,iel,il
      real ffn

      ffn = 0.0
      
      do il= 1, trip_nline
         ipos = trip_map(ix,iy,iz,iel,il)
         ffn = trip_ftrp(ipos,il)*trip_fsmth(ix,iy,iz,iel,il)
         
         ffx = ffx - ffn*sin(trip_rota(il))
         ffy = ffy + ffn*cos(trip_rota(il))
      enddo
      
      return
      end subroutine
