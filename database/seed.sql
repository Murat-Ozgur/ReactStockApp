-- Demo verilerini ekle (development ortamı için)

-- 1. Kategoriler (alfabetik sıralı, sonradan eklenip düzenlenebilir)
INSERT INTO categories (name, code, icon, description) VALUES
('Arka Amortisör', 'AAM', '🔧', 'Arka amortisör parçaları'),
('Arka Balata', 'ABA', '🛑', 'Arka fren balata takımları'),
('Arka Disk', 'ADI', '💿', 'Arka fren disk parçaları'),
('Arka Porya', 'APO', '⚙️', 'Arka porya parçaları'),
('Bagaj Amortisörü', 'BAG', '📦', 'Bagaj amortisör parçaları'),
('Debriyaj Seti', 'DEB', '🔩', 'Debriyaj seti ve parçaları'),
('Ek Su Depo', 'ESD', '💧', 'Ek su deposu'),
('Hava Filtresi', 'HVF', '🌪️', 'Hava filtreleri'),
('Intercooler', 'INT', '❄️', 'Intercooler parçaları'),
('Kalorifer Peteği', 'KPE', '🔥', 'Kalorifer peteği parçaları'),
('Kampana', 'KAM', '🔄', 'Kampana parçaları'),
('Klima Radyatörü', 'KRA', '🌡️', 'Klima radyatörü parçaları'),
('Mazot Filtresi', 'MZF', '⛽', 'Mazot filtreleri'),
('Ön Amortisör', 'OAM', '🔧', 'Ön amortisör parçaları'),
('Ön Balata', 'OBA', '🛑', 'Ön fren balata takımları'),
('Ön Disk', 'ODI', '💿', 'Ön fren disk parçaları'),
('Ön Porya', 'OPO', '⚙️', 'Ön porya parçaları'),
('Polen Filtresi', 'POF', '🌸', 'Polen filtreleri'),
('Rot Başı', 'ROB', '🔩', 'Rot başı parçaları'),
('Rot Mili', 'ROM', '🔩', 'Rot mili parçaları'),
('Rotil', 'ROT', '🔩', 'Rotil parçaları'),
('Salıncak', 'SAL', '⚙️', 'Salıncak parçaları'),
('Su Fıskiye Depo', 'SFD', '💦', 'Su fıskiye deposu'),
('Su Radyatörü', 'SRA', '💧', 'Su radyatörü parçaları'),
('Triger Seti', 'TRI', '⚙️', 'Triger seti ve parçaları'),
('Yağ Filtresi', 'YAF', '🛢️', 'Yağ filtreleri'),
('Yağ Karteri', 'YKA', '🛢️', 'Yağ karteri parçaları'),
('Z-Rot', 'ZRO', '🔩', 'Z-Rot parçaları');

-- 2. Lokasyonlar
INSERT INTO locations (name, type, address) VALUES
('Ana Depo', 'warehouse', 'Sanayi Mah. Oto Sanayi Sit. No:45'),
('Satış Mağazası', 'store', 'Merkez Cad. No:123'),
('Servis Atölyesi', 'workshop', 'Sanayi Mah. Oto Sanayi Sit. No:47');

-- 3. Tedarikçiler (alfabetik sıralı)
INSERT INTO suppliers (company, is_active) VALUES
('AKBİLYA', true),
('AKTEKNİK', true),
('AKTİF', true),
('ALTAŞ', true),
('ALTAY', true),
('BAŞARAN', true),
('BAŞBUĞ', true),
('DAVET', true),
('DEGA', true),
('DİNAMİK', true),
('DOĞUŞ', true),
('EVREN', true),
('FORKA', true),
('GÜLER', true),
('LİMİT', true),
('MARTAŞ', true),
('MTZ', true),
('NEKO', true),
('OTO İSMAİL', true),
('ÖZAŞ', true),
('ÖZKAYALAR', true),
('R1', true),
('REMAR', true),
('TOK', true),
('VİZYON', true),
('YUKE', true),
('YÜKSEL', true);

-- 4. Demo Kullanıcılar
INSERT INTO users (email, full_name, role, is_active) VALUES
('admin@stok.com', 'Murat Admin', 'admin', true),
('depo@stok.com', 'Ahmet Depocu', 'staff', true),
('yonetici@stok.com', 'Zeynep Yönetici', 'manager', true);

-- Şimdi ilişkili verileri eklemek için ID'leri alalım

-- 5. Demo Ürünler
DO $$
DECLARE
    v_admin_id UUID;
    v_cat_oba_id UUID;
    v_cat_yaf_id UUID;
    v_cat_oam_id UUID;
BEGIN
    -- ID'leri al
    SELECT id INTO v_admin_id FROM users WHERE email = 'admin@stok.com';
    SELECT id INTO v_cat_oba_id FROM categories WHERE code = 'OBA';
    SELECT id INTO v_cat_yaf_id FROM categories WHERE code = 'YAF';
    SELECT id INTO v_cat_oam_id FROM categories WHERE code = 'OAM';
    
    -- Ürünleri ekle
    INSERT INTO products (sku, name, description, category_id, unit_price, min_stock, barcode, created_by) VALUES
    ('OBA-001', 'Fren Balata Takımı Ön', 'Ön fren balata seti - çeşitli araç modelleri', v_cat_oba_id, 450.00, 5, '8699876543210', v_admin_id),
    ('YAF-001', 'Motor Yağ Filtresi', 'Yağ filtresi - çeşitli araç modelleri', v_cat_yaf_id, 85.00, 10, '8699876543211', v_admin_id),
    ('OAM-001', 'Amortisör Ön', 'Ön amortisör - çeşitli araç modelleri', v_cat_oam_id, 1250.00, 3, '8699876543212', v_admin_id);
END $$;

-- 6. Demo Stok Hareketleri
DO $$
DECLARE
    v_user_id UUID;
    v_location_id UUID;
    v_product_oba UUID;
    v_product_yaf UUID;
    v_supplier_martas UUID;
    v_supplier_ozas UUID;
    v_location_magaza UUID;
BEGIN
    -- ID'leri al
    SELECT id INTO v_user_id FROM users WHERE email = 'depo@stok.com';
    SELECT id INTO v_location_id FROM locations WHERE name = 'Ana Depo';
    SELECT id INTO v_location_magaza FROM locations WHERE name = 'Satış Mağazası';
    SELECT id INTO v_product_oba FROM products WHERE sku = 'OBA-001';
    SELECT id INTO v_product_yaf FROM products WHERE sku = 'YAF-001';
    SELECT id INTO v_supplier_martas FROM suppliers WHERE company = 'MARTAŞ';
    SELECT id INTO v_supplier_ozas FROM suppliers WHERE company = 'ÖZAŞ';
    
    -- Stok girişleri
    INSERT INTO stock_movements (product_id, type, quantity, to_location_id, supplier_id, reason, reference, user_id) VALUES
    (v_product_oba, 'in', 20, v_location_id, v_supplier_martas, 'İlk stok girişi', 'FT-2024-001', v_user_id),
    (v_product_yaf, 'in', 30, v_location_id, v_supplier_ozas, 'İlk stok girişi', 'FT-2024-002', v_user_id);
    
    -- Bir satış
    INSERT INTO stock_movements (product_id, type, quantity, from_location_id, reason, reference, user_id) VALUES
    (v_product_oba, 'out', 8, v_location_magaza, 'Müşteri satışı', 'SAT-2024-001', v_user_id);
END $$;