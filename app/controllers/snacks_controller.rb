class SnacksController < ApplicationController
  before_action :set_snack, only: %i[ show edit update destroy ]

  # GET /snacks or /snacks.json
  def index
    @snacks = params[:query].present? ? Snack.search(params[:query]) : Snack.all
    @snacks = @snacks.order(tried_on: :desc)
  end

  # GET /snacks/1 or /snacks/1.json
  def show
  end

  # GET /snacks/new
  def new
    @snack = Snack.new(tried_on: Date.today)
  end

  # GET /snacks/1/edit
  def edit
  end

  # POST /snacks or /snacks.json
  def create
    @snack = Snack.new(snack_params)

    respond_to do |format|
      if @snack.save
        format.html { redirect_to @snack, notice: "Snack was successfully created." }
        format.json { render :show, status: :created, location: @snack }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @snack.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /snacks/1 or /snacks/1.json
  def update
    respond_to do |format|
      if @snack.update(snack_params)
        format.html { redirect_to @snack, notice: "Snack was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @snack }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @snack.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /snacks/1 or /snacks/1.json
  def destroy
    @snack.destroy!

    respond_to do |format|
      format.html { redirect_to snacks_path, notice: "Snack was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snack
      @snack = Snack.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def snack_params
      params.expect(snack: [ :brand, :name, :isaac_rating, :kristina_rating, :notes, :tried_on, :country_of_origin ])
    end
end
