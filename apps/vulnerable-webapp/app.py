"""
KOAD-S01: SSRF Vulnerable Web Application
ATT&CK: T1190 — Exploit Public-Facing Application

This Flask app intentionally contains an SSRF vulnerability.
DO NOT deploy in production environments.
"""

from flask import Flask, request, render_template_string
import requests as http_requests

app = Flask(__name__)

INDEX_HTML = """
<!DOCTYPE html>
<html>
<head><title>KOAD Vulnerable Web App</title></head>
<body>
<h1>Internal URL Fetcher</h1>
<p>Enter a URL to fetch its contents:</p>
<form method="POST" action="/fetch">
    <input type="text" name="url" size="60"
           placeholder="http://example.com" value="{{ url or '' }}">
    <button type="submit">Fetch</button>
</form>
{% if error %}
<h3 style="color:red">Error: {{ error }}</h3>
{% endif %}
{% if result %}
<h3>Response:</h3>
<pre>{{ result }}</pre>
{% endif %}
<hr>
<h2>SSRF Attack Examples</h2>
<ul>
    <li><code>http://mock-metadata.koad/latest/meta-data/</code> — Cloud Metadata API</li>
    <li><code>http://mock-metadata.koad/latest/meta-data/iam/security-credentials/</code> — IAM Credentials</li>
    <li><code>https://kubernetes.default.svc/api/v1/namespaces</code> — K8s API</li>
    <li><code>http://10.96.0.1:443/api</code> — K8s API via ClusterIP</li>
</ul>
</body>
</html>
"""


@app.route("/")
def index():
    return render_template_string(INDEX_HTML)


@app.route("/fetch", methods=["POST"])
def fetch():
    url = request.form.get("url", "")
    if not url:
        return render_template_string(INDEX_HTML, error="No URL provided")

    try:
        resp = http_requests.get(url, timeout=5, verify=False)
        return render_template_string(
            INDEX_HTML, result=resp.text[:5000], url=url
        )
    except Exception as e:
        return render_template_string(INDEX_HTML, error=str(e), url=url)


@app.route("/health")
def health():
    return "OK"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
