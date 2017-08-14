class Reports::TileStatsDownloadReport
  attr_reader :tile, :report

  WHITE = "ffffff"
  AIRBO_BLUE = "48bfff"
  SECONDARY_GRAY = "e3e3e3"

  def initialize(tile_id:)
    @tile = Tile.find(tile_id)
    @report = Axlsx::Package.new
  end

  def data
    process_report
    report.use_shared_strings = true #allows for compatibility with Apple Pages

    report.to_stream.read
  end

  def process_report
    add_survey_sheet
    add_completed_sheet
    add_viewed_sheet
    add_did_not_view_sheet
  end

  def add_survey_sheet
    report.workbook.add_worksheet(name: "Results") do |sheet|
      title_style = set_title_style(sheet)
      table_header_style = set_table_header_style(sheet)

      sheet.add_row [tile.headline, nil, nil], style: title_style

      sheet.add_row ["Date Posted:", nil, tile.activated_at.try(:strftime, "%m/%d/%Y")]
      sheet.add_row ["People Viewed:", nil, tile.total_viewings_count]
      sheet.add_row ["People Completed:", nil, tile.tile_completions_count]
      sheet.add_row []

      sheet.add_row [tile.question]
      sheet.add_row ["Answer", "Users", "Percent"], style: table_header_style

      tile.survey_chart.each do |result_row|
        sheet.add_row [result_row["answer"], result_row["number"], result_row["percent"]]
      end
    end
  end

  def add_completed_sheet
    data = get_tile_interaction_data(action: "interacted")

    if tile_is_a_survey?
      headers = ["Date", "Name", "Email", "Answer", "Free Response"]
      schema =  ["completion_date", "user_name", "user_email", "tile_answer_index", "free_response"]
    else
      headers = ["Date", "Name", "Email"]
      schema =  ["completion_date", "user_name", "user_email"]
    end

    create_tile_interaction_sheet(name: "Completed", data: data, headers: headers, schema: schema)
  end

  def add_viewed_sheet
    data = get_tile_interaction_data(action: "viewed_only")
    headers = ["Date", "Name", "Email"]
    schema =  ["viewed_date", "user_name", "user_email"]

    create_tile_interaction_sheet(name: "Viewed Only", data: data, headers: headers, schema: schema)
  end

  def add_did_not_view_sheet
    data = get_tile_interaction_data(action: "not_viewed")
    headers = ["Name", "Email"]
    schema =  ["user_name", "user_email"]

    create_tile_interaction_sheet(name: "Did Not View", data: data, headers: headers, schema: schema)
  end

  def create_tile_interaction_sheet(name:, data:, headers:, schema:)
    report.workbook.add_worksheet(name: name) do |sheet|
      title_style = set_title_style(sheet)
      table_header_style = set_table_header_style(sheet)

      sheet.add_row create_title_row(schema_length: schema.length), style: title_style
      sheet.add_row headers, style: table_header_style

      data.each do |result_row|
        decorated_data = decorate_tile_interaction_data(row: result_row, schema: schema)
        sheet.add_row decorated_data
      end
    end
  end

  def create_title_row(schema_length:)
    Array.new(schema_length - 1).unshift(tile.headline)
  end

  def decorate_tile_interaction_data(row:, schema:)
    schema.map do |column|
      if column == "tile_answer_index"
        get_answer(row.send(column))
      elsif column == "viewed_date" || column == "completion_date"
        Time.local(row.send(column)).strftime("%m/%d/%Y")
      else
        row.send(column)
      end
    end
  end

  def get_answer(index)
    tile.multiple_choice_answers[index.to_i]
  end

  def get_tile_interaction_data(action:)
    GridQuery::TileActions.new(tile, action).query
  end

  def filename
    "airbo-tile-report-#{tile.headline.parameterize}.xlsx"
  end

  def set_title_style(sheet)
    sheet.styles.add_style(bg_color: AIRBO_BLUE, fg_color: WHITE)
  end

  def set_table_header_style(sheet)
    sheet.styles.add_style(bg_color: SECONDARY_GRAY)
  end

  def tile_is_a_survey?
    if tile.question_type
      tile.question_type.downcase == Tile::SURVEY.downcase
    end
  end
end
