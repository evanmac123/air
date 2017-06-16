class Admin::CaseStudiesController < AdminBaseController
  def new
    @case_study = CaseStudy.new
  end

  def edit
    @case_study = find_case_study
  end

  def index
    @case_studies = CaseStudy.order_by_position
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
    @case_study = find_case_study

    if @case_study.update_attributes(case_study_params)
      redirect_to admin_case_studies_path
    else
      flash.now[:failure] = @case_study.errors.full_messages.join(", ")
      render :edit
    end
  end

  private

    def case_study_params
      params.require(:case_study).permit(:client_name, :description, :logo, :pdf, :quote, :quote_cite, :quote_cite_title, :non_pdf_url, :position)
    end

    def find_case_study
      CaseStudy.find(params[:id].to_i)
    end
end
