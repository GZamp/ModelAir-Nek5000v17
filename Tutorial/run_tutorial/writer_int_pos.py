# Example script for reading int_fld data
# Kept similar to pymech
import struct
import numpy as np

class point:
    """class defining point variables"""

    def __init__(self,ldim):
        self.pos = np.zeros((ldim))

class pset:
    """class containing data of the point collection"""

    def __init__(self,ldim,npoints):
        self.ldim = ldim
        self.npoints = npoints
        self.pset = [point(ldim) for il in range(npoints)]


def set_pnt_pos(data,il,lpos):
    """set position of the single point"""
    lptn = data.pset[il]
    data_pos = getattr(lptn,'pos')
    for jl in range(data.ldim):
            data_pos[jl] =  lpos[jl]

def write_int_pos(fname,wdsize,emode,data):
    """ write point positions to the file"""
    # open file
    outfile = open(fname, 'wb')

    # word size
    if (wdsize == 4):
        realtype = 'f'
    elif (wdsize == 8):
        realtype = 'd'

    # header
    header = '#iv1 %1i %1i %10i ' %(wdsize,data.ldim,data.npoints)
    header = header.ljust(32)
    outfile.write(header.encode('utf-8'))

    # write tag (to specify endianness)
    #etagb = struct.pack(emode+'f', 6.54321)
    #outfile.write(etagb)
    outfile.write(struct.pack(emode+'f', 6.54321))

    #write point positions
    for il in range(data.npoints):
        lptn = data.pset[il]
        data_pos = getattr(lptn,'pos')
        outfile.write(struct.pack(emode+data.ldim*realtype, *data_pos))
    
if __name__ == "__main__":
    # initialise variables
    fname = 'int_pos'
    wdsize = 8
    # little endian
    emode = '<'
    # big endian
    #emode = '<'

    # set of points
    npointsx = 100
    npointsy = 100

    # create point coordinates
    ptx = np.linspace(0.25,1.25,npointsx)
    pty = np.linspace(0.0,1.0,npointsy)
    ptz = 0

    # allocate space
    ldim = 3
    npoints = npointsx*npointsy
    data = pset(ldim,npoints)
    print('Allocated {0} points'.format(npoints))

    # initialise point position buffer
    lpos = np.zeros(data.ldim)

    # assign point structure
    npoints = 0
    for ix in range(npointsx):
        for jy in range(npointsy):
            lpos[0] = ptx[ix]
            lpos[1] = pty[jy]
            lpos[2] = ptz
            set_pnt_pos(data,npoints,lpos)
            npoints = npoints + 1

    # write points to the file
    write_int_pos(fname,wdsize,emode,data)
