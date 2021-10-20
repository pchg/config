#!/bin/sh

#export CMAKE_ROOT=/home/publique/cmake-2.8.1
export QTDIR=/home/publique/cnrc/qt/Qt-4.6

export PATH=$QTDIR/bin:$CMAKE_ROOT:/usr/local/cnrc/paraview3_10/lib/paraview-3.10:$PATH

export LD_LIBRARY_PATH=$QTDIR/lib:/usr/local/cnrc/paraview3_10/lib/paraview-3.10:/usr/local/cnrc/cgns/lib:/usr/local/cnrc/cgns/hdf5/lib

export LD_RUN_PATH=$QTDIR/lib:/usr/local/cnrc/paraview3_10/lib/paraview-3.10:/usr/local/cnrc/cgns/lib:/usr/local/cnrc/cgns/hdf5/lib

export PV_PLUGIN_PATH=/usr/local/cnrc/paraview3_10/lib/paraview-3.10/plugins

/usr/local/cnrc/paraview3_10/bin/paraview
