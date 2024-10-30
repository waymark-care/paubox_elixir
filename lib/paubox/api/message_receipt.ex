defmodule Paubox.API.MessageReceipt do
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
      data: atomize!(data),
      sourceTrackingId: sourceTrackingId
    }
  end

  defp atomize!(data) do
    case data do
      nil -> nil
      [] -> []
      [h | t] -> [atomize!(h) | atomize!(t)]
      %{} -> for {k, v} <- data, into: %{}, do: {String.to_atom(k), atomize!(v)}
      _ -> data
    end
  end

  def id(%__MODULE__{} = receipt) do
    receipt.data.message.id
  end

  def message_deliveries(%__MODULE__{} = receipt) do
    receipt.data.message.message_deliveries
  end
end
