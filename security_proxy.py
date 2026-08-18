import http.server
import json
import re
import urllib.request

UPSTREAM = "http://localhost:3001"

INJECTION_PATTERNS = [
    r'(?i)(ignore|disregard|forget).*(previous|above|prior).*(instruction|prompt)',
    r'(?i)(you are now|act as|pretend to be|system:)',
    r'(?i)(read|cat|type|open|load).*(file|/etc|/home|/root|\.env|memory)',
    r'(?i)(execute|run|eval|exec).*(command|shell|bash|cmd)',
    r'(?i)(api[_-]?key|password|token|secret|credential).*(=|:)',
]

def scan_response(text):
    issues = []
    for p in INJECTION_PATTERNS:
        if re.search(p, text):
            issues.append(p[:40])
    return issues

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length)
        
        req = urllib.request.Request(
            UPSTREAM + self.path,
            data=body,
            headers={'Content-Type': 'application/json', 'Authorization': self.headers.get('Authorization', '')},
            method='POST'
        )
        
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                resp_body = resp.read().decode('utf-8', errors='replace')
            
            issues = scan_response(resp_body)
            if issues:
                print(f'⚠️ 检测到可疑内容: {issues}', flush=True)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(resp_body.encode())
        except Exception as e:
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode())
    
    def do_GET(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length) if length > 0 else None
        
        req = urllib.request.Request(
            UPSTREAM + self.path,
            headers={'Authorization': self.headers.get('Authorization', '')},
            method='GET'
        )
        
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                resp_body = resp.read()
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(resp_body)
        except Exception as e:
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode())
    
    def log_message(self, format, *args):
        pass

server = http.server.HTTPServer(('0.0.0.0', 3000), ProxyHandler)
print('🛡️ 安全代理启动: 0.0.0.0:3000 -> localhost:3001', flush=True)
server.serve_forever()
