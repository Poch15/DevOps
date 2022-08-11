import json, re
import requests
import sys
import boto3

print('Loading function')
 
def lambda_handler(event, context):

    def getSSMSecret(parameter):
        parameter = ssm.get_parameter(Name="/administration/secrets/jenkins/" + parameter, WithDecryption=True)
        return parameter['Parameter']['Value']
        
    def listToString(s):  
        string = " "  
        return (string.join(s))

    jenkinsURL = 'https://deploy.samsungmembers.com/generic-webhook-trigger/invoke?token='
    headers = {'content-type': "application/json"}
    jenkinsJob = ''
    ssm = boto3.client('ssm')    
    body = json.loads(event['body'], strict=False)
    text = body['attachments'][0]['text']
    print(event['body'])
    alertMessage = {}
    alerting = []
    resolved = []
    output = re.split("\n", text)

    for i in output:
        # removes space at the beginning of string
        each = i.lstrip()
        if "evoked" in each:
            # splits the sentence which contains evoked into words
            evokeOutput = re.split("\/", each)
            myDict = {}
            for y in evokeOutput:
                keyValOutput = re.split("\:", y)
                if "evoked" in keyValOutput[0]:  
                    keyVal = {
                        'service' : keyValOutput[1]
                    }
                    myDict.update(keyVal)    
                elif "jenkinsJob" in keyValOutput[0]:
                    jenkinsJob = keyValOutput[1]
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
            # loop through the key value output
            for y in resOutput:
                keyValOutput = re.split("\:", y)
                if "resolved" in keyValOutput[0]:
                    keyVal = {
                        'service' : keyValOutput[1]
                    }
                    myDict.update(keyVal)
                elif "jenkinsJob" in keyValOutput[0]:
                    jenkinsJob = keyValOutput[1]
                else:
                    keyVal = {
                        keyValOutput[0] : keyValOutput[1]               
                    }
                    myDict.update(keyVal)
            resolved.append(myDict)
        elif "Date" in each:
            regex = '(?<=Date: )(.*)'
            match = re.findall(regex, each)
            alertMessage["Date"] = listToString(match)
        elif "AlertID" in each:
            regex = '(?<=AlertID: )(.*)'
            match = re.findall(regex, each)
            alertMessage["AlertID"] = listToString(match)
        elif "Name" in each:
            regex = '(?<=Name: )(.*)'
            match = re.findall(regex, each)
            alertMessage["AlertName"] = listToString(match)
    
    alertMessage["Alerting"] = alerting
    alertMessage["Resolved"] = resolved
    jsonDumps = json.dumps(alertMessage)
    print(jsonDumps)
    
    token = getSSMSecret(jenkinsJob)
    response = requests.post(jenkinsURL + token, data=jsonDumps, headers=headers)
    resLoads = json.loads(response.text, strict=False)
    print(response.text)
    
    return {
        'statusCode': 200,
        'body': json.dumps(resLoads)
    }
    
    
    
