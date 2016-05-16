[
  name: "curl -X GET http://google.pl",
  name2: "curl -X POST http://twitter.com",
  test: ~s"""
  curl -X POST --header "Accept:application/json" --header "Content-Type:application/json" https://www.globalvcard.com/v2/tokens -d "{username: 'user@example.com', password: 'thepassword'}"
  """
]
