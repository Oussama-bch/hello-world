from lib import exec_upsert_query, exec_select_query, format_response, gen_upsert_query, gen_select_query, validate_body_content
import argparse
import os

from flask import Flask, jsonify, request, make_response
from flask_json_schema import JsonSchema, JsonValidationError


app = Flask(__name__)

###########################################################################
# Default error responses
###########################################################################
@app.errorhandler(400)
def handle_400_error(_error):
    """Return a http 400 error to client"""
    return make_response(jsonify({'error': 'Misunderstood'}), 400)


@app.errorhandler(401)
def handle_401_error(_error):
    """Return a http 401 error to client"""
    return make_response(jsonify({'error': 'Unauthorised'}), 401)


@app.errorhandler(404)
def handle_404_error(_error):
    """Return a http 404 error to client"""
    return make_response(jsonify({'error': 'Not found'}), 404)


@app.errorhandler(500)
def handle_500_error(_error):
    """Return a http 500 error to client"""
    return make_response(jsonify({'error': 'Server error'}), 500)

############################################################################
# Heath check Endpoint
############################################################################
@app.route('/healthz', methods=['GET'])
def health_check():
    app.logger.info("Health check request")
    return jsonify({'Application': 'is healthy !'}), 200


schema = JsonSchema(app)
body_schema = {
    'type': 'object',
    'required': ['dateOfBirth'],
    'properties': {
        'dateOfBirth': {'type': 'string'}
    }
}


@app.errorhandler(JsonValidationError)
def validation_error(e):
    app.logger.error("Bad service contract : {}".format(e.errors))
    return jsonify({'error': e.message, 'errors': [validation_error.message for validation_error in e.errors]}), 400

############################################################################
# PUT User
############################################################################
@app.route('/hello/<username>', methods=['PUT'])
@schema.validate(body_schema)
def put_user(username):
    app.logger.info(" PUT /hello/{}".format(username))
    message = request.get_json()
    app.logger.debug(message)

    content = message.get("dateOfBirth", "")
    valid_request = validate_body_content(content, username)
    app.logger.info(valid_request)
    if not valid_request["valid_request"] :
        app.logger.warn(valid_request["error_message"])
        return make_response(jsonify({'error': valid_request["error_message"]}), 400)

    query = gen_upsert_query(username, content)
    app.logger.debug(query)

    try:
        app.logger.info("Connecting to the PostgreSQL database...")
        exec_upsert_query(query)
        app.logger.info("Database connection closed.")
        return '', 204
    except(Exception) as error:
        app.logger.error(error)
        return '', 503


############################################################################
# GET User
############################################################################
@app.route('/hello/<username>', methods=['GET'])
def get_user(username):
    app.logger.info(" GET /hello/{}".format(username))

    query = gen_select_query(username)
    app.logger.debug(query)
    try:
        db_result = exec_select_query(query)

        if db_result is not None:
            app.logger.debug("username {} found !".format(username))
            response = format_response(db_result[0], username)
            app.logger.debug(response)
            return jsonify({'message': response}), 200

        else:
            response = "username {} not found".format(username)
            app.logger.debug(response)
            return jsonify({'message': response}), 400
    except(Exception) as error:
        app.logger.error(error)
        return '', 503



############################################################################
# Main function
############################################################################
if __name__ == '__main__':

    PARSER = argparse.ArgumentParser(
        description="Hello world application")

    PARSER.add_argument('--debug', action='store_true',
                        help="Use flask debug/dev mode with file change reloading")
    ARGS = PARSER.parse_args()

    PORT = int(os.environ.get('PORT', 80))

    if ARGS.debug:
        app.logger.debug("Running in debug mode")
        app.run(host='0.0.0.0', port=PORT, debug=True)
    else:
        app.run(host='0.0.0.0', port=PORT, debug=False)
