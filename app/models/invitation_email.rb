class InvitationEmail

  # Set up the default values for bullets
  def self.bullet_defaults
    {'1a' => 'Finding tiles',
      '1b' => '',
      '2a' => 'Eating fruits and veggies',
      '2b' => '',
      '3a' => 'Exercising and making other',
      '3b' => 'healthy choices'}
  end

  # Here is the ghost method 
  # Call it like this:  InvitationEmail.bullet_1a(user), InvitationEmail.bullet_1b(user), etc.
  def self.method_missing(id, *args, &block)
    user = args[0]
    if id.to_s =~ /^bullet_(.+)$/
      attribute = "invitation_bullet_" + $1
      unless user.kind_of? User
        raise "You must call InvitationEmail.#{attribute} with an argument of class User"
      end
      if user.demo.send(attribute).present?
        return user.demo.send(attribute)
      else
        return self.bullet_defaults[$1]
      end
    end
    super
  end
      
end
