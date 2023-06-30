#######################################################################################################
# Automated Script to execute sacapture, daexport, and dbexport                                       #
#                                                                                                     #
# Date Created: 04/22/2020                                                                            #
# Last Updated: 05/21/2020                                                                            #
# Authors: Jeffrey Bote, Paul John Encina, Terrence Bailey Hidalgo, Angelique Mingoa                  #
#                                                                                                     #
# Usage: Make sure that you're using lawson ID and invoked . cv to initiate the environment variables #
#        execute by running, python sa_db_daexport.py in the command line                             #
#######################################################################################################


# ------------------------------------------------------------------------------------------------------
# Import modules
# ------------------------------------------------------------------------------------------------------

from datetime import date
import os
import subprocess
import sys
import re
import time
import shutil
import getpass
import sys

# ------------------------------------------------------------------------------------------------------
# Set variables
# ------------------------------------------------------------------------------------------------------

today = date.today()
curdate = today.strftime("%m%d%Y")
base_dir = r"/opt/landmark/src/auto_scripts/data_export/"
regex = r"CLOUD[-]\d{5,6}"
os.chdir(base_dir)
g_jtno = ""
curuser = getpass.getuser()


# ------------------------------------------------------------------------------------------------------
# Check if jtno is in valid format
# ------------------------------------------------------------------------------------------------------

def check(jtno):
    if (re.search(regex, jtno, re.I)):
        return True
    else:
        return False


def get_hostname():
    p1_host = subprocess.run(r'echo $HOSTNAME | grep -Po "tam-master\K[^.]+"', shell=True, capture_output=True,
                             text=True)

    if not p1_host.returncode == 0:
        p1_host = str(p1_host.stdout)
        return print(f'Error encountered while retrieving hostname {p1_host}')
    else:
        p1_host = str(p1_host.stdout)
        return p1_host


dir_not_created = True

# ------------------------------------------------------------------------------------------------------
# Check if user is lawson and folder already exists
# ------------------------------------------------------------------------------------------------------
if curuser != "lawson":
    print("Please sudo as lawson user. Current user is " + curuser + "\n")
    sys.exit()
else:
    
        # print("Current user is " + curuser + "\n");
    while dir_not_created:
        jtno = input("Please input the JT number of this request: ").upper()
        if check(jtno):
            path = base_dir + jtno
            isdir = os.path.isdir(path)
            # mkdir = 'mkdir ' + jtno
            g_jtno = jtno

            if isdir == True:
                # print("Folder already exists. Please try another JT number")

                exst = True
                while exst:
                    print("""
                    1. Delete existing directory
                    2. Try another folder name
                    3. Use existing directory
                    4. Exit
                    """)
                    exst = input("Folder already exists. What would you like to do? ")

                    if exst == "1":
                        while True:
                            exst_ans = input(
                                "\nAre you sure you want to delete  " + base_dir + g_jtno + "? \n 1. Yes \n 2. No \n: ")

                            if exst_ans == "1":
                                folderpath = base_dir + jtno
                                shutil.rmtree(folderpath)
                                print("\n" + folderpath + " has been deleted!")
                                exst_ans = False
                                exst = False
                                break

                            elif exst_ans == "2":
                                exst_ans = False
                                break

                            else:
                                print("\n Not a valid choice try again. Please try again")


                    elif exst == "2":
                        exst = False
                        break

                    elif exst == "3":
                        exst = False
                        dir_not_created = False
                        break
                        
                    elif exst == "4":
                        print("\n Exiting script...")
                        exst = False
                        sys.exit()

                    else:
                        print("\n Not Valid Choice Try again")


            else:
                p1 = subprocess.run(['mkdir', jtno], capture_output=True, text=True)
                # os.chdir(path)
                print(f"{jtno} folder has been created. ")
                # os.path.join('home', 'jacob', 'twcSite')
                # new_dir = os.path.join(base_dir, jtno)
                os.chdir(path)
                # print(p1.returncode)           )

                # os.getcwd()
                dir_not_created = False
        else:
            print("Invalid JT number. Please enter correct format. (e.g. CLOUD-12345)")
    # os.chdir(path)


# ------------------------------------------------------------------------------------------------------
# Check if data area is valid
# ------------------------------------------------------------------------------------------------------

def check_dataarea(user_da):
    p1_list = subprocess.run("listprod -da | awk '{print $2}'", shell=True, capture_output=True, text=True, check=True)

    da_list = p1_list.stdout.splitlines()

    da_list.remove('data')
    da_list.remove('gen')
    da_list.remove('hcm')
    da_list.remove('fsm')

    if user_da in da_list:
        return True
    else:
        return False

    # if p1_list.returncode != 0:
    #     p1_list.stderr
    #     return

    # p2_awk = subprocess.run(["awk", "'{print $2}'"], capture_output=True , text=True, input=p1_list.stdout)

    # if p2_awk.returncode != 0:
    #     p2_awk.stderr
    #     return


