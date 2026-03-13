import requests
import time
import concurrent.futures

TOKEN = "eyJraWQiOiJOaUZYdUVxZkFTaXl1eHhBWGJRMDRNbm1hWTYzeHk4akZFVEliRjhLQ3BVPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJiNDc4YjQ5OC1lMGYxLTcwNDQtMTJhZi1mZjI4NWFlMzQ0NjUiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV91WjlERjZmRFUiLCJjb2duaXRvOnVzZXJuYW1lIjoidGhvbWFzLnlhbmcyQGdtYWlsLmNvbSIsIm9yaWdpbl9qdGkiOiJhNzJhNTFjOS1hMTYwLTRiZDItYjg0ZC05OTNlN2EzODg3ODgiLCJhdWQiOiIzbzExMHNjZjE0anRjNHFtaWFiaXJqMWN1NyIsImV2ZW50X2lkIjoiMTcwZmZhZmQtYTkxNi00NmE4LWIxOWUtNmE5MjA0Y2E5ZjQ1IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE3NzMzNzk3NjMsImV4cCI6MTc3MzM4MzM2MywiaWF0IjoxNzczMzc5NzYzLCJqdGkiOiIxZjE3ZGYxYy0zNDE2LTQ3ZmEtYjQ4NC0wNjY3NjAxMGU0YzIiLCJlbWFpbCI6InRob21hcy55YW5nMkBnbWFpbC5jb20ifQ.ZPaOY2-1J9i_Tx1iGrw3O76Qv16oO1vM0nNRjVFllJcEEOtMuUgz-nxN3bIvlw1JhR0cKFXah2z1UjP4UhqtPlw7wsshMfhSyWkJ7PFN2vkkCDl1LUhuAQVvkdToytLqy8aT1HfKXsbBPs09ZRH1eqw2qblXPoTSBu3RrsoT212A4FqyNfVTmpLVwiH77zPhSAuUth9Y-uSNLreCn_OatD9PSjWVeeyLfch-kkBeEa-x8OVHsyC5AK7n2S1urkowbyxbIDvgCsS0K_EV9hT4ltiM3pgFqdZBTKxY-mfNdQzXZjvMuE3X4jTi4R2dTtBWbTWnR8pjMlLImyqNmoZnvQ"

API_US = "https://gx55zruuli.execute-api.us-east-1.amazonaws.com"
API_EU = "https://nuuvabun6f.execute-api.eu-west-1.amazonaws.com"

apis = [
    f"{API_US}/greet",
    f"{API_EU}/greet",
    f"{API_US}/dispatch",
    f"{API_EU}/dispatch"    
]

def call_api(url):

    start = time.time()

    r = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json"
        },
        json={}
    )

    latency = time.time() - start

    return url, r.status_code, r.text, latency


with concurrent.futures.ThreadPoolExecutor() as executor:
    results = executor.map(call_api, apis)

for r in results:
    print(r)