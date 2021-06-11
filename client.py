from socket import socket
from sys import argv


def kiwi_message(message, message_id):
    data = bytearray()
    data.append(2)
    data.extend("{:02d}".format(message_id).encode())
    data.extend(bytearray(message.encode()))
    data.append(3)
    return data


if __name__ == "__main__":
    option = argv[1] if len(argv) > 1 else None
    if option == "-h":
        print(
            "Usage: python client.py [-f <filename>]"
        )
    else:
        i = 1
        s = socket()
        s.connect(("localhost", 4040))
        if option == "-f":
            s.sendall(open(argv[2], "rb").read())
            print(s.recv(1024))
            s.close()
        else:
            try:
                while True:
                    data = input("message: ")
                    print(repr(data))
                    s.sendall(kiwi_message(data, i))
                    i += 1
                    print(s.recv(1024))
            except KeyboardInterrupt:
                s.close()
