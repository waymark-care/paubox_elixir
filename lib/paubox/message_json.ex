defimpl Jason.Encoder, for: Paubox.Message do
  def encode(%Paubox.Message{} = message, opts) do
    Jason.Encode.map(encode_message(message), opts)
  end

  defp encode_message(%Paubox.Message{} = message) do
    encode_recipients(message)
    |> Map.merge(%{
      headers: encode_headers(message),
      allow_non_tls: message.allow_non_tls,
      force_secure_notification: message.force_secure_notification,
      content: encode_content(message)
    })
  end

  defp encode_recipients(%Paubox.Message{} = message) do
    %{}
    |> then(fn recipients ->
      if message.recipients,
        do: Map.put(recipients, "recipients", message.recipients),
        else: recipients
    end)
    |> then(fn recipients ->
      if message.cc, do: Map.put(recipients, "cc", message.cc), else: recipients
    end)
    |> then(fn recipients ->
      if message.bcc, do: Map.put(recipients, "bcc", message.bcc), else: recipients
    end)
  end

  defp encode_headers(%Paubox.Message{} = message) do
    %{
      subject: message.subject,
      from: message.from
    }
    |> then(fn header ->
      if message.reply_to, do: Map.put(header, "reply-to", message.reply_to), else: header
    end)
    |> then(fn header ->
      if message.unsubscribe,
        do: Map.put(header, "List-Unsubscribe", message.unsubscribe),
        else: header
    end)
  end

  defp encode_content(%Paubox.Message{} = message) do
    %{}
    |> then(fn content ->
      if message.text_content,
        do: Map.put(content, "text/plain", message.text_content),
        else: content
    end)
    |> then(fn content ->
      if message.html_content,
        do: Map.put(content, "text/html", message.html_content),
        else: content
    end)
  end
end
