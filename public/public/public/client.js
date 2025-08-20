public/client.js
const ws = new WebSocket(`ws://${location.hostname}:${location.port}`);

const healthFill = document.getElementById("health-fill");
const chatContainer = document.getElementById("chat-container");

let bossHealth = 100;

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  if (data.type === "chat") {
    const msg = document.createElement("div");
    msg.textContent = `${data.user}: ${data.text}`;
    chatContainer.appendChild(msg);
    chatContainer.scrollTop = chatContainer.scrollHeight;
  }

  if (data.type === "gift") {
    bossHealth -= data.count * 2;
    if (bossHealth < 0) bossHealth = 0;
    healthFill.style.width = bossHealth + "%";
  }
};
