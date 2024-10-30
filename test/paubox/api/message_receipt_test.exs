defmodule Paubox.API.MessageReceiptTest do
  use ExUnit.Case, async: true
  doctest Paubox.API.MessageReceipt

  alias Paubox.API.MessageReceipt

  @test_receipt_map %{
    "sourceTrackingId" => "6e1cf9a4-7bde-4834-8200-ed424b50c8a7",
    "data" => %{
      "message" => %{
        "id" => "<f4a9b518-439c-497d-b87f-dfc9cc19194b@authorized_domain.com>",
        "message_deliveries" => [
          %{
            "recipient" => "recipient@host.com",
            "status" => %{
              "deliveryStatus" => "delivered",
              "deliveryTime" => "Mon, 23 Apr 2018 13:27:34 -0700",
              "openedStatus" => "opened",
              "openedTime" => "Mon, 23 Apr 2018 13:27:51 -0700"
            }
          }
        ]
      }
    }
  }

  describe "new/1" do
    test "create a simple MessageReceipt" do
      assert MessageReceipt.new(@test_receipt_map) == %MessageReceipt{
               data: %{
                 message: %{
                   id: "<f4a9b518-439c-497d-b87f-dfc9cc19194b@authorized_domain.com>",
                   message_deliveries: [
                     %{
                       status: %{
                         deliveryStatus: "delivered",
                         deliveryTime: "Mon, 23 Apr 2018 13:27:34 -0700",
                         openedStatus: "opened",
                         openedTime: "Mon, 23 Apr 2018 13:27:51 -0700"
                       },
                       recipient: "recipient@host.com"
                     }
                   ]
                 }
               },
               sourceTrackingId: "6e1cf9a4-7bde-4834-8200-ed424b50c8a7"
             }
    end
  end

  describe "id/1" do
    test "use the id helper" do
      assert MessageReceipt.new(@test_receipt_map) |> MessageReceipt.id() ==
               "<f4a9b518-439c-497d-b87f-dfc9cc19194b@authorized_domain.com>"
    end
  end

  describe "message_deliveries/1" do
    test "use the message_deliveries helper" do
      assert MessageReceipt.new(@test_receipt_map) |> MessageReceipt.message_deliveries() == [
               %{
                 status: %{
                   deliveryStatus: "delivered",
                   deliveryTime: "Mon, 23 Apr 2018 13:27:34 -0700",
                   openedStatus: "opened",
                   openedTime: "Mon, 23 Apr 2018 13:27:51 -0700"
                 },
                 recipient: "recipient@host.com"
               }
             ]
    end
  end
end
