[
  create_card: """
  curl -X POST --header "Accept:application/json" --header "Content-Type:application/json" https://www.globalvcard.com/v2/tokens -d "{username: '{user}', password: '{thepassword}'}"
  """,
  list_all_tokens: """
  curl --header "Accept:application/json" --header "Content-Type:application/json" --header "AUTH:{authtoken}" https://www.globalvcard.com/v2/tokens
  """,
  list_companies: """
  curl --header "AUTH:{authtoken}" https://www.globalvcard.com/v2/companies
  """
]
