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
      Alert was evoked with value service:care/instanceID:i-01401e83a243210cc/instanceName:members-work-machine/host:ip-10-1-101-54/volume:nvme0n1p1/value:84.25\n
      Alert was evoked with value service:care/instanceID:i-08332f4f0de43f8e5/instanceName:care-pgl-api-was-prd#10/host:ip-30-0-151-41-f8e5.smem-prod/volume:nvme0n1p1/value:89.06\n\n\n
      
      
      OK: \n
      Alert was resolved with value service:care/instanceID:i-05a452900d0bd41b3/instanceName:care-pgl-api-was-prd#11/host:ip-30-0-152-41-41b3.smem-prod/volume:nvme0n1p1/value:65.82\n
      Alert was resolved with value service:care/instanceID:i-0c6b5e1f63260006e/instanceName:care-pgl-api-was-prd-dk2#3/host:ip-30-0-151-31-006e.smem-prod/volume:xvda1/value:65.97\n"
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
    if "evoked" in each:
        # splits the sentence which contains evoked into words
        evokeOutput = re.split("\/", each)
        myDict = {}
        for y in evokeOutput:
            # print(y)
            keyValOutput = re.split("\:", y)
#            print(keyValOutput)
            if "evoked" in keyValOutput[0]:

                keyVal = {
                    'service' : keyValOutput[1]
                }
                myDict.update(keyVal)

            else:
                keyVal = {
                    keyValOutput[0] : keyValOutput[1]               
                }
                myDict.update(keyVal)

        alerting.append(myDict)
    elif "resolved" in each:
         # splits the sentence which contains evoked into words
        resOutput = re.split("\/", each)
        myDict = {}
        for y in resOutput:
            # print(y)
            keyValOutput = re.split("\:", y)
#            print(keyValOutput)
            if "resolved" in keyValOutput[0]:

                keyVal = {
                    'service' : keyValOutput[1]
                }
                myDict.update(keyVal)

            else:
                keyVal = {
                    keyValOutput[0] : keyValOutput[1]               
                }
                myDict.update(keyVal)
        resolved.append(myDict)
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

# print(alertMessage)


print(jsonDumps)
# print(rawJson)

