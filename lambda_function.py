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

    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    req = urllib.request.Request(url, headers=headers)
    
    try:
        with urllib.request.urlopen(req) as response:
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
    
    except urllib.error.HTTPError as e:
        logger.error(f"HTTPError: {e.code} {e.reason}")
        return {
            'statusCode': e.code,
            'body': json.dumps({'error': e.reason})
        }
    
    except Exception as e:
        logger.error(f"Exception: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
