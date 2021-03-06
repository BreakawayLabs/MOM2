       subroutine amask
c
c-----------------------------------------------------------------------
c      define an arbitrary atmospheric land/sea mask defined at the
c      main atmospheric grid point coordinates.
c
c      note: this land/sea mask does not have to match the ocean
c            land/sea mask. 
c     
c      coded by:      r. c. pacanowski      e-mail=> rcp@gfdl.gov
c-----------------------------------------------------------------------
c
#include "param.h"
#include "csbc.h"
c
c      "levind.h" and "coord.h" are normally not needed but
c       are brought in to make the test case atmosphere land/sea mask
c
#include "coord.h"
#include "levind.h"
c
c     discretize the ocean land/sea mask to the atmosphere grid
c     resolution for the test case. assume the atmosphere land/sea
c     mask is to be defined on the SST grid (nabco=6).
c
      do jj=1,jma
        j = indp (abcgy(jj), yt, jmt)
        do ii=2,imap2-1
          i = indp (abcgx(ii), xt, imt)
          if (kmt(i,j) .eq. 0) then
            aland(ii,jj) = 0
          else
            aland(ii,jj) = 1
          endif
        enddo
c
c       apply the cyclic condition
c
        aland(1,jj)     = aland(imap2-1,jj)
        aland(imap2,jj) = aland(2,jj)
      enddo
c
c     print out the atmospheric land/sea mask
c
      write (6,9000)
      call imatrx (aland, imap2, 1, imap2, -1, -jma, 1)
      return
9000  format (/,1x,' Atmospheric land/sea mask follows:'/)
      end

