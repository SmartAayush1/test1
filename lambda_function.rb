# lambda function handler
ENV['RAILS_SERVE_STATIC_FILES'] = '1'
require_relative 'config/boot'
require 'dotenv'; Dotenv.load ".env.#{ENV['RAILS_ENV']}"
require 'lamby'
require_relative 'config/application'
require_relative 'config/environment'

# $app = Rack::Builder.new { run Rails.application }.to_app

# def handler(event:, context:)
#   Lamby.handler $app, event, context, rack: :http, binary_mimetypes: %w[application/octet-stream]
#   puts 'after lamby handler'
# end

# Lambda handler function
def handler(event:, context:)
  puts 'lambda function starts'
  # Load necessary libraries
  require 'rack'
  require 'json'
  require 'base64'
  begin
    puts event
    app = Rails.application
    # Extract relevant information from the Lambda event
    http_method = event['httpMethod'] || event['requestContext']['http']['method']
    path =event['path'] || event['requestContext']['http']['path']
    headers = event['headers'] || {}
    body = event['body'] || ''
    is_base64_encoded = event['isBase64Encoded'] || false

    # Decode base64-encoded body if needed
    body = Base64.decode64(body) if is_base64_encoded

    # Create a Rack environment
    env = {
      Rack::REQUEST_METHOD => http_method,
      Rack::PATH_INFO => path,
      Rack::RACK_INPUT => StringIO.new(body),
      Rack::RACK_URL_SCHEME => headers['X-Forwarded-Proto'] || 'http',
      Rack::QUERY_STRING => (event['multiValueQueryStringParameters']&.to_query || ''),
      Rack::SERVER_NAME => headers['X-Forwarded-Host'] || headers['Host'] || 'localhost',
      Rack::SERVER_PORT => headers['X-Forwarded-Port'] || 80,
      Rack::RACK_ERRORS => $stderr
    }

    # Add request headers to environment
    headers.each do |key, value|
      env["HTTP_#{key.upcase.gsub('-', '_')}"] = value
    end

    # Invoke the Rails application
    status, headers, response = app.call(env)

    # Check if response_body is an array and extract the first element
    # response_body_proxy = response.first if response.is_a?(Array)

    # Extract the body content from the BodyProxy
    body_content = ''
    response.each { |chunk| body_content += chunk.to_s }

    # Ensure response_body is a JSON string
    response_body_json = JSON.parse(body_content.to_json)

    # Build the Lambda response
    {
      'statusCode' => status,
      'headers' => headers,
      'body' => response_body_json,
      'isBase64Encoded' => false
    }

    # Rails.logger.info("Lambda handler invoked with event: #{event}")
    # puts lambda_response
  rescue StandardError => e
    Rails.logger.error("Error in Lambda handler: #{e.message}")
    # Additional handling or re-raise the error if needed
    raise e
  end
end
