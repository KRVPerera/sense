import struct

def decodeTemperature(message):
    data_out = []
    message = list(map(int, message[:-1].strip().split(',')))
    for i in range(0, len(message), 2):
        value, parity = message[i], message[i + 1]
        if (parityCheck(value, parity)):
            data_out.append(value/100)
        else:
            if 0 < i and i + 2 < len(message):
                prev_value, next_value = message[i - 2], message[i + 2]
                interpolated_value = (prev_value + next_value) // 2
                data_out.append(interpolated_value)
    return data_out

#checking odd parity
def parityCheck(value, parity):
    ones_count = bin(int(value)).count('1')
    return (ones_count + int(parity)) % 2 == 1
