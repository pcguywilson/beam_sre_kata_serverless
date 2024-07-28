import json
import urllib.request
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    city = os.getenv("CITY", "Columbus")
    state = os.getenv("STATE", "Ohio")
    
    url = f"https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}"
    
    try:
        response = urllib.request.urlopen(url)
        breweries = json.loads(response.read().decode())
        
        breweries_list = [
            {"name": brewery["name"], "street": brewery["street"], "phone": brewery["phone"]}
            for brewery in sorted(breweries, key=lambda x: x["name"])
        ]
        
        logger.info(json.dumps(breweries_list, indent=2))
        return breweries_list
    
    except Exception as e:
        logger.error(f"Error fetching breweries: {e}")
        raise e
