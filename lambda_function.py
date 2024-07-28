import json
import urllib.request

def lambda_handler(event, context):
    city = "Columbus"
    state = "Ohio"
    url = f"https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}"
    
    response = urllib.request.urlopen(url)
    breweries = json.loads(response.read())
    
    result = []
    for brewery in sorted(breweries, key=lambda x: x['name']):
        result.append({
            "name": brewery['name'],
            "street": brewery['street'],
            "phone": brewery['phone']
        })
    
    print(json.dumps(result, indent=2))
    
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
