import requests
import gzip
import json
import os

def is_gzipped(file_path):
    """Check if the file is gzipped by reading its first two bytes (Gzip magic number)."""
    with open(file_path, "rb") as f:
        return f.read(2) == b'\x1f\x8b'  # Gzip files start with 0x1f 0x8b

def fetch_and_extract_default_cards():
    base_url = "https://api.scryfall.com/bulk-data"
    
    response = requests.get(base_url)
    if response.status_code != 200:
        print("Failed to fetch bulk data list.")
        return
    
    data = response.json()
    default_cards_entry = next((item for item in data["data"] if item["type"] == "default_cards"), None)
    
    if not default_cards_entry:
        print("No default_cards entry found.")
        return
    
    download_url = default_cards_entry["download_uri"]
    print(f"Downloading default cards data from: {download_url}")
    
    download_response = requests.get(download_url, stream=True)
    if download_response.status_code != 200:
        print("Failed to download default cards data.")
        return
    
    gz_file_name = "default_cards.json.gz"
    json_file_name = "default_cards.json"

    # Save the file
    with open(gz_file_name, "wb") as file:
        for chunk in download_response.iter_content(chunk_size=8192):
            file.write(chunk)

    # Check if it's actually gzipped
    if is_gzipped(gz_file_name):
        print("File is gzipped. Extracting...")
        with gzip.open(gz_file_name, "rt", encoding="utf-8") as gz_file:
            with open(json_file_name, "w", encoding="utf-8") as json_file:
                json_file.write(gz_file.read())
    else:
        print("File is NOT gzipped. Renaming to JSON.")
        os.rename(gz_file_name, json_file_name)

    print(f"Extracted JSON saved as {json_file_name}")

if __name__ == "__main__":
    fetch_and_extract_default_cards()
