#! /bin/bash
#clear old file if exist
> test.txt
#show date and time in the log
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" | tee -a test.txt
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt" | tee -a test.txt
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" | tee -a test.txt
#smartctl script time
echo "=====================================================================================================================================" | tee -a test.txt
echo "DRIVE::Temp::Model::Serial::Health Status::Read Error::Bad Sectors" | awk -F:: '{printf "%-7s%-6s%-22s%-20s%-22s%-15s%-15s\n", $1, $2, $3, $4, $5, $6, $7}' | tee -a test.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" | tee -a test.txt
for i in $(lsblk | grep -E "disk" | awk '{print $1}')
do
DevSupport=`smartctl -a /dev/$i | awk '/SMART support is:/{print $0}' | awk '{print $4}' | tail -1`
if [ "$DevSupport" == "Enabled" ]
then
DevTemp=`smartctl -a /dev/$i | awk '/Temperature/{print $0}' | awk '{print $10 "C"}'`
DevSerNum=`smartctl -a /dev/$i | awk '/Serial Number:/{print $0}' | awk '{print $3}'`
DevName=`smartctl -a /dev/$i | awk '/Device Model:/{print $0}' | awk '{print $4}'`
DevStatus=`smartctl -a /dev/$i | awk '/SMART overall-health/{print $0}' | awk '{print $1" "$5" "$6}'`
DevReadErrorRate=`smartctl -a /dev/$i | awk '/Raw_Read_Error_Rate/{print $0}' | awk '{print $10}'`
DevReallocatedSectorCT=`smartctl -a /dev/$i | awk '/Reallocated_Sector_Ct/{print $0}' | awk '{print $10}'`
echo [$i]::$DevTemp::$DevName::$DevSerNum::$DevStatus::$DevReadErrorRate::$DevReallocatedSectorCT | awk -F:: '{printf "%-7s%-6s%-22s%-20s%-22s%-15s%-15s\n", $1, $2, $3, $4, $5, $6, $7}' | >
fi
done
##
# now find drives that don't have SMART enabled and warn user about these drives
##
echo "--------------------------------------------------------------------------------------------------------------------------------------" | tee -a test.txt
for i in $(lsblk | grep -E "disk" | awk '{print $1}')
do
DevSupport=`smartctl -a /dev/$i | awk '/SMART support is:/{print $0}' | awk '{print $4}' | tail -1`
if [ "$DevSupport" != "Enabled" ]
then
echo [$i]::$DevSupport | awk -F:: '{printf "%-6s **ERROR!!! SMART Support Status: %s\n", $1, $2}' | tee -a test.txt
fi
done
echo "========================================================================================================================================" | tee -a test.txt
#send email here
su -c '/bin/bash /home/USERNAME/Documents/scripts/mail.sh' - USERNAME
