defmodule Test.Dummmymodule do
  use HTTPoison.Base

  @endpoint "https://www.globalvcard.com/v2/"

  def process_url(url), do: endpoint <> url

  def create_card(user, thepassword) do
    request(:post, "tokens", "{username: '#{user}', password: '#{thepassword}'}", ["Accept:application/json", "Content-Type:application/json"], [])
  end
  
  def list_all_tokens(authtoken) do
    request(:get, "tokens", "", ["Accept:application/json", "Content-Type:application/json", "AUTH:#{authtoken}"], [])
  end
  
  def list_companies(authtoken) do
    request(:get, "companies", "", ["AUTH:#{authtoken}"], [])
  end
end
