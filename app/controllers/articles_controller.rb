class ArticlesController < ApplicationController
  def index
    render json: { message: 'This is the articles api' }
  end

  def hello_world
    render json: {message: 'Hello World from the hello world function in articles controller.'}
  end

  def test_method
    render json: { message: 'Another test method for url testing.' }
  end
end
