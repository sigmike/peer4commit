if (SEND_ALL_EMAILS_TO = CONFIG["send_all_emails_to"]).present?
  class MailInterceptor
    def self.delivering_email(message)
      message.subject = "[#{CONFIG['smtp_settings']['domain']} to #{message.to.join(", ")}] #{message.subject}"
      message.to = SEND_ALL_EMAILS_TO
    end
  end

  ActionMailer::Base.register_interceptor(MailInterceptor)
end
