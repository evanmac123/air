class Admin::CaseStudiesController < AdminBaseController
  def new
    @case_study = CaseStudy.new
  end

  def edit
    @case_study = CaseStudy.find_by_slug(params[:id])
  end

  def index
    @case_studies = CaseStudy.all
  end

  def create
    @case_study = CaseStudy.new(case_study_params)

    if @case_study.save
      redirect_to admin_case_studies_path
    else
      flash.now[:failure] = @case_study.errors.full_messages.join(", ")
      render :new
    end
  end

  def update
    @case_study = CaseStudy.find_by_slug(params[:id])

    if @case_study.update_attributes(campaign_params)
      redirect_to admin_case_studies_path
    else
      flash.now[:failure] = @case_study.errors.full_messages.join(", ")
      render :edit
    end
  end

  private

    def case_study_params
      params.require(:case_study).permit(:client_name, :description, :cover_image, :logo, :pdf)
    end
end
