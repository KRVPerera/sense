import socket

# Create a socket object
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

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

        # Send a greeting message
        client_socket.send(b'Hello, you are connected to the server!\n')

        # Close the client connection
        client_socket.close()
except KeyboardInterrupt:
    print("\nServer is shutting down.")
    server_socket.close()
