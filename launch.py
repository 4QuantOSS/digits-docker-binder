import os
import digits, digits.webapp
import argparse

parser = argparse.ArgumentParser(description='DIGITS server')
class ReverseProxied(object):
    '''Wrap the application in this middleware and configure the 
    front-end server to add these headers, to let you quietly bind 
    this to a URL other than / and to an HTTP scheme that is 
    different than what is used locally.

    In nginx:
    location /myprefix {
        proxy_pass http://192.168.0.1:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Script-Name /myprefix;
        }

    :param app: the WSGI application
    '''
    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        script_name = environ.get('HTTP_X_SCRIPT_NAME', '')
        if script_name:
            environ['SCRIPT_NAME'] = script_name
            path_info = environ['PATH_INFO']
            if path_info.startswith(script_name):
                environ['PATH_INFO'] = path_info[len(script_name):]

        scheme = environ.get('HTTP_X_SCHEME', '')
        if scheme:
            environ['wsgi.url_scheme'] = scheme
        return self.app(environ, start_response)
parser.add_argument(
    '-p', '--port',
    type=int,
    default=5000,
    help='Port to run app on (default 5000)'
)
args = vars(parser.parse_args())
base_prefix = '{}proxy/{}/'.format(os.environ['JUPYTERHUB_SERVICE_PREFIX'], args['port'])
digits.webapp.app.config.requests_pathname_prefix = base_prefix
digits.webapp.app.debug = False
digits.webapp.app.config["APPLICATION_ROOT"] = base_prefix
digits.webapp.app.wsgi_app = ReverseProxied(digits.webapp.app.wsgi_app)
print('Launching Server', digits.webapp.app.config)
#digits.webapp.socketio.run(digits.webapp.app, '0.0.0.0', args['port'])
digits.webapp.app.run(debug=False, # needs to be false in Jupyter
                          host = '0.0.0.0',
                          port=args['port'])
