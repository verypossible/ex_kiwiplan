defmodule ExKiwiplan.VLink do
  require Logger
  @stx 2
  @etx 3
  @uppercase_chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  def extract_frame(<<@stx, data::binary>>) do
    {frame, buffer} =
      :binary.bin_to_list(data)
      |> Enum.split_while(fn byte ->
        byte !== @etx
      end)

    case buffer do
      [@etx | remainder] ->
        {
          <<@stx>> <> :binary.list_to_bin(frame) <> <<@etx>>,
          case remainder do
            [] -> ""
            _ -> :binary.list_to_bin(remainder)
          end
        }

      _ ->
        {"", <<@stx>> <> data}
    end
  end

  def extract_frame("") do
    {"", ""}
  end

  def extract_frame(<<data::binary>>) do
    {_frame, buffer} =
      :binary.bin_to_list(data)
      |> Enum.split_while(fn byte ->
        byte !== @stx
      end)

    {"", buffer}
  end

  def parse_frame!(<<@stx, message_id::bytes-size(2), data::binary>>) do
    <<@etx, data::binary>> =
      data |> :binary.bin_to_list() |> Enum.reverse() |> :binary.list_to_bin()

    data = data |> :binary.bin_to_list() |> Enum.reverse() |> :binary.list_to_bin()
    {command, parsed} = parse_command(data)
    %{message_id: message_id, command: command, data: parsed}
  end

  def parse_command(data) do
    <<command::bytes-size(2), data::binary>> = data
    {command, parse_data(data)}
  end

  def parse_data(data, parsed \\ %{}) do
    case data do
      <<element::bytes-size(2), data::binary>> ->
        data_chars = String.to_charlist(data)

        case Stream.chunk_every(data_chars, 2, 1, :discard)
             |> Stream.map(&List.to_string/1)
             |> Enum.find_index(&uppercase_alpha?/1) do
          nil ->
            Map.put(parsed, element, List.to_string(data_chars))

          index ->
            index = index
            data = Enum.slice(data_chars, index..-1)
            data_chars = Enum.slice(data_chars, 0..(index - 1))

            parse_data(
              List.to_string(data),
              Map.put(parsed, element, List.to_string(data_chars))
            )
        end

      "" ->
        nil
    end
  end

  def ack_message(%{command: _command, data: _data, message_id: message_id}) do
    <<@stx>> <> message_id <> "AK" <> <<@etx>>
  end

  def serialize_message(%{command: command, data: data, message_id: message_id}) do
    <<@stx>> <> message_id <> command <> serialize_data(data) <> <<@etx>>
  end

  def serialize_data(nil) do
    ""
  end

  def serialize_data(data) do
    data
    |> Enum.reduce(
      fn {element, value}, acc ->
        acc <> Atom.to_string(element) <> value
      end,
      ""
    )
  end

  def uppercase_alpha?(str) do
    str
    |> String.codepoints()
    |> Enum.all?(&String.contains?(@uppercase_chars, &1))
  end
end
