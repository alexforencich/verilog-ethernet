#!/bin/sh

#
#  Vivado(TM)
#  ISEWrap.sh: Vivado Runs Script for UNIX
#  Copyright 1986-2022 Xilinx, Inc. All Rights Reserved. 
#  Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved. 
#

cmd_exists()
{
  command -v "$1" >/dev/null 2>&1
}

HD_LOG=$1
shift

# CHECK for a STOP FILE
if [ -f .stop.rst ]
then
echo ""                                        >> $HD_LOG
echo "*** Halting run - EA reset detected ***" >> $HD_LOG
echo ""                                        >> $HD_LOG
exit 1
fi

ISE_STEP=$1
shift

# WRITE STEP HEADER to LOG
echo ""                      >> $HD_LOG
echo "*** Running $ISE_STEP" >> $HD_LOG
echo "    with args $@"      >> $HD_LOG
echo ""                      >> $HD_LOG

# LAUNCH!
$ISE_STEP "$@" >> $HD_LOG 2>&1 &

# BEGIN file creation
ISE_PID=$!

HostNameFile=/proc/sys/kernel/hostname
if cmd_exists hostname
then
ISE_HOST=$(hostname)
elif cmd_exists uname
then
ISE_HOST=$(uname -n)
elif [ -f "$HostNameFile" ] && [ -r $HostNameFile ] && [ -s $HostNameFile ] 
then
ISE_HOST=$(cat $HostNameFile)
elif [ X != X$HOSTNAME ]
then
ISE_HOST=$HOSTNAME #bash
else
ISE_HOST=$HOST     #csh
fi

ISE_USER=$USER

ISE_HOSTCORE=$(awk '/^processor/{print $3}' /proc/cpuinfo | wc -l)
ISE_MEMTOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

ISE_BEGINFILE=.$ISE_STEP.begin.rst
/bin/touch $ISE_BEGINFILE
echo "<?xml version=\"1.0\"?>"                                                                     >> $ISE_BEGINFILE
echo "<ProcessHandle Version=\"1\" Minor=\"0\">"                                                   >> $ISE_BEGINFILE
echo "    <Process Command=\"$ISE_STEP\" Owner=\"$ISE_USER\" Host=\"$ISE_HOST\" Pid=\"$ISE_PID\" HostCore=\"$ISE_HOSTCORE\" HostMemory=\"$ISE_MEMTOTAL\">" >> $ISE_BEGINFILE
echo "    </Process>"                                                                              >> $ISE_BEGINFILE
echo "</ProcessHandle>"                                                                            >> $ISE_BEGINFILE

# WAIT for ISEStep to finish
wait $ISE_PID

# END/ERROR file creation
RETVAL=$?
if [ $RETVAL -eq 0 ]
then
    /bin/touch .$ISE_STEP.end.rst
else
    /bin/touch .$ISE_STEP.error.rst
fi

exit $RETVAL

