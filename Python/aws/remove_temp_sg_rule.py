import boto3
import re
from botocore.exceptions import ClientError

keyWord = 'temp'
sRegion = 'ap-southeast-1'
#sRole='arn:aws:iam::480586329294:role/mem-releng-access'
sRole = 'arn:aws:iam::963697571568:role/role-samsungmembers-releng-smem-ta'
regex = r"[a-z]{1,}\.[a-z]{1,}\,[0-9]{2}\-[0-9]{2}\-[0-9]{4}"

def get_session(sRole):
    sts = boto3.client('sts')
    get_sts = sts.assume_role(RoleArn=sRole,RoleSessionName='p.encina')

    return boto3.session.Session(
        aws_access_key_id=get_sts['Credentials']['AccessKeyId'],
        aws_secret_access_key=get_sts['Credentials']['SecretAccessKey'],
        aws_session_token=get_sts['Credentials']['SessionToken'])

def get_rule_prot(fPort, tPort, ipProtocol, desc, cidrIp):
    IpPermissionsEgress=[
        {
            'FromPort': fPort,
            'ToPort': tPort,
            'IpProtocol': ipProtocol,
            'IpRanges': [
                {
                    'Description': desc,
                    'CidrIp': cidrIp,
                }
            ]
        }
    ]    
    return IpPermissionsEgress
    
def get_rule_no_prot(ipProtocol, desc, cidrIp):
    IpPermissionsEgress=[
        {
            'IpProtocol': ipProtocol,
            'IpRanges': [
                {
                    'Description': desc,
                    'CidrIp': cidrIp,
                }
            ]
        }
    ]
    return IpPermissionsEgress

def get_rule_prot_sgsource(fPort, tPort, ipProtocol, desc, groupId, userId, vpcId):
    IpPermissionsEgress=[
        {
            'FromPort': fPort,
            'ToPort': tPort,
            'IpProtocol': ipProtocol,
            'UserIdGroupPairs': [
                {
                    'Description': desc,
                    'GroupId': groupId,
                    'UserId': userId,
                    'VpcId': vpcId
                }
            ]
        }
    ]    
    return IpPermissionsEgress   

def get_rule_all_prot_sgsource(ipProtocol, desc, groupId, userId, vpcId):
    IpPermissionsEgress=[
        {
            'IpProtocol': ipProtocol,
            'UserIdGroupPairs': [
                {
                    'Description': desc,
                    'GroupId': groupId,
                    'UserId': userId,
                    'VpcId': vpcId
                }
            ]
        }
    ]    
    return IpPermissionsEgress

def check_desc_exists(source):
    d1={}
    d1.update(source)
    
    if 'Description' in d1.keys():
        return True
    else:
        return False

def check_user_id_exists(desc):
    if (re.search(regex, desc)):
        return True
    else:
        return False

    
