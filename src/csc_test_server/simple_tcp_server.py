import socket


warning_message = (
    "⚠️ Unauthorized Access Detected ⚠️\n"
    "---------------------------------\n"
    "Hello there! It appears you're trying to connect to a restricted server.\n"
    "Unfortunately, your access credentials do not match our records.\n\n"
    "Please contact the system administrator if you believe this is an error.\n"
    "Your connection attempt has been logged. Have a great day!\n"
    "---------------------------------\n"
    "🔒 Secure Server 🔒"
)


# Create a socket object
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Define the host and port
host = '0.0.0.0'  # Localhost
port = 23455        # Choose a port that is free

# Bind to the port
server_socket.bind((host, port))

# Listen for incoming connections
server_socket.listen(5)

print(f"Server listening on {host}:{port}")

# Keep the server running
try:
    while True:
        # Accept a new connection
        client_socket, addr = server_socket.accept()
        print(f"Connected to {addr}")
        client_socket.send(warning_message.encode())

        try:
            client_socket.send(b'What is your message : ')
            message = client_socket.recv(1024)
            if not message:
                print("No message received. Closing connection.")
            else:
                print(f"Message from {addr}: {message.decode()}")
                # Send a response (optional)
                client_socket.send(b'Your message was received.\n')
        except socket.timeout:
            print(f"Timeout waiting for a message from {addr}.")
        except Exception as e:
            print(f"Error occurred: {e}")

        # Close the client connection
        client_socket.close()
except KeyboardInterrupt:
    print("\nServer is shutting down.")
    server_socket.close()
