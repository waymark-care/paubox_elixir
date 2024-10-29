defmodule Paubox.API.SendResponseTest do
  use ExUnit.Case, async: true
  doctest Paubox.API.SendResponse

  alias Paubox.API.SendResponse

  describe "new/1 - Map" do
    test "create a simple SendResponse" do
      response = %{"data" => "my-data", "sourceTrackingId" => "abc42"}

      assert SendResponse.new(response) == %SendResponse{
               data: "my-data",
               sourceTrackingId: "abc42"
             }
    end
  end

  describe "new/1 - List" do
    test "create a List of SendResponse items" do
      responses = %{
        "messages" => [
          %{"data" => "my-data", "sourceTrackingId" => "abc42"},
          %{"data" => "your-data", "sourceTrackingId" => "def42"}
        ]
      }

      assert SendResponse.new(responses) == [
               %SendResponse{
                 data: "my-data",
                 sourceTrackingId: "abc42"
               },
               %SendResponse{
                 data: "your-data",
                 sourceTrackingId: "def42"
               }
             ]
    end
  end

  describe "Jason encoder" do
    test "it encodes a simple SendResponse" do
      response = %SendResponse{
        data: "my-data",
        sourceTrackingId: "abc42"
      }

      assert Jason.encode!(response) == ~s({"data":"my-data","sourceTrackingId":"abc42"})
    end

    test "it encodes a List of SendResponse items" do
      responses = [
        %SendResponse{
          data: "my-data",
          sourceTrackingId: "abc42"
        },
        %SendResponse{
          data: "your-data",
          sourceTrackingId: "def42"
        }
      ]

      assert Jason.encode!(responses) ==
               ~s([{"data":"my-data","sourceTrackingId":"abc42"},{"data":"your-data","sourceTrackingId":"def42"}])
    end
  end
end
