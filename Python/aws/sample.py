import boto3
import boto3.session
import argparse
import json, re, datetime

from boto3.session import Session

# setup date
set_date = datetime.datetime.now()
date_today = set_date.strftime('%m-%d-%Y')

# parser for force clean up
parser = argparse.ArgumentParser()
parser.add_argument("-f", "--force", action="store_true", help="clean up secgroup by force")
args = parser.parse_args()

# Initiate sesion for PROD
def get_session(sRole):
    sts = boto3.client('sts')
    get_sts = sts.assume_role(RoleArn=sRole,RoleSessionName='p.manansala')
    return boto3.session.Session(
        aws_access_key_id=get_sts['Credentials']['AccessKeyId'],
        aws_secret_access_key=get_sts['Credentials']['SecretAccessKey'],
        aws_session_token=get_sts['Credentials']['SessionToken']
    )

# Check expiration of rule
def get_ip(sRole, sEnv, sRegion, sSecgroup):
    if sEnv == 'prd':
        session = get_session(sRole)
        ec2 = session.resource('ec2', region_name=sRegion)
    else:
        ec2 = boto3.resource('ec2', sRegion)
    security_group = ec2.SecurityGroup(sSecgroup)
    sg_data = security_group.ip_permissions
    for x in sg_data:
        fPort = x['FromPort']
        tPort = x['ToPort']
        for y in x['IpRanges']:
            try:
                get_ip_data = y['CidrIp']
                get_description = y['Description']
                ### search for date format
                find_date = re.search('[0-9]{2}-[0-9]{2}-[0-9]{4}', get_description) 
                if find_date is not None:
                    get_ip_type = get_description.split(',')[1].strip()
                    get_date_data = get_description.split(',')[2].strip()
                    print(date_today, get_date_data, get_ip_type)
                    if ((date_today >= get_date_data) and (get_ip_type == "WFH")):
                        security_group.revoke_ingress(CidrIp=get_ip_data,IpProtocol='tcp',FromPort=fPort,ToPort=tPort)
                        print(sEnv, sRegion, sSecgroup, fPort, get_ip_data, get_description, '--> Clean up complete.')
                    elif get_ip_type == "OFC":
                        print(sEnv, sRegion, sSecgroup, fPort, get_ip_data, get_description, '--> Skipped, office IP.')
                    elif args.force:
                        security_group.revoke_ingress(CidrIp=get_ip_data,IpProtocol='tcp',FromPort=fPort,ToPort=tPort)
                        print(sEnv, sRegion, sSecgroup, fPort, get_ip_data, get_description, '--> FORCE CLEAN')
                    else:
                        print(sEnv, sRegion, sSecgroup, fPort, get_ip_data, get_date_data, '--> NOT YET EXPIRED')
                else:
                    if (("wfh" in get_description) or ("WFH" in get_description) or ("Wfh" in get_description)):
                        print(get_description, "---> FOUND!")
                        security_group.revoke_ingress(CidrIp=get_ip_data,IpProtocol='tcp',FromPort=fPort,ToPort=tPort)
                        print(sEnv, sRegion, sSecgroup, fPort, get_ip_data, get_description, '--> WFH IP Clean up complete.')
            except KeyError:
                continue

# Get necessary details from file
def main():
    with open('adminSg.json') as json_file:
        data = json.load(json_file)
        for x in data['accounts']:
            env = (x['name'])
            role = (x['roleArn'])
            for y in x['regions']:
                region = (y['name'])
                for z in y['groups']:
                    secgroup = (z['sgid'])
                    get_ip(role,env,region,secgroup)


if __name__ == "__main__":
    print('Initializing Clean up')
    main()