import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY; // Service key kullan

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error(
    "Supabase URL ve Service Key tanımlanmamış! .env dosyasını kontrol edin."
  );
}

export const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Bağlantıyı test et
export const testConnection = async () => {
  try {
    const { data, error } = await supabase.from("categories").select("count");
    if (error) throw error;
    console.log("✅ Supabase bağlantısı başarılı");
    return true;
  } catch (error) {
    console.error("❌ Supabase bağlantı hatası:", error.message);
    return false;
  }
};