# print(curdate)


# ------------------------------------------------------------------------------------------------------
# Main Program
# ------------------------------------------------------------------------------------------------------


ans = True

while ans:
    print("""
    1. Perform sacapture
    2. Peform daexport
    3. Peform dbexport
    4. Exit""")
    ans = input("\nWhat would you like to do? ")
    if ans == "1":
        while True:
            print("""
    1. Yes
    2. No
    3. Exit""")
            sa_ans = input("\nAre you sure you would like to perform sacapture? ")

            hostname = str(get_hostname()).rstrip()
            # print(hostname + ": is the hostname")
            
            sa_file = curdate + "_" + hostname + ".sacapture.zip"
            target_file = base_dir + g_jtno + "/" + sa_file
            S3_dir = "s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/data_export/" + hostname + "/" + g_jtno + "/" + sa_file
            sa_log = base_dir + g_jtno + "/" + curdate + "_" + hostname + "_sacapture_result.txt"
            # cmd_hostname = f"perl /var/opt/tam/sa_capture.pl /home/lawson/test/{hostname}-sacapture.zip"

            if sa_ans == "1":
                #p1_sa = subprocess.run(['nohup perl', '/var/opt/tam/sa_capture.pl', target_file, '&'], capture_output=True, text=True, check=True)
                                    
                print('Executing sacapture...\nPlease wait...')
                p1_sa = subprocess.run('nohup perl ' + '/var/opt/tam/sa_capture.pl ' + target_file + ' > ' + sa_log + ' &',
                                    shell=True, close_fds=True, capture_output=True, text=True)
                                    

                print(p1_sa.stdout)

                # print("Sacapture complete!")
                # (output, err) = p1_sa.communicate()

                # p1_sa_status = p1_sa.wait()

                # print("Command output: " + output)
                # print(p1_sa.stderr)
                # print(p1_sa.returncode)
                print(p1_sa.returncode)
                if p1_sa.returncode == 0:
                    print("Sacapture completed!")
                    print("Transferring sacapture file to S3...")
                    # aws s3 cp /home/lawson/test/CSFE1.sacapture.zip s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/csfe1/data/CSFE1.sacapture.zip
                    p1_s3 = subprocess.run(['aws', 's3', 'cp', target_file, S3_dir], capture_output=True, text=True,
                                        check=True)

                    print(p1_s3.stdout)

                    if p1_s3.returncode == 0:
                        print("Sacapture has successfully been transferred to " + S3_dir)
                        break
                        #sys.exit()
                    else:
                        print(p1_s3.stderr)
                        break

                else:
                    print(p1_sa.stderr)
                    break



            elif sa_ans == "2":
                break
            elif sa_ans == "3":
                sys.exit()
            else:
                print("\n Not a valid choice try again. Please try again")

        # print("Continue executing command ")

    elif ans == "2":
        while True:
            data_area = input("\nSpecify the data area you wish to export data FROM (e.g. csfe1t10_tst_fsm): ")
            if data_area == "":
                print("No data area was entered. Please try again.")
                continue
            else:
                if not check_dataarea(data_area):
                    print("Data area does not exist. Please try again.")
                    continue
                else:
                    print("""
        1. Yes
        2. No
        3. Exit""")
                    da_ans = input(
                        "\nDaexport from " + data_area + " will be performed. Are you sure you would like to proceed? ")
                    if da_ans == "1":
                        print('Executing daexport...\nPlease wait...')
                        # nohup daexport -z 04302020_csfm1c07_tst_fsm_daexport.zip csfm1c07_tst_fsm > 04302020_result_daexport_csfm1c07_tst_fsm.txt &

                        da = data_area
                        da_file = curdate + "_" + da + "_daexport.zip"
                        da_file_loc = base_dir + g_jtno + "/" + da_file
                        da_log = base_dir + g_jtno + "/" + curdate + "_result_" + da + "_da.txt"

                        # close_fds=True
                        # with subprocess.Popen(['nohup', 'daexport', '-z', da_file, da_ans, '>', da_log], close_fds=True, capture_output=True , text=True, check= True) as p1_da:
                        # p1_da = subprocess.run(['daexport', '-z', da_file, data_area], close_fds=True, capture_output=True , text=True)
                        # p1_da = subprocess.Popen('nohup daexport -z ' + da_file + ' ' + da + ' > ' + da_log + ' &', shell=True, close_fds=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                        p1_da = subprocess.run('nohup daexport -z ' + da_file_loc + ' ' + da + ' > ' + da_log + ' &',
                                            shell=True, close_fds=True, capture_output=True, text=True)

                        print(p1_da.stdout)
                        print(p1_da.stderr)
                        print(p1_da.returncode)
                        if p1_da.returncode == 0:
                            source_file = da_file_loc
                            hostname = str(get_hostname()).rstrip()
                            S3_loc = "s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/data_export/" + hostname + "/" + g_jtno + "/" + da_file
                            print("Daexport completed!")
                            print("Transferring exported file to S3...")
                            # aws s3 cp /home/lawson/test/CSFE1.sacapture.zip s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/csfe1/data/CSFE1.sacapture.zip
                            p1_s3 = subprocess.run(['aws', 's3', 'cp', source_file, S3_loc], capture_output=True,
                                                text=True, check=True)

                            print(p1_s3.stdout)

                            if p1_s3.returncode == 0:
                                print("Archived file has successfully been transferred to " + S3_loc)
                                # sys.exit()
                            else:
                                print(p1_s3.stderr)
                                break

                        else:
                            print(p1_da.stderr)
                            break
                        # print(p1_da.stdout)
                        # print(p1_da.stderr)  

                        # print("data file: " + da_file)
                        # print("data log: " + da_log)
                        # time.sleep(2)
                        # print("Daexport is now running in the background...")
                        # print("You may view the log in real-time by executing the following command:")
                        # print("tail -f " + os.getcwd() + "/" + da_log)
                        # sys.exit()


                    elif da_ans == "2":
                        break
                    elif da_ans == "3":
                        sys.exit()
                    else:
                        print("\n Not a valid choice. Please try again.")

                    break
        # listprod -da | awk '{print $2}'

        # print("Continue executing command ")
        # file_name = input("\nPlease provide archive file name for the daexport? ")

        # check_dataarea()

    elif ans == "3":
        while True:
            data_area = input("\nSpecify the data area you wish to export db FROM (e.g. csfe1t10_tst_fsm): ")
            if data_area == "":
                print("No data area was entered. Please try again.")
                continue
            else:
                if not check_dataarea(data_area):
                    print("Data area does not exist. Please try again.")
                    continue
                else:
                    print("""
        1. Yes
        2. No
        3. Exit""")
                    da_ans = input(
                        "\nDbexport from " + data_area + " will be performed. Are you sure you would like to proceed? ")
                    if da_ans == "1":
                        print('Executing dbexport...\nPlease wait...')
                        # nohup daexport -z 04302020_csfm1c07_tst_fsm_daexport.zip csfm1c07_tst_fsm > 04302020_result_daexport_csfm1c07_tst_fsm.txt &

                        da = data_area
                        da_file = curdate + "_" + da + "_dbexport.zip"
                        da_file_loc = base_dir + g_jtno + "/" + da_file
                        da_log = base_dir + g_jtno + "/" + curdate + "_result_" + da + "_db.txt"

                        # p1_da = subprocess.run(['daexport', '-z', da_file, data_area], close_fds=True, capture_output=True , text=True)
                        # p1_da = subprocess.Popen('nohup dbexport -Cvz ' + da_file + ' ' + da + ' > ' + da_log + ' &', shell=True, close_fds=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                        # p1_da = subprocess.run(['nohup', 'dbexport', '-Cvz', da_file, da, '>', da_log, '&'], close_fds=True, capture_output=True , text=True)
                        p1_da = subprocess.run('nohup dbexport -Cvz ' + da_file_loc + ' ' + da + ' > ' + da_log + ' &',
                                            shell=True, close_fds=True, capture_output=True, text=True)

                        print(p1_da.stdout)
                        print(p1_da.stderr)
                        print(p1_da.returncode)
                        if p1_da.returncode == 0:
                            source_file = da_file_loc
                            hostname = str(get_hostname()).rstrip()
                            S3_loc = "s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/data_export/" + hostname + "/" + g_jtno + "/" + da_file
                            print("Dbexport completed!")
                            print("Transferring exported file to S3...")
                            # aws s3 cp /home/lawson/test/CSFE1.sacapture.zip s3://infor-devops-dev-appdata-us-east-1/tam/usem-cloud/csfe1/data/CSFE1.sacapture.zip
                            p1_s3 = subprocess.run(['aws', 's3', 'cp', source_file, S3_loc], capture_output=True,
                                                text=True, check=True)

                            print(p1_s3.stdout)

                            if p1_s3.returncode == 0:
                                print("Archived file has successfully been transferred to " + S3_loc)
                                # sys.exit()
                            else:
                                print(p1_s3.stderr)
                                break

                        else:
                            print(p1_da.stderr)
                            break

                        # print("data file: " + da_file)
                        # print("data log: " + da_log)
                        # time.sleep(2)
                        # print("Dbexport is now running in the backgroud...")
                        # print("You may view the log in real-time by executing the following command:")
                        # print("tail -f " + os.getcwd() + "/" + da_log)
                        # sys.exit()


                    elif da_ans == "2":
                        break
                    elif da_ans == "3":
                        sys.exit()
                    else:
                        print("\n Not a valid choice. Please try again")
                    break

    elif ans == "4":
        print("\nExiting Script")
        ans = False
    else:
        print("\n Not a valid choice. Please try again.")

# ------------------------------------------------------------------------------------------------------
# End of Program
# ------------------------------------------------------------------------------------------------------

