"""Creates firebase auth JSON file with secrets from environment variables."""
import json
import os
import sys


auth_data = {
    'type': 'service_account',
    'project_id': os.environ['FIREBASE_PROJECT_ID'],
    'private_key_id': os.environ['FIREBASE_PRIVATE_KEY_ID'],
    'private_key': os.environ['FIREBASE_PRIVATE_KEY'].replace('\\n', '\n'),
    'client_email': os.environ['FIREBASE_CLIENT_EMAIL'],
    'client_id': os.environ['FIREBASE_CLIENT_ID'],
    'auth_uri': os.environ['FIREBASE_AUTH_URI'],
    'token_uri': os.environ['FIREBASE_TOKEN_URI'],
    'auth_provider_x509_cert_url': os.environ['FIREBASE_AUTH_PROVIDER_CERT_URL'],
    'client_x509_cert_url': os.environ['FIREBASE_CLIENT_CERT_URL'],
}

file_name = sys.argv[1]
with open(file_name, 'w') as auth_file:
    json.dump(auth_data, auth_file, indent=4)
