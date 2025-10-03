import express from "express";
import { supabase } from "../config/supabase.js";

const router = express.Router();

// Tüm hareketleri getir (ilişkili verilerle)
router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("stock_movements")
      .select(
        `
        *,
        product:products(id, sku, name),
        from_location:locations!stock_movements_from_location_id_fkey(id, name),
        to_location:locations!stock_movements_to_location_id_fkey(id, name),
        supplier:suppliers(id, company),
        user:users(id, full_name)
      `
      )
      .order("created_at", { ascending: false });

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

// Yeni hareket ekle (stok giriş/çıkış/transfer)
router.post("/", async (req, res) => {
  try {
    const {
      product_id,
      type,
      quantity,
      from_location_id,
      to_location_id,
      supplier_id,
      reason,
      reference,
    } = req.body;

    const { data, error } = await supabase.from("stock_movements").insert([
      {
        product_id,
        type,
        quantity,
        from_location_id,
        to_location_id,
        supplier_id,
        reason,
        reference,
      },
    ]).select(`
        *,
        product:products(id, sku, name)
      `);

    if (error) throw error;

    res.status(201).json({
      success: true,
      data: data[0],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
