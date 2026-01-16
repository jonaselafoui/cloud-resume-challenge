const COUNTER_URL = "https://0jtwgu4iei.execute-api.eu-central-1.amazonaws.com/count";

async function updateVisitorCount() {
  try {
    const res = await fetch(COUNTER_URL);
    const data = await res.json();
    document.getElementById("visitor-count").textContent = data.count;
  } catch (e) {
    console.error("Counter error:", e);
  }
}

document.addEventListener("DOMContentLoaded", updateVisitorCount);
