"""
KOAD Mock Cloud Metadata API
Simulates AWS/GCP metadata endpoints for SSRF training.
"""

from flask import Flask, jsonify

app = Flask(__name__)

FAKE_CREDENTIALS = {
    "Code": "Success",
    "LastUpdated": "2026-01-15T00:00:00Z",
    "Type": "AWS-HMAC",
    "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
    "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "Token": "FwoGZXIvYXdzEBYaDFAKE_SESSION_TOKEN_EXAMPLE",
    "Expiration": "2026-01-16T00:00:00Z",
}


@app.route("/latest/meta-data/")
def metadata_root():
    return "\n".join([
        "ami-id",
        "hostname",
        "instance-id",
        "instance-type",
        "local-ipv4",
        "iam/",
        "network/",
    ])


@app.route("/latest/meta-data/ami-id")
def ami_id():
    return "ami-0abcdef1234567890"


@app.route("/latest/meta-data/hostname")
def hostname():
    return "ip-172-31-0-1.ec2.internal"


@app.route("/latest/meta-data/instance-id")
def instance_id():
    return "i-0123456789abcdef0"


@app.route("/latest/meta-data/instance-type")
def instance_type():
    return "m5.xlarge"


@app.route("/latest/meta-data/local-ipv4")
def local_ipv4():
    return "172.31.0.1"


@app.route("/latest/meta-data/iam/")
def iam_root():
    return "info\nsecurity-credentials/"


@app.route("/latest/meta-data/iam/info")
def iam_info():
    return jsonify({
        "Code": "Success",
        "InstanceProfileArn": "arn:aws:iam::123456789012:instance-profile/k8s-node-role",
        "InstanceProfileId": "AIPAEXAMPLE123456",
    })


@app.route("/latest/meta-data/iam/security-credentials/")
def iam_creds_list():
    return "k8s-node-role"


@app.route("/latest/meta-data/iam/security-credentials/k8s-node-role")
def iam_creds():
    return jsonify(FAKE_CREDENTIALS)


@app.route("/computeMetadata/v1/instance/service-accounts/default/token")
def gcp_token():
    return jsonify({
        "access_token": "ya29.FAKE_GCP_TOKEN_FOR_DEMO",
        "expires_in": 3600,
        "token_type": "Bearer",
    })


@app.route("/health")
def health():
    return "OK"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
