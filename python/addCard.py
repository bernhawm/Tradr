import json
import csv
import sys

# File paths
JSON_FILE = "default_cards.json"
CSV_FILE = "collection.csv"

def load_cards():
    """Loads the default_cards.json file and returns the list of cards."""
    try:
        with open(JSON_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: {JSON_FILE} not found. Make sure it exists.")
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Failed to parse JSON file. Check the format.")
        sys.exit(1)

def find_cards_by_name(cards, search_name):
    """Returns a list of physical (paper) cards matching the given name (case-insensitive)."""
    return [
        card for card in cards
        if card["name"].lower() == search_name.lower() and "paper" in card.get("games", [])
        # if card["name"].lower() == search_name.lower() and "paper" in card.get("games", []) and card["digital"] == "false" 

    ]

def write_to_csv(card):
    """Appends a selected card's details to collection.csv."""
    fields = ["name", "set", "collector_number", "usd_price"]
    data = {
        "name": card["name"],
        "set": card["set"],
        "collector_number": card["collector_number"],
        "usd_price": card.get("prices", {}).get("usd", "N/A")  # Get price if available
    }

    # Check if CSV exists to write headers
    write_header = not csv_file_exists()

    with open(CSV_FILE, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        if write_header:
            writer.writeheader()
        writer.writerow(data)

def csv_file_exists():
    """Checks if the CSV file exists."""
    try:
        with open(CSV_FILE, "r", encoding="utf-8"):
            return True
    except FileNotFoundError:
        return False

def main():
    """Main function that handles searching and adding a card."""
    if len(sys.argv) < 2:
        print("Usage: python addCard.py <card_name>")
        sys.exit(1)

    search_name = " ".join(sys.argv[1:])
    print(f"Searching for: {search_name}...")

    cards = load_cards()
    matching_cards = find_cards_by_name(cards, search_name)

    if not matching_cards:
        print("No exact match found in the collection or no physical version available.")
        sys.exit(0)

    elif len(matching_cards) == 1:
        # Only one match, add it directly
        card = matching_cards[0]
        write_to_csv(card)
        print(f"Added {card['name']} ({card['set']}) to collection.csv!")

    else:
        # Multiple matches, prompt user to select one
        print("\nMultiple versions found. Select the correct version:")
        for idx, card in enumerate(matching_cards, 1):
            print(f"{idx}. {card['name']} - {card['set_name']} (Collector # {card['collector_number']})")

        while True:
            try:
                choice = int(input("\nEnter the number of the card to add: ")) - 1
                if 0 <= choice < len(matching_cards):
                    selected_card = matching_cards[choice]
                    write_to_csv(selected_card)
                    print(f"Added {selected_card['name']} ({selected_card['set']}) to collection.csv!")
                    break
                else:
                    print("Invalid selection. Try again.")
            except ValueError:
                print("Please enter a valid number.")

if __name__ == "__main__":
    main()
