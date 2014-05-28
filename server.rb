
require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end




get '/movies' do


  erb :'/movies/index'
end

get 'movies/:id' do


erb :'/movies/show'
end

get '/actors' do

@actors = db_connection do |conn|
  conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name;')
  end

  erb :'/actors/index'
end

get '/actors/:id' do
  id = params[:id]
   query = 'SELECT actors.name, actors.id, movies.title, cast_members.character
      FROM movies
      JOIN cast_members
      ON cast_members.movie_id = movies.id
      JOIN actors
      ON cast_members.actor_id = actors.id
      WHERE actors.id = $1
      ORDER BY movies.title'

  @actors = db_connection do |conn|
    conn.exec_params(query, [id])
  end

  erb :'/actors/show'
end
