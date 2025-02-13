import express from "express";
import path from "path";
import serveIndex from "serve-index";
import cors from "cors";
import addCounter from "./src/middleware/counter.js";

const app = express();
const port = 3000;
const __dirname = path.resolve();
app.use(cors());
app.use(express.static(path.join(__dirname, "public")));

app.get("/", addCounter, (req, res) => {
  res.sendFile(path.join(__dirname, "src/views", "index.html"));
});

app.use(
  "/file",
  addCounter,
  express.static(path.join(__dirname, "src/files")),
  serveIndex(path.join(__dirname, "src/files"), { icons: true })
);

app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "src/views", "not-found.html"));
});

app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});
