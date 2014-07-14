#!/bin/bash
#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#  Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#  Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#  You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
. "$( dirname "${BASH_SOURCE[0]}" )/config" 
setup_two_read_write_test

if [ "$OBJECTBENCH_SYSTEM_UNDER_TEST" = "" ] ; then 
  echo " set OBJECTBENCH_SYSTEM_UNDER_TEST"
  exit 0
fi

# The small file is
#  39K Nov  8  2013 11304_1#86_phix_quality_error.txt
export OB_D_BASE="/local/scratch01/jb23/src_files/"
export OBJECTBENCH_INITAL_FILES="${OB_D_BASE}11310_2#56_phix_quality_cycle_surv.txt ${OB_D_BASE}6.5GB"
export OBJECTBENCH_INITAL_DISTRIBUTION="1,0"
export OBJECTBENCH_TEST_WRITE_DISTRIBUTION="$OBJECTBENCH_INITAL_DISTRIBUTION"
export OBJECTBENCH_RUN_NAME="_Unique_GET_PUT_SMALLFILE_"
export OBJECTBENCH_TEST_WORKLOAD_DISTRIBUTION="0,1,0"

#Single Unique GET Performance w/ small object
#Single Unique PUT Performance w/small object
for loop in `seq 1 10`
do
  echo "Small file $loop"
  two_phase_test
done
write_errors
#Single Unique seek Performance w/small object
# Not implemented
#Single Unique delete Performance w/small object
# Not implemented
export OBJECTBENCH_INITAL_DISTRIBUTION="0,1"
export OBJECTBENCH_TEST_WRITE_DISTRIBUTION="$OBJECTBENCH_INITAL_DISTRIBUTION"
export OBJECTBENCH_RUN_NAME="_Unique_GET_PUT_LARGEFILE_"
export OBJECTBENCH_TEST_WORKLOAD_DISTRIBUTION="0,1,0"
#Single Unique GET Performance w/ large object
#Single Unique PUT Performance w/large object
for loop in `seq 1 10`
do
  echo "Large file $loop"
  two_phase_test
done
write_errors
#Single Unique seek Performance w/large object
# Not implemented
#Single Unique delete Performance w/large object
# Not implemented

