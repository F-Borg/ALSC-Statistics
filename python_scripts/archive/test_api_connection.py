"""Quick manual smoke test: confirms .api_credentials.yml can authenticate against the PlayHQ API."""

import python_scripts.api_playhq as api
import http.client

import importlib
importlib.reload(api)

client = api.PlayHQClient(association='asca')
print(f"Using organisation_id={client.organisation_id}, tenant={client.tenant}")

seasons = client.get_seasons()
print(f"Connection OK - found {len(seasons)} season(s):")
for season in seasons:
    print(f"  {season['id']}  {season['name']}")












# ALSC
conn = http.client.HTTPSConnection("api.playhq.com")
payload = ''
headers = {
  'Accept': 'application/json',
  'x-api-key': '4ad0ac44-1743-4e13-bed5-06c0041a79de',
  'x-phq-tenant': 'ca'
}
conn.request("GET", "/v1/organisations/b0a4e326-e1e0-4f2f-b33f-39b1ad687f0d/seasons", payload, headers)
res = conn.getresponse()
data = res.read()
print(data.decode("utf-8"))


# asca
conn = http.client.HTTPSConnection("api.playhq.com")
payload = ''
headers = {
  'Accept': 'application/json',
  'x-api-key': '5082141e-0a3e-4118-9c9c-4b212858d357',
  'x-phq-tenant': 'ca'
}
conn.request("GET", "/v1/organisations/e27e550f-6add-44d1-9caf-b633fad95702/seasons", payload, headers)
res = conn.getresponse()
data = res.read()
print(data.decode("utf-8"))

# atca
conn = http.client.HTTPSConnection("api.playhq.com")
payload = ''
headers = {
  'Accept': 'application/json',
  'x-api-key': '6951e01c-2ee3-434c-84da-df8b0cfd7f1b',
  'x-phq-tenant': 'ca'
}
conn.request("GET", "/v1/organisations/73f2cc76-b400-4938-9be3-79bd0d87dbbf/seasons", payload, headers)
res = conn.getresponse()
data = res.read()
print(data.decode("utf-8"))

# SACA Junior
conn = http.client.HTTPSConnection("api.playhq.com")
payload = ''
headers = {
  'Accept': 'application/json',
  'x-api-key': '69eae451-5212-46ce-a4e6-cdbedaf1b36c',
  'x-phq-tenant': 'ca'
}
conn.request("GET", "/v1/organisations/07929bc7-78b3-4c04-aa27-a41f3f0a8868/seasons", payload, headers)
res = conn.getresponse()
data = res.read()
print(data.decode("utf-8"))