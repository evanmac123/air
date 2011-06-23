class Mailer < ActionMailer::Base
  default :from => "vlad@hengage.com"

  def invitation(user)
    @user = user

    mail :to      => user.email,
         :subject => "Invitation to demo H Engage"
  end

  def victory(user)
    @user = user

    mail :to      => user.demo.victory_verification_email,
         :subject => "HEngage victory notification: #{user.name} (#{user.email})"
  end

  def activity_report(csv_data, company_name, report_time, address)
    puts "Sending activity report for #{company_name} to #{address}"

    subject_line = "Activity dump for #{company_name} as of #{report_time.to_s}"

    normalized_company_name = company_name.gsub(/\s+/, '_').gsub(/[^A-Za-z0-9_]/, '')
    attachment_name = [
      normalized_company_name,
      '-',
      report_time.strftime("%Y_%m_%d_%H%M"),
      '.csv'
    ].join('')

    attachments[attachment_name] = csv_data

    mail :to      => address,
         :subject => subject_line
  end
end
