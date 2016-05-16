defmodule Curl2PoisonTest do
  use ExUnit.Case
  doctest Curl2Poison

  @url "http://google.pl"
  @header1 "Accept:application/json"
  @header2 "Content-Type:application/json"
  @data "{username: 'user@example.com', password: 'thepassword'}"

  @curl1 """
  curl -X POST --header "#{@header1}" --header "#{@header2}" #{@url} -d "#{@data}"
  """
  @correct_response1 """
  request(:post, "#{@url}", "#{@data}", ["#{@header1}", "#{@header2}"], [])
  """

  @curl2 """
  curl -X GET --header "#{@header1}" --header "#{@header2}" #{@url}
  """
  @correct_response2 """
  request(:get, "#{@url}", "", ["#{@header1}", "#{@header2}"], [])
  """

  test "parse curl" do
    code = Curl2Poison.parse_curl(@curl1 |> String.strip)
    assert code == @correct_response1
  end

  test "defaults data" do
    code = Curl2Poison.parse_curl(@curl2 |> String.strip)
    assert code == @correct_response2
  end
end
