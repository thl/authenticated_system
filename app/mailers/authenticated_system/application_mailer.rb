module AuthenticatedSystem
  class ApplicationMailer < ActionMailer::Base
    default from: "do-not-reply@contemplative.eco"
    layout "mailer"
  end
end
