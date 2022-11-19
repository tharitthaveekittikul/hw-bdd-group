#MoviesController manage for CRUD operations
class MoviesController < ApplicationController

  #display movie on first page
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end


  def sort_data
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'bg-warning hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'bg-warning hilite'
    end
    return sort, ordering
  end

  def return_sorted_data
    sort = sort_data[0]
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    resume(sort_data[1])
  end

  def resume(order_sort)
    @movies = Movie.where(rating: @selected_ratings.keys).order(order_sort)
  end

  #retrieve movie from database and return to index page
  def index
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}

    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    return_sorted_data
  end

  #create new movie
  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  #find all movies from ID
  def edit
    @movie = Movie.find params[:id]
  end

  #update movie
  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  #destroy movie
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def fetch_from_tmdb
    response = Net::HTTP.get_response(URI("https://api.themoviedb.org/3/search/movie?api_key=d7c385ccb2f4441630477b180f3861e3&query=#{params[:search_terms]}&page=1"))
    if response.is_a?(Net::HTTPSuccess)
      retrieve = JSON.parse(response.body)
      data = retrieve["results"][0]
      return data
    else 
      return nil
    end

  end

  #search movie from TMDb and return to create page
  def search_tmdb
    data = fetch_from_tmdb
    if data
      @movies = {
        "title" => "#{data["title"]}",
        "release_date" => "#{data["release_date"]}",
        "adult" => "#{data["adult"]}",
        "overview" => "#{data["overview"]}"
      }
      redirect_to new_movie_path(@movies)
    else
      flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
      redirect_to movies_path
    end

        
  end

end