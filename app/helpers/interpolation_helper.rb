module InterpolationHelper
  def interpolate!(text, objects = { user: @user, organization: @user.organization || Organization.new })
    text = interpolate_user(text, objects[:user])
    text = interpolate_organization(text, objects[:organization])
    text
  end

  private
    def interpolate_string(interpolation, object)
      methods = sanitize_interpolations(interpolation)
      methods.inject(object) { |result, method| result.send(method) }
    end

    def interpolate_user(text, user)
      return unless user.is_a?(User)
      text.gsub(/\{user(.*?)\}/) do |interpolation|
        interpolate_string(interpolation, user)
      end
    end

    def interpolate_organization(text, organization)
      return unless organization.is_a?(Organization)
      text.gsub(/\{organization(.*?)\}/) do |interpolation|
        interpolate_string(interpolation, organization)
      end
    end

    def sanitize_interpolations(interpolation)
      interpolation.delete("{}").delete(' ').split(",")[1..-1]
    end
end
