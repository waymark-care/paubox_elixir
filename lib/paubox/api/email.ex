defmodule Paubox.API.Email do
  @moduledoc """
  Documentation for the Paubox.API module.
  """
  alias Paubox.API.SendResponse
  alias Paubox.Message

  @base_url URI.parse("https://api.paubox.net/v1")

  @doc """
  See: https://docs.paubox.com/docs/paubox_email_api/messages#send-message

  Send a single Paubox.Message to the Paubox API.

  Possible responses are:
  - `{:ok, %Paubox.API.SendResponse{}}`: The message was successfully sent.
  - `{:api_error, %{errors: []}}`: The API returned an error.
  - `{:error, String.t()}`: An error occurred while sending the message.
  """
  def send(client, %Message{} = msg) do
    send_call(client, "/messages", %{data: %{message: msg}})
  end

  @doc """
  See: https://docs.paubox.com/docs/paubox_email_api/messages#send-bulk-messages

  Send multiple Paubox.Message structs to the Paubox API in a single request.
  The Paubox documentation recommends sending batches of 50 or less.  Source
  tracking IDs are generated for each message and are returned in the order they
  are in the request.

  Possible responses are:
  - `{:ok, [%Paubox.API.SendResponse{} | _rest]}`: The messages were successfully sent.
  - `{:api_error, %{errors: []}}`: The API returned an error.
  - `{:error, String.t()}`: An error occurred while sending the messages.
  """
  def send_bulk(client, [%Message{} | _rest] = msgs) do
    send_call(client, "/bulk_messages", %{data: %{messages: msgs}})
  end

  @doc """
  This is a thin wrapper around `send_bulk/2` that sends messages in batches of
  a passed in value or using the default of 50. The response is the same as
  `send_bulk/2`.
  """
  def send_in_batches(client, [%Message{} | _rest] = msgs, batches_of \\ 50)
      when is_number(batches_of) do
    Enum.chunk_every(msgs, batches_of)
    |> Enum.map(fn msgs_chunk ->
      with {:ok, data} <- __MODULE__.send_bulk(client, msgs_chunk), do: data
    end)
    |> List.flatten()
    |> then(fn data -> {:ok, data} end)
  end

  defp send_call(client, url, data) do
    try do
      case Req.post!(client, url: url, json: data) do
        %Req.Response{status: 200, body: body} ->
          {:ok, SendResponse.new(body)}

        %Req.Response{body: body} ->
          {:api_error, body}
      end
    rescue
      e ->
        {:error, Exception.format(:error, e)}
    end
  end

  @doc """
  Get the receipt for a message with the given source tracking ID.
  See: https://docs.paubox.com/docs/paubox_email_api/messages#get-email-disposition
  """
  def get_receipt(client, source_tracking_id) do
    Req.get!(client, url: "/message_receipt", params: [sourceTrackingId: source_tracking_id]).body
  end

  def client() do
    __MODULE__.client([])
  end

  def client(opts) when is_list(opts) do
    api_key = System.get_env("PAUBOX_API_KEY")
    api_user = System.get_env("PAUBOX_API_USER")
    __MODULE__.client(%{api_user: api_user, api_key: api_key}, opts)
  end

  def client(%{"api_user" => api_user, "api_key" => api_key}) do
    __MODULE__.client(%{api_user: api_user, api_key: api_key}, [])
  end

  def client(%{api_user: api_user, api_key: api_key}) do
    __MODULE__.client(%{api_user: api_user, api_key: api_key}, [])
  end

  def client(%{"api_user" => api_user, "api_key" => api_key}, opts) do
    __MODULE__.client(%{api_user: api_user, api_key: api_key}, opts)
  end

  def client(%{api_user: api_user, api_key: api_key}, opts) do
    api_url = @base_url |> URI.append_path("/#{api_user}") |> URI.to_string()

    [
      base_url: api_url,
      auth: "Token token=#{api_key}"
    ]
    |> Keyword.merge(opts)
    |> Req.new()
  end
end
