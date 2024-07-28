import unittest
from lambda_function import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    def test_lambda_handler(self):
        event = {
            'CITY': 'Columbus',
            'STATE': 'Ohio'
        }
        result = lambda_handler(event, None)
        self.assertIsInstance(result, list)
        self.assertGreater(len(result), 0)
        for brewery in result:
            self.assertIn('name', brewery)
            self.assertIn('street', brewery)
            self.assertIn('phone', brewery)

if __name__ == '__main__':
    unittest.main()
