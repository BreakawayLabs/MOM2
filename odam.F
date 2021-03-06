#ifdef ramdrive
      subroutine ostart (lu, fname, ntot, nwrec, nbuf)
c
c=======================================================================
c
c     ramdrive section uses memory as a ramdisk
c
c     check for validity of unitnumber and show memory requirement
c
c     lu    = i/o unit number associated with "fname"
c     fname = filename 
c     ntot  = total length of unit, in words
c     nwrec = number of words in the record on the unit
c     nbuf  = number of buffers for the unit
c=======================================================================
c
      character*(*) fname
# include "param.h"
# include "iounit.h"
      if (lu .ne. kflds .and. lu .ne. latdisk(1) .and. 
     &                        lu .ne. latdisk(2)) then
        write (stdout,'(/1x,a,/,11x,a,/11x,a,i10)')
     &  '=>Error: ostart... when using the "ramdrive" option, only'
     &,' units "kflds","latdisk(1)" or "latdisk(2)" are allowed'
     &,' you were trying to open unit #',lu 
	stop '=>ostart'
      endif
      write (stdout,'(/a,a,a,1pg10.3,a)')
     & ' Memory resource for file ',fname,' = ',ntot*1.e-6,' (MW)'
      return
      end
c
      subroutine ofind (lu, nwrs, nrec)
      return
      end
c
      subroutine oclose (lu)
      return
      end


      subroutine getrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     get velocity and tracer data from ramdisk latitude row "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      parameter (nsl = nslab*jmt,  ntb=2*nsl*(1-jmw/jmt)+1)
      parameter (ntrac=nvar-2)
      dimension sdisk(ntb), u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
      save sdisk
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	if (lu .eq. latdisk(1)) then
          ns = nfrst
	else
          ns = nsl + nfrst
	endif
        call getlat (sdisk(ns), u, t)
      else
        write (stdout,*) '=>Error: unit ',lu,' is not allowed. nrec='
     &, nrec
	stop '=>getrow'
      endif
      return

      entry putrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     put velocity and tracer data to ramdisk latitude row "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	if (lu .eq. latdisk(1)) then
          ns   = nfrst
	else
          ns   = nsl + nfrst
	endif
        call putlat (sdisk(ns), u, t)
      else
        write (stdout,*) '=>Error: unit ',lu,' is not allowed. jrow='
     &, nrec
	stop '=>putrow'
      endif
      return
      end

      subroutine getlat (disk, u, t)
c
c-----------------------------------------------------------------------
c     copy contiguous portions of virtual disk to non-contiguous
c     portions of memory.
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac), disk(imt,km,nvar)
      do n=1,2
        do k=1,km
	  do i=1,imt
	    u(i,k,1,n) = disk(i,k,n)
	  enddo
	enddo
      enddo
      do n=1,ntrac
        do k=1,km
	  do i=1,imt
	    t(i,k,1,n) = disk(i,k,n+2)
	  enddo
	enddo
      enddo
      return
      end
      
      subroutine putlat (disk, u, t)
c
c-----------------------------------------------------------------------
c     copy non-contiguous portions of memory to contiguous portions
c     of virtual disk. 
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac), disk(imt,km,nvar)
      do n=1,2
        do k=1,km
	  do i=1,imt
	    disk(i,k,n) = u(i,k,1,n)
	  enddo
	enddo
      enddo
      do n=1,ntrac
        do k=1,km
	  do i=1,imt
	    disk(i,k,n+2) = t(i,k,1,n)
	  enddo
	enddo
      enddo
      return
      end


      subroutine oget (lu, nwrs, nrec, a)
c
c=======================================================================
c     get 2D field data from ramdisk record "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = two dimensional field
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      parameter (n12=nwds*nkflds)
      dimension sdisk(n12), a(nwds)
      save sdisk
c
      if (lu .ne. kflds) then
        write (stdout,*) '=>Error: unit # ',lu,' not allowed. rec=',nrec
	stop '=>oget'
      else
        ns = (nrec-1)*nwrs + 1
        ne = ns + nwrs - 1
        do n=ns,ne
          a(n-ns+1) = sdisk(n)
        enddo
      endif
      return

      entry oput (lu, nwrs, nrec, a)
c
c=======================================================================
c     put 2D field data to ramdisk record "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = two dimensional field
c=======================================================================
c
c
      if (lu .ne. kflds) then
        write (stdout,*) '=>Error: unit # ',lu,' not allowed. rec=',nrec
	stop '=>oget'
      else
        ns = (nrec-1)*nwrs + 1
        ne = ns + nwrs - 1
        do n=ns,ne
          sdisk(n) = a(n-ns+1)
        enddo
      endif
      return
      end
      
#endif




      subroutine copy_all_rows (ifrom, ito)
