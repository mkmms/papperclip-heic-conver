class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :verify_image, only: [:create, :update]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def verify_image
    return unless params[:post][:image].present?

    filename = params[:post][:image].original_filename
    heic_format = /\.(heic|heif)$/ 
    
    return unless heic_format =~ filename
    
    file = params[:post][:image].tempfile
    jpegname = filename.gsub(/\.heic/, '.jpg')
    file_prefix = Time.now.strftime('%s')
    directory = "#{Rails.root}/public/#{file_prefix}/"
    path = "#{directory}#{filename}"
    
    FileUtils::mkdir_p(directory)
    Rails.logger.info "===========File Copying============="
    FileUtils.cp(file, path)

    Rails.logger.info "===========File Converting============="
    `convert #{path} #{directory}#{jpegname}`

    file = File.open("#{directory}#{jpegname}")

    params[:post][:image].content_type = "image/jpeg"
    params[:post][:image].headers = "Content-Disposition: form-data; name=\"post[image]\"; filename=\"#{jpegname}\"\r\nContent-Type: image/jpeg\r\n"
    params[:post][:image].original_filename = jpegname
    params[:post][:image].tempfile = file

    FileCleanerJob.set(wait: 5.seconds).perform_later(directory)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :desc, :image)
    end
end
