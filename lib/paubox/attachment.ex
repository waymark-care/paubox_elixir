defmodule Paubox.Attachment do
  use TypedStruct

  typedstruct do
    @typedoc """
    A Paubox email attachment. Additional info can be found at https://docs.paubox.com/docs/paubox_email_api/messages
    """

    field(:file_name, String.t(), enforce: true)
    field(:content_type, String.t(), enforce: true)
    field(:content, String.t(), enforce: true)
  end

  @doc """
  This will create a new Paubox.Attachment struct from a file. It will read the
  file in, encode it to base64, and set the content type based on the file
  extension. If no content type is found, it will default to text/plain.
  """
  def new(file_path) do
    path = Path.join(File.cwd!(), file_path)
    <<".", extention::binary>> = Path.extname(file_path)

    %Paubox.Attachment{
      file_name: Path.basename(file_path),
      content_type: Mail.MIME.type(extention) || Mail.MIME.type("txt"),
      content: File.read!(path) |> Mail.Encoders.Base64.encode()
    }
  end

  @doc """
  This will write the attachment to the specified directory. If no directory
  is specified, it will default to the current directory.
  """
  def output(%__MODULE__{} = attachment, outdir \\ ".") do
    content = Mail.Encoders.Base64.decode(attachment.content)

    outdir =
      if String.starts_with?(outdir, "/") do
        outdir
      else
        Path.join(File.cwd!(), outdir)
      end

    File.mkdir_p!(outdir)

    File.write!(Path.join(outdir, attachment.file_name), content)
  end
end
