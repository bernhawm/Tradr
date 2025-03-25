import React, { useEffect, useState } from "react";

const CollectionScreen = () => {
  const [collection, setCollection] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Fetch the collection data from the API
    const fetchCollection = async () => {
      try {
        const response = await fetch("http://localhost:3000/api/collection");
        const data = await response.json();
        setCollection(data.collection);
      } catch (err) {
        setError("Failed to fetch collection");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchCollection();
  }, []);

  if (loading) {
    return <div>Loading your collection...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  return (
    <div>
      <h2>Your Collection</h2>
      <ul>
        {collection.length === 0 ? (
          <li>No cards in your collection.</li>
        ) : (
          collection.map((card) => (
            <li key={card.id}>
              <strong>{card.name}</strong> ({card.set}) - ${card.usd_price}
            </li>
          ))
        )}
      </ul>
    </div>
  );
};

export default CollectionScreen;
