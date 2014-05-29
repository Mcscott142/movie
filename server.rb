
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

def next_page(page_num)
  (page_num - 1) * 20
end


get '/movies' do

@page_number = params["page"] || 1
off_set = next_page(@page_number.to_i)
@next_page_num = @page_number.to_i + 1

#binding.pry
@movies = db_connection do |conn|
  conn.exec("SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    JOIN genres ON genres.id = movies.genre_id
    LEFT OUTER JOIN studios ON studios.id = movies.studio_id
    ORDER BY movies.title LIMIT 20 OFFSET #{off_set}")
end


  erb :'/movies/index'
end

get '/movies/:id' do
  id = params[:id]
  query = 'SELECT movies.id, movies.title, genres.name AS genre, studios.name AS studio, actors.name AS actor_name, actors.id AS actor_id, cast_members.character
  FROM movies
  JOIN genres ON genres.id = movies.genre_id
  LEFT OUTER JOIN studios ON movies.studio_id = studios.id
  JOIN cast_members ON movies.id = cast_members.movie_id
  JOIN actors ON cast_members.actor_id = actors.id
  WHERE movies.id = $1
  ORDER BY movies.title'

  @movies = db_connection do |conn|
    conn.exec_params(query, [id])
  end



erb :'/movies/show'
end

get '/actors' do

@actors = db_connection do |conn|
  conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name LIMIT 20 OFFSET 20')
  end

  erb :'/actors/index'
end

get '/actors/:id' do
  id = params[:id]
   query = 'SELECT actors.name, actors.id, movies.id AS movie_id, movies.title, cast_members.character
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
