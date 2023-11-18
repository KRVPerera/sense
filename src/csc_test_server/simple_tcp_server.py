import socket
import threading
from flask import Flask, jsonify
from flask_cors import CORS, cross_origin

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

messages = []  # List to store messages from TCP clients

warning_message = (
    "⚠️ Unauthorized Access Detected ⚠️\n"
    "------------------------------------------------------------------------\n"
    "Hello there! It appears you're trying to connect to a restricted server.\n"
    "Unfortunately, your access credentials do not match our records.\n\n"
    "Please contact the system administrator if you believe this is an error.\n"
    "Your connection attempt has been logged. Have a great day!\n\n"
    "Only Group 12 students can use this!\n"
    "------------------------------------------------------------------------\n"
    "🔒 Secure Server 🔒"
)

max_messages = 100  # Maximum number of messages to store
sequence = 0

# Function to Manage Message List Size
def manage_messages():
    global sequence
    if len(messages) > max_messages:
        del messages[:max_messages//2]  # Delete the first 10 messages
        sequence = 0

# TCP Server Logic
def tcp_server():
    global sequence
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('0.0.0.0', 23455))  # TCP Server Port
    server_socket.listen(5)

    while True:
        client_socket, addr = server_socket.accept()
        print(f"Connected to {addr}")

        client_socket.send(warning_message.encode())  # Send warning message

        try:
            client_socket.send(b'\n\nWhat is your message: ')
            message = client_socket.recv(1024)
            if not message:
                print("No message received. Closing connection.")
            else:
                decoded_message = message.decode()
                sequence += 1
                print(f"Message from {addr}: {decoded_message}")
                formatted_message = f"#{sequence}: {decoded_message}"
                messages.append(formatted_message)  # Store the received message
                manage_messages()
        except socket.timeout:
            print(f"Timeout waiting for a message from {addr}.")
        except Exception as e:
            print(f"Error occurred: {e}")

        client_socket.close()

# Flask App Route to Get Messages
@app.route('/messages', methods=['GET'])
@cross_origin()
def get_messages():
    return jsonify(messages)

# Running TCP Server in a Thread
threading.Thread(target=tcp_server, daemon=True).start()

# Flask App Execution
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5001, use_reloader=False)  # Flask Server Port
