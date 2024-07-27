import json
import pytest
import lambda_function

def test_lambda_handler(mocker):
    event = {}
    context = {}
    
    # Mocking the requests.get call
    breweries = [
        {"name": "Brewery A", "street": "123 Main St", "phone": "555-1234"},
        {"name": "Brewery B", "street": "456 Elm St", "phone": "555-5678"}
    ]
    
    mocker.patch("lambda_function.requests.get").return_value.json.return_value = breweries
    
    result = lambda_function.lambda_handler(event, context)
    
    assert result == [
        {"name": "Brewery A", "street": "123 Main St", "phone": "555-1234"},
        {"name": "Brewery B", "street": "456 Elm St", "phone": "555-5678"}
    ]
