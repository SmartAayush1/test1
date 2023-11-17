FROM public.ecr.aws/lambda/ruby:3.2

RUN yum install -y make gcc gcc-c++ kernel-devel libyaml-devel

# Set the working directory
WORKDIR ${LAMBDA_TASK_ROOT}


ENV RAILS_ENV=production

# Copy Gemfile and Gemfile.lock
COPY . .

RUN chmod 0644 config/master.key

# # Create and set permissions for log file
# RUN touch log/development.log && chmod 777 log/development.log

# # Create and set permissions for tmp folder and files
# RUN touch tmp/restart.txt tmp/local_secret.txt && chmod -R 777 tmp/

 RUN gem install bundler:2.4.20 && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.handler" ]



# FROM public.ecr.aws/lambda/ruby:3.2

# RUN yum install -y make gcc gcc-c++ kernel-devel libyaml-devel

# # Set the working directory
# WORKDIR ${LAMBDA_TASK_ROOT}

# # Copy log and tmp directories
# # COPY log log
# # COPY tmp tmp


# # Copy Gemfile and Gemfile.lock
# COPY . .

# # Install Bundler and the specified gems
# RUN gem install bundler:2.4.20 && \
#     bundle config set --local path 'vendor/bundle' && \
#     bundle install


# # Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
# CMD [ "lambda_function.handler" ]