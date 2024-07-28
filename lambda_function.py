import json
import urllib.request
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    city = os.environ.get('CITY', 'Columbus')
    state = os.environ.get('STATE', 'Ohio')
    
    url = f"https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}&sort=name"
    
    with urllib.request.urlopen(url) as response:
        breweries = json.loads(response.read().decode())
        
    for brewery in breweries:
        log_data = {
            'name': brewery.get('name'),
            'street': brewery.get('street'),
            'phone': brewery.get('phone')
        }
        logger.info(json.dumps(log_data))
        
    return {
        'statusCode': 200,
        'body': json.dumps('Log created successfully!')
    }
