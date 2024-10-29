defmodule Paubox.AttachmentTest do
  use ExUnit.Case, async: true
  doctest Paubox.Attachment

  alias Paubox.Attachment

  @file_path "tmp.txt"
  @file_content "Hello, world!"
  @encoded_content Mail.Encoders.Base64.encode(@file_content)

  describe "new/1" do
    test "it creates an Attachment from a file" do
      create_tmp_file()

      attachment = Attachment.new(@file_path)

      assert attachment.file_name == @file_path
      assert attachment.content_type == "text/plain"
      assert attachment.content == @encoded_content
    end
  end

  describe "output/2" do
    setup do
      on_exit(fn -> File.rm(@file_path) end)
    end

    test "it creates an output file in the default location" do
      attachment = %Attachment{
        file_name: @file_path,
        content_type: "text/plain",
        content: @encoded_content
      }

      Attachment.output(attachment)

      assert File.read!(@file_path) == @file_content

      File.rm(@file_path)
    end

    test "it creates an output file in a specified location" do
      attachment = %Attachment{
        file_name: @file_path,
        content_type: "text/plain",
        content: @encoded_content
      }

      temp_dir = System.tmp_dir!()
      file_path = Path.join(temp_dir, @file_path)

      Attachment.output(attachment, temp_dir)
      assert File.read!(file_path) == @file_content

      File.rm(file_path)
    end
  end

  defp create_tmp_file do
    File.write!(@file_path, @file_content)
  end
end
