defmodule Paubox.Message do
  use TypedStruct

  typedstruct do
    field(:recipients, [String.t()])
    field(:bcc, [String.t()])
    field(:cc, [String.t()])

    field(:subject, String.t(), enforce: true)
    field(:from, String.t(), enforce: true)
    field(:reply_to, String.t())

    field(:allow_non_tls, :boolean, default: false)
    field(:force_secure_notification, :boolean, default: false)

    field(:text_content, String.t())
    field(:html_content, String.t())

    field(:attachments, [Paubox.Attachment.t()])

    # This is to support the List-Unsubscribe header
    # https://docs.paubox.com/docs/paubox_email_api/messages/#list-unsubscribe
    field(:unsubscribe, String.t())
  end
end
