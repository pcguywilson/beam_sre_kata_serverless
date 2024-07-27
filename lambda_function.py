import json
import logging
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    city = "Columbus"
    state = "Ohio"
    url = f"https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        breweries = response.json()
        
        sorted_breweries = sorted(breweries, key=lambda k: k['name'])
        
        results = [
            {
                "name": brewery.get("name"),
                "street": brewery.get("street"),
                "phone": brewery.get("phone")
            }
            for brewery in sorted_breweries
        ]
        
        logger.info(json.dumps(results, indent=4))
        
        return {
            "statusCode": 200,
            "body": json.dumps(results)
        }
        
    except requests.RequestException as e:
        logger.error(f"Request failed: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
