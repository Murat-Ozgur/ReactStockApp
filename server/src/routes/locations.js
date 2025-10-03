import express from "express";
import { supabase } from "../config/supabase.js";

const router = express.Router();

// Tüm lokasyonları getir
router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("locations")
      .select("*")
      .eq("is_active", true)
      .order("name", { ascending: true });

    if (error) throw error;

    res.json({
      success: true,
      data: data,
      count: data.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
