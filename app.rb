require 'sinatra'
require 'traitify'

# Configure the traitify gem. These are the only required fields
# Set your environment variables for the api_host and your secret.
# Your secert key can be found in the the developer portal:
#
# http://developer.traitify.com
Traitify.configure do |t|
  t.api_host = ENV['TRAITIFY_API_HOST']
  t.api_version = "v1"
  t.secret = ENV['TRAITIFY_API_KEY']
end

# This is only if you are using haml in a sinatra application and
# not required.
set :haml, format: :html5

# Landing page for the example. The available decks are passed to the
# UI
get '/' do
  haml :index, locals: { decks: Traitify.new.decks }
end

# Create an assessment for a specific deck and respond with the show page
get '/assessments/:deck' do
  haml :show, locals: { assessment: traitify.create_assessment(deck_id: params[:deck]) }
end

# Get the slides for an assessment. This is where the assessment is taken by
# the user
get '/assessments/slides/:assessment_id' do
  haml :slides, locals: { assessment_id: params[:assessment_id], slides: Traitify.new.find_slides(params[:assessment_id]) }
end

# Post the users answers to a given slide
post '/assessments/:assessment_id/slides/:slide_id/:answer' do
  begin
    Traitify.new.update_slide(params[:assessment_id], {
      id:         params[:slide_id],
      response:   params[:answer],
      time_taken: 1000
    })
  rescue
    [500, 'Error updating slide']
  end
  200
end

# Get the results for an assessment after the assessment is completed
get '/assessments/:assessment_id/results' do
  traitify = Traitify.new
  assessment = traitify.find_assessment(params[:assessment_id])
  results = assessment.completed_at ? traitify.find_results(assessment.id) : []

  haml :results, locals: { assessment_id: assessment.id, results: results }
end
