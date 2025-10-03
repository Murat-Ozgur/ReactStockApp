-- Veritabanı şemasını temizle (geliştirme aşamasında)
DROP TABLE IF EXISTS stock_movements CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Kullanıcılar tablosu
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'staff')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Kategoriler tablosu
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    icon TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tedarikçiler tablosu (basitleştirilmiş)
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company TEXT NOT NULL UNIQUE,
    specialties TEXT[], -- Hangi kategorilerde ürün veriyor
    notes TEXT, -- Opsiyonel notlar
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lokasyonlar tablosu
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('warehouse', 'store', 'workshop', 'quarantine')),
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ürünler tablosu
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    oem_code TEXT, -- OEM kodu
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    unit_price NUMERIC(10,2) DEFAULT 0,
    min_stock INTEGER DEFAULT 0,
    stock INTEGER DEFAULT 0, -- Toplam stok (hesaplanacak)
    barcode TEXT UNIQUE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stok hareketleri tablosu
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('in', 'out', 'transfer')),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    from_location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    to_location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    reason TEXT,
    reference TEXT, -- Fatura no, sipariş no vs.
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- İndeksler (performans için)
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_movements_product ON stock_movements(product_id);
CREATE INDEX idx_movements_date ON stock_movements(created_at);
CREATE INDEX idx_movements_type ON stock_movements(type);

-- Trigger: Ürün güncellendiğinde updated_at'i güncelle
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Stok hesaplama (gerçek zamanlı)
CREATE OR REPLACE FUNCTION calculate_product_stock(p_product_id UUID)
RETURNS INTEGER AS $$
DECLARE
    total_stock INTEGER;
BEGIN
    SELECT 
        COALESCE(SUM(
            CASE 
                WHEN type = 'in' THEN quantity
                WHEN type = 'out' THEN -quantity
                ELSE 0
            END
        ), 0)
    INTO total_stock
    FROM stock_movements
    WHERE product_id = p_product_id;
    
    RETURN total_stock;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Her hareket sonrası stok güncelle
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock = calculate_product_stock(NEW.product_id)
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_after_movement AFTER INSERT ON stock_movements
    FOR EACH ROW EXECUTE FUNCTION update_product_stock();

-- Row Level Security (RLS) Politikaları
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Herkese okuma izni (authenticated users)
CREATE POLICY "Allow read access to authenticated users" ON products
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to authenticated users" ON categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to authenticated users" ON suppliers
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to authenticated users" ON locations
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to authenticated users" ON stock_movements
    FOR SELECT TO authenticated USING (true);

-- Yazma izinleri (sadece admin ve manager)
CREATE POLICY "Allow insert for admin and manager" ON products
    FOR INSERT TO authenticated 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'manager')
        )
    );

CREATE POLICY "Allow update for admin and manager" ON products
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'manager')
        )
    );

-- Stok hareketleri için tüm authenticated users yazabilir
CREATE POLICY "Allow insert for authenticated users" ON stock_movements
    FOR INSERT TO authenticated
    WITH CHECK (true);