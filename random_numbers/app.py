import os
import json
import logging
import random


logger = logging.getLogger()
logger.setLevel(logging.WARN if os.environ.get('ENV_TYPE') == 'prod' else logging.INFO)


RESOURCE = 'random-number-generating-lambda'


def validate_request(request_data):
    logger.info({'resource': RESOURCE, 'operation': 'request_data'})
    if not isinstance(request_data, dict):
        message = 'Failed request_data argument type validation, expected dictionary'
        logger.error({
            'resource': RESOURCE,
            'operation': 'request_data',
            'details': {
                'error': message,
                'request_data': request_data
            }
        })
        raise TypeError(message)

    try:
        lower_bounds = request_data['lower_bounds']
    except KeyError as e:
        logger.error({
            'resource': RESOURCE,
            'operation': 'request_data',
            'details': {
                'error': str(e),
                'request_data': request_data
            }
        })
        raise e

    lower_bounds = request_data.get('lower_bounds', 0)
    upper_bounds = request_data.get('upper_bounds', 100)

    if lower_bounds < 0:
        raise ValueError('Lower bounds must be at least zero')

    if upper_bounds > 1000:
        raise ValueError('Upper bounds must be no more than 1000')

    return lower_bounds, upper_bounds


def random_number(lower_bounds, upper_bounds):
    logger.info({'resource': RESOURCE, 'operation': 'random_number'})
    return random.randint(lower_bounds, upper_bounds)


def lambda_handler(event, context):
    logger.info({'resource': RESOURCE, 'operation': 'lambda_handler'})

    try:
        request_data = json.loads(event['body'])
        lower_bounds, upper_bounds = validate_request(request_data)
    except (ValueError, TypeError) as e:
        return {
            'statusCode': 400,
            'body': json.dumps(str(e))
        }

    num = random.randint(lower_bounds, upper_bounds)

    return {
        "statusCode": 201,
        "body": json.dumps({
                'lower_bounds': lower_bounds,
                'upper_bounds': upper_bounds,
                'number': num
            }),
    }
