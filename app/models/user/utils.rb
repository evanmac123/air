class User
  module Utils

    # This method is helpful when you need to flush the staging database
    def self.seed(demo)
      list = ['vlad', 'phil', 'kim', 'jack', 'connie', 'josh', 'kate', 'larry']
      count = 0
      list.each do |name|
        in_email = name + '@airbo.com'
        unless User.find_by_email(in_email)
          User.create(name: name, 
                      demo_id: demo.id, 
                      email: in_email, 
                      slug: name,
                      sms_slug: name,
                      accepted_invitation_at: Time.now, 
                      password: 'airbo-password')
          count += 1
        end
      end
      puts "Created #{count} users"
    end

  end
end

