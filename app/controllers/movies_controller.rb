class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
	sel_ratings = params[ :ratings ]
	sort_by = params[:order]
	if  sel_ratings == nil && sort_by == nil 
		sel_ratings = session[:ratings] 
		sort_by = session[:order]
		if  sel_ratings != nil || sort_by != nil 
			flash.keep
			redirect_to movies_path ( {:ratings => sel_ratings , :order => sort_by} )
		end
	else
		session[ :ratings ] = sel_ratings
		session[ :order ] = sort_by
	end

	@search_ratings = Array.new
        @all_ratings = Hash.new
	Movie.find_by_sql("select DISTINCT rating from movies order by rating" ).each do |rate| 
		if sel_ratings == nil or sel_ratings.include?( rate.rating ) 
			@all_ratings[ rate.rating ] = 1 
			@search_ratings << rate.rating
		else
			@all_ratings[ rate.rating ] = nil
		end
	end
	if sort_by
    		@movies = Movie.where( "movies.rating IN (?)", @search_ratings ).order( sort_by )
 	else
		@movies = Movie.where( "movies.rating IN (?)", @search_ratings )
	end
	instance_variable_set("@#{sort_by}_header", "hilite")
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
