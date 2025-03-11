from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_docker():
    return 'terraform test version 1.0.0' 

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')