import json, re

rawJson = '''
{
  "attachments": [
    {
      "color": "danger",
      "fallback": "",
      "title": "ALERT STATUS: FIRING (UPDATE)",
      "text": "Date: 2022-01-21 00:04:05 UTC\n
      Name: HostDiskUtilization\n
      AlertID: 618e44e142e2aa7e9731ecea\n\n\n
      
      
      FIRING: \n
      Alert was evoked with value i-01401e83a243210cc/members-work-machine/ip-10-1-101-54/nvme0n1p1@84.25\n
      Alert was evoked with value i-0136cc8832c972cd9/care-pgl-sch-slr6-slv#1/ip-30-0-151-66/nvme0n1p1@89.06\n\n\n
      
      
      OK: \n
      Alert was resolved with value i-08332f4f0de43f8e5/care-pgl-api-was-prd#10/ip-30-0-151-41-f8e5.smem-prod/nvme0n1p1@65.82\n
      Alert was resolved with value i-05a452900d0bd41b3/care-pgl-api-was-prd#11/ip-30-0-152-41-41b3.smem-prod/nvme0n1p1@65.97\n"
    }
  ]
}

'''

def listToString(s):  
    # initialize an empty string 
    string = " "  
    # return string 
    return (string.join(s)) 

body = json.loads(rawJson, strict=False)

text = body['attachments'][0]['text']

output = re.split("\n", text)

# print(output)
alertMessage = {}
alerting = []
resolved = []

for i in output:
    # removes space at the beginning of string
    each = i.lstrip()
#    instanceIdReg = '[i]\-[a-zA-Z0-9]+'
    instanceIdReg = '(?<=value )(.*)'
    instanceNameReg = '(care|com|bnf|members)\-[a-zA-Z0-9]+'
    hostReg = '(ip)\-[a-zA-Z0-9]+'
    volReg = '(xvd|nvm)[a-zA-Z0-9]+'
    valReg = '[0-9]+'
    if "evoked" in each:
        # splits the sentence which contains evoked into words
        evokeOutput = re.split("\/", each)
        instanceID = ""
        instanceName = ""
        host = ""
        vol = ""
        value = ""
        for y in evokeOutput:
            if "value" in y:
                match = re.findall(instanceIdReg, y)
                instanceID = match
            elif (re.search(instanceNameReg, y)):
                instanceNameMatch = re.findall(instanceNameReg, y)
                instanceName = y
            elif (re.search(hostReg, y)):
                host = y    
            elif (re.search(volReg, y)):
                # splits words which contains volumes and values by @
                volOutput = re.split("\@", y)
                for x in volOutput:
                    if (re.search(volReg, x)):
                        vol = x
                    elif (re.search(valReg, x)):
                        value = x
        
        evokeRecord = {
            "instanceID" : listToString(instanceID),
            "instanceName" : instanceName,
            "host" : host,
            "volumeName" : vol,
            "value" : value
        }
        alerting.append(evokeRecord)
    elif "resolved" in each:
        resOutput = re.split("\/", each)
        instanceID = ""
        instanceName = ""
        host = ""
        vol = ""
        value = ""
        for y in resOutput:
            if "value" in y:
                match = re.findall(instanceIdReg, y)
                instanceID = match
            elif (re.search(instanceNameReg, y)):
                instanceNameMatch = re.findall(instanceNameReg, y)
                instanceName = y
            elif (re.search(hostReg, y)):
                host = y    
            elif (re.search(volReg, y)):
                volOutput = re.split("\@", y)
                for x in volOutput:
                    if (re.search(volReg, x)):
                        vol = x
                    elif (re.search(valReg, x)):
                        value = x
        resRecord = {
            "instanceID" : listToString(instanceID),
            "instanceName" : instanceName,
            "host" : host,
            "volumeName" : vol,
            "value" : value
        }
        resolved.append(resRecord)
    elif "Date" in each:
        print(each)
        regex = '(?<=Date: )(.*)'
        match = re.findall(regex, each)
        alertMessage["Date"] = listToString(match)
    elif "AlertID" in each:
        print(each)
        regex = '(?<=AlertID: )(.*)'
        match = re.findall(regex, each)
        alertMessage["AlertID"] = listToString(match)
    elif "Name" in each:
        print(each)
        regex = '(?<=Name: )(.*)'
        match = re.findall(regex, each)
        alertMessage["AlertName"] = listToString(match)

alertMessage["Alerting"] = alerting
alertMessage["Resolved"] = resolved

jsonDumps = json.dumps(alertMessage)

#print(alertMessage)


print(jsonDumps)
# print(rawJson)

