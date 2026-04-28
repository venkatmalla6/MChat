import time

lyrics = [
    (5.0, "Maata Raani Mounam… Manase Thelipe"),
    (12.5, "Edha Chaatumaatu Gaanam… Kanule Kalipe Ee Vela"),
    (20.0, "Kallu Raase Nee Kallu Raase… Oka Chinni Kavitha Premenemo"),
    (29.0, "Adhi Chadivinappudu… Naa Pedhavi Chappudu"),
    (36.0, "Tholi Paate Naalo Palikinadhi.......")
]

input("Press ENTER exactly when the song starts...")

start_time = time.time()

for timestamp, line in lyrics:

    # Wait until timestamp
    while time.time() - start_time < timestamp:
        time.sleep(0.01)

    # Calculate per-letter delay based on line duration
    next_index = lyrics.index((timestamp, line)) + 1
    if next_index < len(lyrics):
        next_timestamp = lyrics[next_index][0]
        duration = next_timestamp - timestamp
    else:
        duration = 5  # default duration for last line

    letter_delay = duration / len(line)

    # Print letter by letter
    for char in line:
        print(char, end="", flush=True)
        time.sleep(letter_delay)

    print()