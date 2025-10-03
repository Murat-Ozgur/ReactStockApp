import express from "express";
import { supabase } from "../config/supabase.js";

const router = express.Router();

// Tüm tedarikçileri getir (alfabetik)
router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("suppliers")
      .select("*")
      .eq("is_active", true)
      .order("company", { ascending: true });

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

// Yeni tedarikçi ekle
router.post("/", async (req, res) => {
  try {
    const { company, specialties, notes } = req.body;

    // Firma adını büyük harfe çevir
    const companyUpper = company.toUpperCase();

    const { data, error } = await supabase
      .from("suppliers")
      .insert([{ company: companyUpper, specialties, notes }])
      .select();

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

// Tedarikçi güncelle
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { company, specialties, notes, is_active } = req.body;

    const updateData = {};
    if (company) updateData.company = company.toUpperCase();
    if (specialties !== undefined) updateData.specialties = specialties;
    if (notes !== undefined) updateData.notes = notes;
    if (is_active !== undefined) updateData.is_active = is_active;

    const { data, error } = await supabase
      .from("suppliers")
      .update(updateData)
      .eq("id", id)
      .select();

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
