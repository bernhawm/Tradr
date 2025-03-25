const express = require("express");
const fs = require("fs");
const path = require("path");
const app = express();
const port = 3000;
const bodyParser = require("body-parser");
const csvParser = require("csv-parser");

// Middleware to parse JSON
app.use(express.json());

// File paths
const JSON_FILE = path.join(__dirname, "default_cards.json");
const CSV_FILE = path.join(__dirname, "collection.csv");

// Function to load cards from the JSON file
function loadCards() {
  try {
    const data = fs.readFileSync(JSON_FILE, "utf-8");
    return JSON.parse(data);
  } catch (error) {
    console.error("Error loading cards:", error);
    return [];
  }
}

// Use bodyParser to parse JSON requests
app.use(bodyParser.json());

// Read JSON data (cards data)
const cardsData = JSON.parse(fs.readFileSync("default_cards.json", "utf8"));

// Helper function to find cards by name
function findCardByName(name) {
    return cardsData.filter((card) =>
      card.name.toLowerCase().includes(name.toLowerCase())
    );
  }
  
// Function to check if CSV file exists
function csvFileExists() {
  return fs.existsSync(CSV_FILE);
}

// Function to write to the CSV file
function writeToCsv(card) {
  const fields = ["id","name", "set", "collector_number", "usd_price"];
  const data = {
    id: card.id,
    name: card.name,
    set: card.set,
    collector_number: card.collector_number,
    usd_price: card.prices?.usd || "N/A", // Get price if available
  };

  const writeHeader = !csvFileExists();

  const csvString = `${data.id},${data.name},${data.set},${data.collector_number},${data.usd_price}\n`;
  // Write the header if the CSV file does not exist
  if (writeHeader) {
    const header = "id,name,set,collector_number,usd_price\n";
    fs.appendFileSync(CSV_FILE, header, "utf-8");
  }

  fs.appendFileSync(CSV_FILE, csvString, "utf-8");
}

// API Endpoint to get all cards
app.get("/api/cards", (req, res) => {
  const cards = loadCards();
  res.json(cards);
});

// API Endpoint to search for cards by name
app.post("/api/search", (req, res) => {
    const { cardName } = req.body; // Get the card name from the body
  
    if (!cardName) {
      return res.status(400).json({ error: "Card name is required" });
    }
  
    // Filter cards based on name and games attribute containing 'paper' (physical cards)
    const matchingCards = findCardByName(cardName).filter((card) => {
      // Ensure the card's name matches, it's in paper, and not digital
      return (
        card.name.toLowerCase() === cardName.toLowerCase() &&
        card.games && card.games.includes("paper") &&
        card.digital !== "True" // Assuming the digital attribute exists and is a string
      );
    });
  
    if (matchingCards.length === 0) {
      return res.status(404).json({ error: "No physical cards found" });
    }
  
    res.json(matchingCards);
  });

// API Endpoint to add a card to the collection (CSV)
app.post("/api/add-card", (req, res) => {
  const { cardId } = req.body;
  const cards = loadCards();
  const card = cards.find((card) => card.id === cardId);

  if (!card) {
    return res.status(404).json({ message: "Card not found." });
  }

  writeToCsv(card);
  res.status(200).json({ message: "Card added to collection successfully." });
});

const collectionFile = path.join(__dirname, "collection.csv");

app.get("/api/collection", (req, res) => {
    const collection = [];
  
    // Read the CSV file and parse the contents into an array of objects
    const csv = require("csv-parser");
    const { readFileSync } = require("fs");

    // Read the collection CSV file as a string
    const data = readFileSync(collectionFile, "utf8");
  
    // Parse CSV data into an array of records
    const records = data.split("\n").map((line) => {
      return line.split(",").map((field) => field.trim());
    });

    // Ensure we skip the header row and parse the remaining data
    records.slice(1).forEach((record) => {
      collection.push({
        id: record[0], // id is now the first column
        name: record[1],
        set: record[2],
        collector_number: record[3],
        usd_price: record[4],
        rarity: record[5], // Assuming rarity is now in the 6th column
        games: record[6] ? record[6].split(",") : [], // Assuming games is the 7th column
      });
    });
  
    // Respond with the collection
    res.json({ collection });
});


// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
