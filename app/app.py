import os
from flask import Flask, render_template_string

app = Flask(__name__)

# Récupérer le secret depuis la variable d'environnement
APP_SECRET = os.environ.get('APP_SECRET', 'NO_SECRET_PROVIDED')

# HTML template with simple cute styling
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Cute Flask App</title>
    <style>
        body {
            font-family: 'Comic Sans MS', cursive, sans-serif;
            background: #ffe6f2;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #ff66b2;
            font-size: 4em;
            margin-bottom: 20px;
        }
        p {
            color: #ff3399;
            font-size: 1.5em;
        }
        .heart {
            color: #ff0000;
            font-size: 3em;
            animation: beat 1s infinite;
        }
        @keyframes beat {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.2); }
        }
        button {
            background-color: #ff66b2;
            border: none;
            color: white;
            padding: 15px 30px;
            text-align: center;
            font-size: 1.2em;
            margin-top: 30px;
            cursor: pointer;
            border-radius: 12px;
            transition: 0.3s;
        }
        button:hover {
            background-color: #ff3399;
        }
        .secret-box {
            background: white;
            border: 2px dashed #ff66b2;
            border-radius: 10px;
            padding: 20px;
            margin: 30px auto;
            max-width: 500px;
        }
        .secret-label {
            color: #ff66b2;
            font-weight: bold;
            font-size: 1.2em;
        }
        .secret-value {
            color: #333;
            font-family: monospace;
            font-size: 1em;
            margin-top: 10px;
            word-break: break-all;
        }
    </style>
</head>
<body>
    <h1>Hello! <span class="heart">❤️</span></h1>
    <p>Welcome to my cute Flask app!</p>
    
    <div class="secret-box">
        <div class="secret-label">🔐 Secret from Vault:</div>
        <div class="secret-value">{{ secret }}</div>
    </div>
    
    <button onclick="alert('Yay! You clicked me!')">Click me!</button>
</body>
</html>
"""

@app.route("/")
def hello():
    return render_template_string(HTML_TEMPLATE, secret=APP_SECRET)

@app.route("/health")
def health():
    return {"status": "healthy", "secret_loaded": APP_SECRET != 'NO_SECRET_PROVIDED'}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)