class TileEmailReportsGenerator
  TILE_EMAIL_REPORTS_SUPPORTED_DATE = DateTime.new(2017, 5, 1).freeze

  attr_reader :board, :limit, :page

  def self.dispatch(board:, limit:, page:)
    generator = TileEmailReportsGenerator.new(board: board, limit: limit, page: page)

    generator.get_reports
  end

  def initialize(board: , limit:, page:)
    @board = board
    @limit = limit
    @page = page
  end

  def get_reports
    reports = tile_emails_for_report.map do |tile_email|
      Reports::TileEmailReport.new(tile_email: tile_email).attributes
    end

    {
      lastPage: tile_emails_for_report.last_page?,
      reports: reports
    }
  end

  private

    def tile_emails_for_report
      tile_emails_supported_by_feature.page(page).per(limit)
    end

    def tile_emails_supported_by_feature
      tile_emails.where("created_at > ?", TILE_EMAIL_REPORTS_SUPPORTED_DATE)
    end

    def tile_emails
      board.tiles_digests
    end
end