c
c-----------------------------------------------------------------------
c     copy all latitude rows from time level "ifrom" to time level "ito"
c     for prognostic variables in the MW
c     
c     author:  r.c.pacanowski   e-mail  rcp@gfdl.gov
c-----------------------------------------------------------------------
c
#include "param.h"
#include "mw.h"
      call tic ('copy_all_rows', 'within the MW')
      do n=1,2
        do j=1,jmw
	  do k=1,km
	    do i=1,imt
	      u(i,k,j,n,ito) = u(i,k,j,n,ifrom)
	    enddo
	  enddo
	enddo
      enddo
      do n=1,nvar-2
        do j=1,jmw
	  do k=1,km
	    do i=1,imt
	      t(i,k,j,n,ito) = t(i,k,j,n,ifrom)
	    enddo
	  enddo
	enddo
      enddo
      call toc ('copy_all_rows', 'within the MW')
      return
      end
c
      subroutine euler_shuffle
c
c-----------------------------------------------------------------------
c     after the second pass of an euler backward step, exchange "tau"
c     and "tau+1" data, after shuffling, data will be in proper position
c     for the next time step.
c     
c     author:  r.c.pacanowski   e-mail  rcp@gfdl.gov
c-----------------------------------------------------------------------
c
#include "param.h"
#include "mw.h"
      call tic ('euler_shuffle', 'within the MW')
      do n=1,2
        do j=1,jmw
	  do k=1,km
	    do i=1,imt
	      temp             = u(i,k,j,n,tau)
	      u(i,k,j,n,tau)   = u(i,k,j,n,taup1)
	      u(i,k,j,n,taup1) = temp
	    enddo
	  enddo
	enddo
      enddo
      do n=1,nt
        do j=1,jmw
	  do k=1,km
	    do i=1,imt
	      temp             = t(i,k,j,n,tau)
	      t(i,k,j,n,tau)   = t(i,k,j,n,taup1)
	      t(i,k,j,n,taup1) = temp
	    enddo
	  enddo
	enddo
      enddo
      call toc ('euler_shuffle', 'within the MW')
      return
      end




#ifdef crayio
      subroutine  ostart (lu, fname, ntot, nwrec, nbuf)
c
c=======================================================================
c
c     cray i/o section using getwa/putwa
c
c     assign a unit number ot "fname" and show resource requriements
c     
c     fname = filename 
c     lu    = i/o unit number associated with "fname"
c     ntot  = total length of unit, in words
c     nwrec = number of words in the record on the unit
c     nbuf  = number of buffers supplied to the unit
c=======================================================================
c
      character*(*) fname
      character*80 optlst
# include "param.h"
# include "iounit.h"
      write (optlst,'(a,i10,a)')
     &  'word buffer:words=',nwrec,' sds scratch novfl'
      call getunit (lu, fname, optlst) 
      write (stdout,'(/a,a,a,1pg10.3,a)')
     & ' Cray Word i/o disk resource for file ',fname
     &,' = ',ntot*1.e-6,' (MW)'
      return
c
      entry oclose (lu)
      call wclose (lu)
      return
c
      entry ofind (lu, nwrs, nrec)
      call seek (lu, (nrec-1)*nwrs+1, nwrs)
      return
      end
      
      subroutine getrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     get velocity and tracer data from latitude row "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
# include "param.h"
      parameter (ntrac=nvar-2)
# include "iounit.h"
c
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
        call getlat (lu, u, t, nfrst, nwrs)
      else
        write (stdout,*) '=>Error: unit #',lu,' not allowed. rec=',nrec
	stop '=>getrow'
      endif
      return
      end

      subroutine getlat (lu, u, t, nfrst, nwrs)
c
c-----------------------------------------------------------------------
c     transfer contiguous portions of disk to non-contiguous
c     portions of memory.
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
      nwords = nwrs / nvar
      do n=1,2
        nfirst = nfrst + (n-1)*imtkm
        call getwa (lu, u(1,1,1,n), nfirst, nwords)
      enddo
      do n=1,ntrac
        nfirst = nfrst + (2+n-1)*imtkm
        call getwa (lu, t(1,1,1,n), nfirst, nwords)
      enddo
      return
      end

      subroutine oget (lu, nwrs, nrec, a)
c
c=======================================================================
c     get data from record "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = array where data will go
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      dimension a(nwrs)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	write (stdout,*) '=>Error: unit #',lu, ' not allowed. rec=',nrec
        stop '=>oget'
      else
        call getwa (lu, a, nfrst, nwrs)
      endif
      return
      end


      subroutine putrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     put velocity and tracer data to latitude row "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
# include "param.h"
      parameter (ntrac=nvar-2)
# include "iounit.h"
c
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
        call putlat (lu, u, t, nfrst, nwrs)
      else
        write (stdout,*) '=>Error: unit #',lu,' not allowed. rec=',nrec
	stop '=>putrow'
      endif
      return
      end

      subroutine putlat (lu, u, t, nfrst, nwrs)
c
c-----------------------------------------------------------------------
c     transfer non-contiguous portions of memory to contiguous portions
c     of disk. 
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
      nwords = nwrs / nvar
      do n=1,2
        nfirst = nfrst + (n-1)*imtkm
        call putwa (lu, u(1,1,1,n), nfirst, nwords)
      enddo
      do n=1,ntrac
        nfirst = nfrst + (2+n-1)*imtkm
        call putwa (lu, t(1,1,1,n), nfirst, nwords)
      enddo
      return
      end

      subroutine oput (lu, nwrs, nrec, a)
