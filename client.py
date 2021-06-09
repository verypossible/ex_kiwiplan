from socket import socket


def kiwi_message(message, message_id):
    data = bytearray()
    data.append(2)
    data.extend("{:02d}".format(message_id).encode())
    data.extend(bytearray(message.encode()))
    data.append(3)
    return data


if __name__ == "__main__":
    i = 1
    s = socket()
    s.connect(("localhost", 4040))
    try:
        while True:
            data = input("message: ")
            print(repr(data))
            s.sendall(kiwi_message(data, i))
            i += 1
            print(s.recv(1024))
    except KeyboardInterrupt:
        s.close()