def main():
    session = get_session(sRole)
    client = session.client('ec2')
    regions = [region['RegionName'] for region in client.describe_regions()['Regions']]
    
    for i in regions:
        region = i
        client = session.client('ec2', region_name=region)
        security_groups = client.describe_security_groups()
        ec2 = session.resource('ec2', region_name=region)

        for i in security_groups['SecurityGroups']:
            security_group = ec2.SecurityGroup(i['GroupId'])
            gName = i['GroupName']
            vId = i['VpcId']
            try:
                # Loop through Inbound Rules
                for j in i['IpPermissions']:
                    ipProt = j['IpProtocol']
                    # Loop through rules whose source is IP Range
                    for k in j['IpRanges']:                   
                        cidr = k['CidrIp']
                        # Checks if description exists in rule                        
                        result = check_desc_exists(k)
                        if result:                        
                            desc = k['Description']
                            # Checks if knox id id with this format exists (j.delacruz,12-24-2021)
                            uIdRes = check_user_id_exists(desc)
                            if not uIdRes:
                                if keyWord in desc.lower():
                                    if ipProt == "-1":
                                        IpPermissionsEgress = get_rule_no_prot(ipProt, desc, cidr)
                                        security_group.revoke_ingress(IpPermissions = IpPermissionsEgress)
                                        print("Source: " + cidr + " Protocol: " + str(ipProt) + " Desc: '" + desc + "' " + 
                                        "--> Inbound rule has been deleted from " + gName + " SG in " + region)
                                    else:
                                        fPort = j['FromPort']
                                        tPort = j['ToPort']
                                        IpPermissionsEgress = get_rule_prot(fPort, tPort, ipProt, desc, cidr)
                                        security_group.revoke_ingress(IpPermissions = IpPermissionsEgress)
                                        print("Source: " + cidr + " From: " + str(fPort) + " To: " + str(tPort) + " Protocol: " + 
                                        str(ipProt) + " Desc: '" + desc + "' " + "--> Inbound rule has been deleted from " + gName + " SG in " + region)
                    # Loop through rules whose source is SG
                    for k in j['UserIdGroupPairs']:
                        gId = k['GroupId']
                        uId = k['UserId']
                        # Checks if description exists in rule
                        result = check_desc_exists(k)
                        if result:
                            desc = k['Description']
                            # Checks if knox id id with this format exists (j.delacruz,12-24-2021)
                            uIdRes = check_user_id_exists(desc)
                            if not uIdRes:
                                if keyWord in desc.lower():
                                    if ipProt == "-1":
                                        IpPermissionsEgress = get_rule_all_prot_sgsource(ipProt, desc, gId, uId, vId)
                                        security_group.revoke_ingress(IpPermissions = IpPermissionsEgress)
                                        print("Source: " + gId + " Protocol: " + str(ipProt) + " Desc: '" + desc + "' " + 
                                        "--> Inbound rule has been deleted from " + gName + " SG in " + region)
                                    else:
                                        fPort = j['FromPort']
                                        tPort = j['ToPort']
                                        IpPermissionsEgress = get_rule_prot_sgsource(fPort, tPort, ipProt, desc, gId, uId, vId)
                                        security_group.revoke_ingress(IpPermissions = IpPermissionsEgress)
                                        print("Source: " + gId + " From: " + str(fPort) + " To: " + str(tPort) + " Protocol: " + 
                                        str(ipProt) + " Desc: '" + desc + "' " + "--> Inbound rule has been deleted from " + gName + " SG in " + region)        

                # Loop through Outbound Rules
                for j in i['IpPermissionsEgress']:
                    ipProt = j['IpProtocol']
                    # Loop through rules whose source is IP Range
                    for k in j['IpRanges']:
                        cidr = k['CidrIp']
                        # Checks if description exists in rule                    
                        result = check_desc_exists(k)
                        if result:
                            desc = k['Description']
                            # Checks if knox id id with this format exists (j.delacruz,12-24-2021)
                            uIdRes = check_user_id_exists(desc)
                            if not uIdRes:
                                if keyWord in desc.lower():
                                    if ipProt == "-1":
                                        IpPermissionsEgress = get_rule_no_prot(ipProt, desc, cidr)
                                        security_group.revoke_egress(IpPermissions = IpPermissionsEgress)
                                        print("Destination: " + cidr + " Protocol: " + str(ipProt) + " Desc: '" + desc + "' " + 
                                        "--> Outbound rule has been deleted from " + gName + " SG in " + region)
                                    else:
                                        fPort = j['FromPort']
                                        tPort = j['ToPort']                                
                                        IpPermissionsEgress = get_rule_prot(fPort, tPort, ipProt, desc, cidr)
                                        security_group.revoke_egress(IpPermissions = IpPermissionsEgress)
                                        print("Destination: " + cidr + " From: " + str(fPort) + " To: " + str(tPort) + " Protocol: " + 
                                        str(ipProt) + " Desc: '" + desc + "' " + "--> Outbound rule has been deleted from " + gName + " SG in " + region)
                    # Loop through rules whose source is SG        
                    for k in j['UserIdGroupPairs']:
                        gId = k['GroupId']
                        uId = k['UserId']
                        # Checks if description exists in rule
                        result = check_desc_exists(k)
                        if result:
                            desc = k['Description']
                            # Checks if knox id id with this format exists (j.delacruz,12-24-2021)
                            uIdRes = check_user_id_exists(desc)
                            if not uIdRes:
                                if keyWord in desc.lower():
                                    if ipProt == "-1":
                                        IpPermissionsEgress = get_rule_all_prot_sgsource(ipProt, desc, gId, uId, vId)
                                        security_group.revoke_egress(IpPermissions = IpPermissionsEgress)
                                        print("Destination: " + gId + " Protocol: " + str(ipProt) + " Desc: '" + desc + "' " + 
                                        "--> Outbound rule has been deleted from " + gName + " SG in " + region)
                                    else:
                                        fPort = j['FromPort']
                                        tPort = j['ToPort'] 
                                        IpPermissionsEgress = get_rule_prot_sgsource(fPort, tPort, ipProt, desc, gId, uId, vId)
                                        security_group.revoke_egress(IpPermissions = IpPermissionsEgress)
                                        print("Destination: " + gId + " From: " + str(fPort) + " To: " + str(tPort) + " Protocol: " + 
                                        str(ipProt) + " Desc: '" + desc + "' " + "--> Outbound rule has been deleted from " + gName + " SG in " + region)                        
            except KeyError:
                continue
        
if __name__ == "__main__":
    main()
    
    