import boto3
import json
import time
import os
from datetime import datetime, timezone
from os import path

sts_client = boto3.client('sts')

assumed_role_object=sts_client.assume_role(
    RoleArn="arn:aws:iam::480586329294:role/role-samsungmembers-prd-smem-ta",
    RoleSessionName="samsungmembers-prd-smem-ta"
)

fileName = time.strftime("%Y%m%d" + ".json")

createdFile = '/home/pencina/Scripts/output/' + fileName
open(createdFile, 'a').close()


def utc_to_local(utc_dt):
    return utc_dt.replace(tzinfo=timezone.utc).astimezone(tz=None)

def diff_dates(date1, date2):
    return abs(date2 - date1).days

#resource = boto3.resource('iam')

resource=boto3.resource(
    'iam',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
)

#client = boto3.client("iam")

client=boto3.client(
    'iam',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
)


for user in resource.users.all():
    print(user)
    Metadata = client.list_access_keys(UserName=user.user_name)
    if Metadata['AccessKeyMetadata']:
        for key in user.access_keys.all():
            
            AccessId = key.access_key_id
            Status = key.status
            CreatedDate = key.create_date

            numOfDays = diff_dates(utc_to_local(datetime.utcnow()), utc_to_local(CreatedDate))
            LastUsed = client.get_access_key_last_used(AccessKeyId=AccessId)

            if (Status == "Active"):
                if (numOfDays > 85):

                    if (os.path.getsize(createdFile) > 0):

                        userRecord = {
                        "User" : user.user_name,
                        "Key" : AccessId,
                        "Last Used" : LastUsed['AccessKeyLastUsed'],
                        "Age of Key" : numOfDays
                        }

                        print(userRecord)
                        
                        # Read JSON file and append new record to json file
                        with open(createdFile, "r+") as f:
                            data = json.load(f)
                            data.append(userRecord)
                            f.seek(0)
                            json.dump(data, f, indent=4, default=str)
                        f.close()
                    else:
                        userRecord = [{
                        "User" : user.user_name,
                        "Key" : AccessId,
                        "Last Used" : LastUsed['AccessKeyLastUsed'],
                        "Age of Key" : numOfDays
                        }]

                        with open(createdFile, 'w') as f:
                            json.dump(userRecord, f, indent=4, default=str)

                        f.close()


