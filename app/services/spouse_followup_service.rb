class SpouseFollowupService
  attr_reader :dependent_board, :recipients, :user_ids, :subject, :plain_text, :html_text

  def initialize(params, current_user)
    @current_user = current_user
    @dependent_board = Demo.find(params[:demo_id])
    @recipients = params[:recipients]
    @user_ids = find_users
    @subject = params[:subject]
    @plain_text = params[:plain_text]
    @html_text = params[:html_text]
    @html_text = '' unless sendable_html?(params[:html_text])
  end

  def send_message
    GenericMailer::BulkSender.new(
      dependent_board.id,
      user_ids,
      subject,
      plain_text,
      html_text,
      select_recipients
    ).send_bulk_mails
  end

  private

    def find_users
      if recipients == "active users"
        dependent_board.users.pluck(:id)
      elsif recipients == "potential users"
        dependent_board.potential_users.pluck(:id)
      elsif recipients == "send test message to current user"
        [@current_user.id]
      end
    end

    def select_recipients
      if recipients == "active users" || recipients == "send test message to current user"
        false
      elsif recipients == "potential users"
        true
      end
    end

    def sendable_html?(html)
      return false unless html.present?

      parsed_html = Nokogiri::HTML(html)
      parsed_html.css('img').present? || parsed_html.text.gsub(/[[:space:]]/, '').present?
    end
end
