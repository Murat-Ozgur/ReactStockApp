import express from "express";
import { supabase } from "../config/supabase.js";

const router = express.Router();

// Tüm ürünleri getir (kategori bilgisiyle)
router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("products")
      .select(
        `
        *,
        category:categories(id, name, code, icon)
      `
      )
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

// SKU ile ürün ara
router.get("/sku/:sku", async (req, res) => {
  try {
    const { sku } = req.params;

    const { data, error } = await supabase
      .from("products")
      .select(
        `
        *,
        category:categories(id, name, code, icon)
      `
      )
      .eq("sku", sku)
      .single();

    if (error) throw error;

    res.json({
      success: true,
      data: data,
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      error: "Ürün bulunamadı",
    });
  }
});

// Barkod ile ürün ara
router.get("/barcode/:barcode", async (req, res) => {
  try {
    const { barcode } = req.params;

    const { data, error } = await supabase
      .from("products")
      .select(
        `
        *,
        category:categories(id, name, code, icon)
      `
      )
      .eq("barcode", barcode)
      .single();

    if (error) throw error;

    res.json({
      success: true,
      data: data,
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      error: "Ürün bulunamadı",
    });
  }
});

// Yeni ürün ekle
router.post("/", async (req, res) => {
  try {
    const {
      sku,
      name,
      description,
      oem_code,
      category_id,
      unit_price,
      min_stock,
      barcode,
    } = req.body;

    const { data, error } = await supabase.from("products").insert([
      {
        sku,
        name,
        description,
        oem_code,
        category_id,
        unit_price,
        min_stock,
        barcode,
      },
    ]).select(`
        *,
        category:categories(id, name, code, icon)
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

// Ürün güncelle
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const { data, error } = await supabase
      .from("products")
      .update(updateData)
      .eq("id", id).select(`
        *,
        category:categories(id, name, code, icon)
      `);

    if (error) throw error;

    res.json({
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
