import boto3
import json
from datetime import datetime, timezone
from os import path


sRole='arn:aws:iam::480586329294:role/mem-releng-access'

def get_session(sRole):
    sts = boto3.client('sts')
    get_sts = sts.assume_role(RoleArn=sRole,RoleSessionName='sec-audit-notifier.inactive-users')

    return boto3.session.Session(
        aws_access_key_id=get_sts['Credentials']['AccessKeyId'],
        aws_secret_access_key=get_sts['Credentials']['SecretAccessKey'],
        aws_session_token=get_sts['Credentials']['SessionToken'])
    
def utc_to_local(utc_dt):
    return utc_dt.replace(tzinfo=timezone.utc).astimezone(tz=None)

def diff_dates(date1, date2):
    return abs(date2 - date1).days

def main():
    session = get_session(sRole)
    resource = session.resource('iam')
    client = session.client('iam')
    baseRecord = []

    for user in resource.users.all():
        latest = user.password_last_used
        Metadata = client.list_access_keys(UserName=user.user_name)       
        if Metadata['AccessKeyMetadata']:
            for key in user.access_keys.all():
                AccessId = key.access_key_id
                keyUsed = client.get_access_key_last_used(AccessKeyId=AccessId)
                # checks if access key has ever been used for the first time
                if 'LastUsedDate' in keyUsed['AccessKeyLastUsed']:
                    keyDate = keyUsed['AccessKeyLastUsed']['LastUsedDate']
                    if latest:
                        if keyDate > latest:                        
                            lastUsed = keyDate
                            numOfDays = diff_dates(utc_to_local(datetime.utcnow()), utc_to_local(lastUsed))
                            userRecord = {
                                "User" : user.user_name,
                                "Inactive" : numOfDays 
                            }
                            if (numOfDays > 60):
                                baseRecord.append(userRecord)
                        else:
                            numOfDays = diff_dates(utc_to_local(datetime.utcnow()), utc_to_local(latest))
                            userRecord = {
                                "User" : user.user_name,
                                "Inactive" : numOfDays
                            }
                            if (numOfDays > 60):
                                baseRecord.append(userRecord)
                    else:
                        numOfDays = diff_dates(utc_to_local(datetime.utcnow()), utc_to_local(keyDate))
                        userRecord = {
                            "User" : user.user_name,
                            "Inactive" : numOfDays
                        }
                        if (numOfDays > 60):
                            baseRecord.append(userRecord)
        else:
            numOfDays = diff_dates(utc_to_local(datetime.utcnow()), utc_to_local(latest))
            userRecord = {
                "User" : user.user_name,
                "Inactive" : numOfDays
            }
            if (numOfDays > 60):
                baseRecord.append(userRecord)
    if baseRecord:
        data_set = {"inactive_users": baseRecord }
        json_dump = json.dumps(data_set)
        print(json_dump)
    else:
        data_set = {}
        json_dump = json.dumps(data_set)
        print(json_dump)
                    
if __name__ == "__main__":
    main()
