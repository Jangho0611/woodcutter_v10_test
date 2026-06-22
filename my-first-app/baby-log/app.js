const STORAGE_KEY = "babyLogFeeds";
const feedAmount = document.getElementById("feedAmount");
const feedBtn = document.getElementById("feedBtn");
const feedList = document.getElementById("feedList");
const emptyState = document.getElementById("emptyState");

let entries = [];

function loadEntries() {
  const saved = localStorage.getItem(STORAGE_KEY);
  entries = saved ? JSON.parse(saved) : [];
}

function saveEntries() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
}

function formatTime(value) {
  const date = value ? new Date(value) : new Date();
  return date.toLocaleString("ko-KR", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function createEntryElement(entry) {
  const li = document.createElement("li");
  li.className = "log-item";

  const meta = document.createElement("div");
  meta.className = "log-meta";
  meta.innerHTML = `
    <span>수유량: <strong>${entry.amount}ml</strong></span>
    <span>${formatTime(entry.time)}</span>
  `;

  const removeButton = document.createElement("button");
  removeButton.type = "button";
  removeButton.textContent = "삭제";
  removeButton.addEventListener("click", () => {
    removeEntry(entry.id);
  });

  li.append(meta, removeButton);
  return li;
}

function renderEntries() {
  feedList.innerHTML = "";

  if (entries.length === 0) {
    emptyState.style.display = "block";
    return;
  }

  emptyState.style.display = "none";

  const sorted = [...entries].sort((a, b) => new Date(b.time) - new Date(a.time));
  sorted.forEach((entry) => {
    feedList.appendChild(createEntryElement(entry));
  });
}

function addEntry(amount) {
  const entry = {
    id: Date.now().toString(),
    amount,
    time: new Date().toISOString(),
  };
  entries.push(entry);
  saveEntries();
  renderEntries();
}

function removeEntry(entryId) {
  entries = entries.filter((entry) => entry.id !== entryId);
  saveEntries();
  renderEntries();
}

feedBtn.addEventListener("click", () => {
  const amount = Number(feedAmount.value);
  if (!amount || amount <= 0) {
    alert("올바른 수유량을 입력하세요.");
    feedAmount.focus();
    return;
  }

  addEntry(amount);
  feedAmount.value = "";
  feedAmount.focus();
});

loadEntries();
renderEntries();
