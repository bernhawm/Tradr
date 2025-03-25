// app.js

document.addEventListener("DOMContentLoaded", function () {
    if (window.location.pathname === "/collection.html") {
      console.log("Fetching collection...");  // Log to check if the page is loading and the function is being called.
      fetchCollection();
    }
  });
  
  function fetchCollection() {
    console.log("Starting fetch request for collection...");  // Log before initiating the fetch request.
    fetch("http://localhost:3000/api/collection")
      .then(response => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then(data => {
        console.log("Data fetched successfully:", data);  // Log the data returned by the API
        const collectionList = document.getElementById("collection-list");
        collectionList.innerHTML = '';
  
        if (data.collection && data.collection.length > 0) {
          data.collection.forEach(item => {
            const cardElement = document.createElement("div");
            cardElement.classList.add("card");
  
            cardElement.innerHTML = `
              <h3>${item.name}</h3>
              <p><strong>Set:</strong> ${item.set}</p>
              <p><strong>Collector Number:</strong> ${item.collector_number}</p>
              <p><strong>Price:</strong> $${item.usd_price}</p>
            `;
  
            collectionList.appendChild(cardElement);
          });
        } else {
          console.log("No cards found in collection.");  // Log if collection is empty.
        }
      })
      .catch(error => {
        console.error("Error fetching collection:", error);  // Log the error if the fetch fails
      });
  }
  