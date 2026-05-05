MORSE_CODE = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z', '-----': '0', '.----': '1', '..---': '2',
    '...--': '3', '....-': '4', '.....': '5', '-....': '6',
    '--...': '7', '---..': '8', '----.': '9',
    '...---...': 'SOS'
}

def decode_morse(morse_code):
    words = morse_code.strip().split('   ')
    decoded_words = []
    for word in words:
        letters = word.split(' ')
        decoded_word = ''.join(MORSE_CODE[letter] for letter in letters if letter)
        decoded_words.append(decoded_word)
    return ' '.join(decoded_words)


# --- Run & Test ---
while True:
    user_input = input("\nEnter morse code (or 'quit' to exit): ")
    if user_input.lower() == 'quit':
        break
    try:
        result = decode_morse(user_input)
        print(f"Decoded: {result}")
    except KeyError as e:
        print(f"Unknown morse code: {e}")