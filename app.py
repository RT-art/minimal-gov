from flask import Flask

# Flaskアプリケーションインスタンスを作成 (Gunicornが 'app:app' で参照)
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello World! Deployed via GitHub Actions."

# ローカルでの開発時に `python app.py` で実行するための記述
# Gunicorn から起動される場合は、この部分は実行されない
if __name__ == '__main__':
    # デバッグモードは本番では無効にすること
    app.run(host='0.0.0.0', port=5000, debug=True)