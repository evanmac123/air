module EmailInterpolations
  module InvitationUrl
    include SelfClosingTag

    def interpolate_invitation_url(invitation_url, text)
      interpolate_self_closing_tag('invitation_url', invitation_url, text)
    end
  end
end
