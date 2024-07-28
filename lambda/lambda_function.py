import json
import logging
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    city = event.get('CITY', 'Columbus')
    state = event.get('STATE', 'Ohio')
    url = f'https://api.openbrewerydb.org/v1/breweries?by_city={city}&by_state={state}'
    response = requests.get(url)
    breweries = response.json()

    sorted_breweries = sorted(breweries, key=lambda x: x['name'])

    result = []
    for brewery in sorted_breweries:
        result.append({
            'name': brewery['name'],
            'street': brewery['street'],
            'phone': brewery['phone']
        })

    logger.info(json.dumps(result, indent=2))
    
    return result
