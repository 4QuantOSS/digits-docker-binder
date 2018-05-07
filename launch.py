import os
import digits, digits.webapp
import argparse

parser = argparse.ArgumentParser(description='DIGITS server')

parser.add_argument(
    '-p', '--port',
    type=int,
    default=5000,
    help='Port to run app on (default 5000)'
)
args = vars(parser.parse_args())
base_prefix = '{}proxy/{}/'.format(os.environ['JUPYTERHUB_SERVICE_PREFIX'], args['port'])
digits.webapp.app.debug = False
# monkey patch url_for
from flask import url_for as old_url_for
import flask
def new_url_for(*args, **kwargs):
    return '{}{}'.format(base_prefix[:-1], old_url_for(*args, **kwargs))
flask.url_for = new_url_for 

print('Launching Server', digits.webapp.app.config)
digits.webapp.socketio.run(digits.webapp.app, '0.0.0.0', args['port'])
#digits.webapp.app.run(debug=False, # needs to be false in Jupyter
#                          host = '0.0.0.0',
#                          port=args['port'])
