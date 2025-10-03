import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { testConnection } from "./config/supabase.js";
import categoriesRouter from "./routes/categories.js";
import suppliersRouter from "./routes/suppliers.js";
import locationsRouter from "./routes/locations.js";
import productsRouter from "./routes/products.js";
import stockMovementsRouter from "./routes/stockMovements.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Bağlantıyı test et
testConnection();

// Test endpoints
app.get("/", (req, res) => {
  res.json({
    message: "Stok Takip API çalışıyor!",
    version: "1.0.0",
  });
});

app.get("/health", (req, res) => {
  res.json({ status: "OK", timestamp: new Date() });
});

// API Routes
app.use("/api/categories", categoriesRouter);
app.use("/api/suppliers", suppliersRouter);
app.use("/api/locations", locationsRouter);
app.use("/api/products", productsRouter);
app.use("/api/stock-movements", stockMovementsRouter);

// Server başlat
app.listen(PORT, () => {
  console.log(`🚀 Server ${PORT} portunda çalışıyor`);
  console.log(`📍 http://localhost:${PORT}`);
});
