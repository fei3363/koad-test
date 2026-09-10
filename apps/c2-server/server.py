"""
KOAD Simulated C2 Server
Listens for heartbeats from "compromised" pods and logs them.
No actual malicious functionality — educational use only.
"""

import json
import socket
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime, timezone


class C2Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8", errors="replace")
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        print(f"[{ts}] BEACON from {self.client_address[0]}: {body[:500]}")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok", "cmd": "sleep"}).encode())

    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(
            b"[KOAD DEMO] C2 server running.\n"
            b"POST / with JSON body to simulate a beacon.\n"
        )

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 4444), C2Handler)
    print(f"[KOAD] C2 server listening on :4444 (simulation only)")
    server.serve_forever()
