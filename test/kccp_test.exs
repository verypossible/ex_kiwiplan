defmodule KCCPTest do
  use ExUnit.Case
  @stx 2
  @etx 3
  @sample_message_parsed %{
    command: "AP",
    data: %{
      "BC" => "194",
      "BL" => "1",
      "CB" => "642",
      "DN" => "S554",
      "EL" => "610",
      "EW" => "630",
      "FL" => "C",
      "JP" => "",
      "LP" => "5",
      "NL" => "2",
      "NT" => "2",
      "NW" => "1",
      "OB" => "DIECUT",
      "OC" => "Agricola T",
      "OI" => "3388",
      "OL" => "1232",
      "ON" => "160324",
      "OS" => "83631201",
      "OW" => "642",
      "PN" => "836312",
      "PP" => "A",
      "PQ" => "250",
      "PT" => "TS",
      "QS" => "16793",
      "SB" => "50",
      "C1" => "RBR"
    },
    message_id: "03"
  }

  def test_frame(msg_id, body, with_stx \\ true, with_etx \\ true) do
    case {with_stx, with_etx} do
      {true, true} -> <<@stx>> <> msg_id <> body <> <<@etx>>
      {true, false} -> <<@stx>> <> msg_id <> body
      {false, true} -> msg_id <> body <> <<@etx>>
      {false, false} -> msg_id <> body
    end
  end

  def test_frame_sample() do
    {:ok, frame} = File.read("sample_message")
    frame
  end

  test "extract_frame/1 parses messages with no remainder" do
    frame = test_frame("11", "AK")
    assert ExKiwiplan.KCCP.extract_frame(frame) == {frame, ""}
  end

  test "extract_frame/1 parses messages with remainder" do
    remainder = "whatever"
    frame = test_frame("11", "AK")
    frame_with_remainder = frame <> remainder
    assert ExKiwiplan.KCCP.extract_frame(frame_with_remainder) == {frame, remainder}
  end

  test "extract_frame/1 passes incomplete messages to the buffer" do
    frame = test_frame("11", "AK", true, false)
    assert ExKiwiplan.KCCP.extract_frame(frame) == {"", frame}
  end

  test "extract_frame/1 parses empty messages" do
    frame = ""
    assert ExKiwiplan.KCCP.extract_frame(frame) == {"", ""}
  end

  test "Ack message has the message_id in it" do
    msg_id = "11"
    input = %{command: "cmd", data: "data", message_id: msg_id}
    ack = test_frame(msg_id, "AK")
    assert ExKiwiplan.KCCP.ack_message(input) == ack
  end

  test "parse_frame" do
    frame = test_frame("11", "GGKKnore")

    expected = %{
      command: "GG",
      data: %{"KK" => "nore"},
      message_id: "11"
    }

    assert ExKiwiplan.KCCP.parse_frame!(frame) == expected
  end

  test "parse_frame with sample message" do
    frame = test_frame_sample()

    assert ExKiwiplan.KCCP.parse_frame!(frame) == @sample_message_parsed
  end

  test "serialize_message with sample message" do
    frame = ExKiwiplan.KCCP.serialize_message(@sample_message_parsed)

    assert ExKiwiplan.KCCP.parse_frame!(frame) == @sample_message_parsed
  end
end
