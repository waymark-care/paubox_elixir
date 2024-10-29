defmodule Paubox.API.SendResponse do
  @moduledoc """
  This is a wrapper struct around the response from the Paubox API when sending
  messages.
  """
  use TypedStruct

  typedstruct do
    field(:data, String.t(), enforce: true)
    field(:sourceTrackingId, String.t(), enforce: true)
  end

  @doc """
  Create a new SendResponse struct from a map.

  If you pass in a List it will create a list of SendResponse structs. This is
  useful when sending messages using the bulk API.
  """
  def new(%{"data" => data, "sourceTrackingId" => sourceTrackingId}) do
    %__MODULE__{
      data: data,
      sourceTrackingId: sourceTrackingId
    }
  end

  def new(%{"messages" => [%{"data" => _data, "sourceTrackingId" => _id} | _rest]} = responses) do
    Enum.map(responses["messages"], &__MODULE__.new(&1))
  end
end

defimpl Jason.Encoder, for: Paubox.API.SendResponse do
  def encode(%Paubox.API.SendResponse{} = response, opts) do
    Jason.Encode.map(encode_response(response), opts)
  end

  defp encode_response(response) do
    %{
      data: response.data,
      sourceTrackingId: response.sourceTrackingId
    }
  end
end
