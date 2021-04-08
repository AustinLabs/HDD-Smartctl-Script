# HDD-Smartctl-Script
Bash script used to read smartctl info and email whether passing or failing. 

can also be run from crontab
`sudo crontab -e` 
add the following: 
```@daily /bin/bash /home/USERNAME/Documents/scripts/hddhealth.sh