c
c=======================================================================
c     put data to record "nrec"
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = array where data will go
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      dimension a(nwrs)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	write (stdout,*) '=>Error: unit #',lu, ' not allowed. rec=',nrec
        stop '=>oput'
      else
        call putwa (lu, a, nfrst, nwrs)
      endif
      return
      end
#endif




#if defined fio
      subroutine  ostart (lu, fname, ntot, nwrec, nbuf)
c
c=======================================================================
c
c     fortran i/o section
c
c     assign a unit number ot "fname" and show resource requriements
c     
c     fname = filename 
c     lu    = i/o unit number associated with "fname"
c     ntot  = total length of unit, in words
c     nwrec = number of words in the record on the unit
c     nbuf  = number of buffers supplied to the unit
c=======================================================================
c
      character*(*) fname
      character*80 optlst
# include "param.h"
# include "iounit.h"
      if (fname .eq. 'latdisk1' .or. fname .eq. 'latdisk2') then
        lenblk = nwrec / nvar
      else
        lenblk = nwrec
      endif
      write (optlst,'(a,i10)') 'direct recl:words = ',lenblk
      call getunit (lu, fname, optlst) 
      write (stdout,'(/a,a,a,1pg10.3,a)')
     & ' Direct access disk resource for file ',fname,' = '
     &, ntot*1.e-6,' (MW)'
      return
c
      entry oclose (lu)
      return
c
      entry ofind (lu, nwrs, nrec)
      return
      end

      
      subroutine getrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     get velocity and tracer data from latitude row "nrec" on disk
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
# include "param.h"
      parameter (ntrac=nvar-2)
# include "iounit.h"
c
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
        call getlat (lu, u, t, nfrst, nwrs)
      else
        write (stdout,*) '=>Error: unit #',lu,' not allowed. rec=',nrec
	stop '=>getrow'
      endif
      return
      end


      subroutine getlat (lu, u, t, nfrst, nwrs)
c
c-----------------------------------------------------------------------
c     transfer contiguous portions of disk to non-contiguous
c     portions of memory.
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
      nwords = nwrs / nvar
      nfirst = (nfrst-1)/nwords+1
      do n=1,2
        nrec = nfirst + n - 1
	read (lu, rec=nrec) ((u(i,k,1,n),i=1,imt),k=1,km)
      enddo
      nfirst = nfirst + 2  - 1
      do n=1,ntrac
        nrec = nfirst + n
	read (lu, rec=nrec) ((t(i,k,1,n),i=1,imt),k=1,km)
      enddo
      return
      end

      subroutine oget (lu, nwrs, nrec, a)
c
c=======================================================================
c     get data from record "nrec" on disk
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = array where data will go
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      dimension a(nwrs)
c
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	write (stdout,*) '=>Error: unit #',lu, ' not allowed. rec=',nrec
        stop '=>oget'
      else
        read (lu, rec=nrec) a
      endif
      return
      end

      
      subroutine putrow (lu, nwrs, nrec, u, t)
c
c=======================================================================
c     put velocity and tracer data to latitude row "nrec" on disk
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = latitude row
c         u     = velocities
c         t     = tracers
c         ntrac = number of tracers
c=======================================================================
c
# include "param.h"
      parameter (ntrac=nvar-2)
# include "iounit.h"
c
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
c
      nfrst = (nrec-1)*nwrs + 1
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
        call putlat (lu, u, t, nfrst, nwrs)
      else
        write (stdout,*) '=>Error: unit #',lu,' not allowed. rec=',nrec
	stop '=>getrow'
      endif
      return
      end


      subroutine putlat (lu, u, t, nfrst, nwrs)
c
c-----------------------------------------------------------------------
c     transfer non-contiguous portions of memory to
c     contiguous portions of disk. 
c-----------------------------------------------------------------------
c
#include "param.h"
      parameter (ntrac=nvar-2)
      dimension u(imt,km,jmw,2), t(imt,km,jmw,ntrac)
      nwords = nwrs / nvar
      nfirst = (nfrst-1)/nwords+1
      do n=1,2
        nrec = nfirst + n - 1
	write (lu, rec=nrec) ((u(i,k,1,n),i=1,imt),k=1,km)
      enddo
      nfirst = nfirst + 2  - 1
      do n=1,ntrac
        nrec = nfirst + n
	write (lu, rec=nrec) ((t(i,k,1,n),i=1,imt),k=1,km)
      enddo
      return
      end

      subroutine oput (lu, nwrs, nrec, a)
c
c=======================================================================
c     put data to record "nrec" on disk
c
c         lu    = i/o unit number associated with "fname"
c         nwrs  = number of words to read
c         nrec  = record
c         a     = array where data will go
c=======================================================================
c
# include "param.h"
# include "iounit.h"
c
      dimension a(nwrs)
c
      if (lu .eq. latdisk(1) .or. lu .eq. latdisk(2)) then
	write (stdout,*) '=>Error: unit #',lu, ' not allowed. rec=',nrec
        stop '=>oget'
      else
        write (lu, rec=nrec) a
      endif
      return
      end

#endif
      

