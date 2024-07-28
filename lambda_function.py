import json
import requests

def lambda_handler(event, context):
    city = event.get('CITY', 'Columbus')
    state = event.get('STATE', 'Ohio')
    url = f"https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}"
    
    response = requests.get(url)
    breweries = response.json()
    
    brewery_list = []
    
    for brewery in breweries:
        brewery_info = {
            "name": brewery.get("name"),
            "street": brewery.get("street"),
            "phone": brewery.get("phone")
        }
        brewery_list.append(brewery_info)
    
    brewery_list_sorted = sorted(brewery_list, key=lambda x: x['name'])
    
    print(json.dumps(brewery_list_sorted, indent=2))
    
    return {
        "statusCode": 200,
        "body": json.dumps(brewery_list_sorted)
    }
