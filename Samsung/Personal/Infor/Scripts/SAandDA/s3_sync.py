#######################################################################################################
# Automated Script to sync s3 files to infor shared drive                                             #
# Runs every 5 minutes. Output file can be found under E:\aws_sync_dir                                #
# Date Created: 05/19/2020                                                                            #
# Last Updated: 05/21/2020                                                                            #
# Authors: Jeffrey Bote, Paul John Encina, Terrence Bailey Hidalgo, Angelique Mingoa                  #
#                                                                                                     #
#######################################################################################################

# ------------------------------------------------------------------------------------------------------
# Import modules
# ------------------------------------------------------------------------------------------------------

import subprocess
from datetime import date
import time

# ------------------------------------------------------------------------------------------------------
# Set variables
# ------------------------------------------------------------------------------------------------------

today = date.today()
now = time.localtime()
curdate = today.strftime("%m%d%Y")
curtime = time.strftime("%H:%M:%S", now)
sync_dir = "E:\\aws_sync_dir\\"
sync_log = sync_dir + curdate + "_aws_sync.log"
target_dir = "\\\\infor.com\\shared\\USAL\\Departments\\Development5\\tempshare\\usem_cloud_s3"
s3_dir = "s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/data_export"

# ------------------------------------------------------------------------------------------------------
# Append time of run in log output
# ------------------------------------------------------------------------------------------------------

file = open(sync_log,"a")
file.write('\n\nSync update as of ' + curtime + ': \n')
file.close()

# ------------------------------------------------------------------------------------------------------
# Sync files in s3 to shared drive
# ------------------------------------------------------------------------------------------------------

sync_s3 = subprocess.run('aws ' + 's3 ' + 'sync ' + s3_dir + ' ' + target_dir + ' >> ' + sync_log, shell=True, close_fds=True, capture_output=True, text=True)

# ------------------------------------------------------------------------------------------------------
# End of Program
# ------------------------------------------------------------------------------------------------------
