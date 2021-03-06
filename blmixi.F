      subroutine blmixi
#if defined bryan_lewis_vertical || defined bryan_lewis_horizontal
c
c-----------------------------------------------------------------------
c     Reference:
c     A Water Mass Model of the World Ocean  K. Bryan, L.J. Lewis
c     JGR, vol 84, No. C5, May 20, 1979
c-----------------------------------------------------------------------
c
# include "param.h"
# include "coord.h"
# include "hmixc.h"
# include "vmixc.h"
c
      data afkph, dfkph, sfkph, zfkph /0.8, 1.05, 4.5e-5, 2500.0e2/
c
      namelist /blmix/  Ahv, Ahh
#ifdef bryan_lewis_vertical
c
c------------------------------------------------------------------------
c     Use Bryan & Lewis values for vertical tracer diffusion
c     Ahv range of 0.3 to 1.3, crossover at 2500m.
c------------------------------------------------------------------------
c
c     compute depth dependent vertical diffusion coefficients for
c     tracers using the relationship of Bryan and Lewis
c
      pi = 4.0 * atan(1.0)
c
      do k=1,km
        Ahv(k) = (afkph + (dfkph/pi)*(atan(sfkph*(zw(k) - zfkph))))
      end do

#endif
#ifdef bryan_lewis_horizontal
c
c------------------------------------------------------------------------
c     compute depth dependent horizontal diffusion coefficients for
c     tracers using the relationship of Bryan and Lewis
c------------------------------------------------------------------------
c
      ahs = 5.0e+3
      ahb = 1.0e+3
      do k=1,km
        Ahh(k) = (ahb + (ahs - ahb)*exp(-zt(k)/50000.0))*1.0e4
      end do
#endif
c
      write (stdout,'(/a/)')
     &  'B R Y A N - L E W I S   M I X I N G   C O E F F S'
c
      call getunit (ioun, 'namelist', 'fsr')
      read  (ioun, blmix)
      write (stdout,blmix)
      call relunit (ioun)
c
      write (stdout,'(/)')
#endif      
      return
      end
