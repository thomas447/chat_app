from flask import Flask, render_template
from flask_socketio import SocketIO, send, emit

app = Flask(__name__)
app.config['SECRET_KEY'] = '...'

socketio = SocketIO(app)

@app.route('/')
@app.route('/index')
def index():
	return render_template("index.html")

@socketio.on('connect')
def handle_connect():
	print("connected")
	emit('test', {"data": "this is a message"})

@socketio.on('test2')
def handle_test2(data):
	print("test2\n" + str(data))
	return "test2"

if __name__ == "__main__":
	socketio.run(app)
