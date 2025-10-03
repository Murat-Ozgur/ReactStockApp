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

-- 5. Demo Ürünler (Birkaç örnek - gerçek ürünleri sen ekleyeceksin)
WITH categories_map AS (
    SELECT id, code FROM categories
),
admin_user AS (
    SELECT id FROM users WHERE email = 'admin@stok.com' LIMIT 1
)
INSERT INTO products (sku, name, description, category_id, unit_price, min_stock, barcode, created_by)
SELECT 
    'OBA-001',
    'Fren Balata Takımı Ön',
    'Ön fren balata seti - çeşitli araç modelleri',
    (SELECT id FROM categories_map WHERE code = 'OBA'),
    450.00,
    5,
    '8699876543210',
    (SELECT id FROM admin_user)
UNION ALL
SELECT 
    'YAF-001',
    'Motor Yağ Filtresi',
    'Yağ filtresi - çeşitli araç modelleri',
    (SELECT id FROM categories_map WHERE code = 'YAF'),
    85.00,
    10,
    '8699876543211',
    (SELECT id FROM admin_user)
UNION ALL
SELECT 
    'OAM-001',
    'Amortisör Ön',
    'Ön amortisör - çeşitli araç modelleri',
    (SELECT id FROM categories_map WHERE code = 'OAM'),
    1250.00,
    3,
    '8699876543212',
    (SELECT id FROM admin_user);

-- 6. Demo Stok Hareketleri (Birkaç örnek)
WITH demo_products AS (
    SELECT id, sku FROM products WHERE sku IN ('OBA-001', 'YAF-001')
),
demo_suppliers AS (
    SELECT id, company FROM suppliers WHERE company IN ('MARTAŞ', 'ÖZAŞ')
),
demo_user AS (
    SELECT id FROM users WHERE email = 'depo@stok.com' LIMIT 1
),
demo_location AS (
    SELECT id FROM locations WHERE name = 'Ana Depo' LIMIT 1
)
INSERT INTO stock_movements (product_id, type, quantity, to_location_id, supplier_id, reason, reference, user_id)
SELECT 
    (SELECT id FROM demo_products WHERE sku = 'OBA-001'),
    'in',
    20,
    (SELECT id FROM demo_location),
    (SELECT id FROM demo_suppliers WHERE company = 'MARTAŞ'),
    'İlk stok girişi',
    'FT-2024-001',
    (SELECT id FROM demo_user)
UNION ALL
SELECT 
    (SELECT id FROM demo_products WHERE sku = 'YAF-001'),
    'in',
    30,
    (SELECT id FROM demo_location),
    (SELECT id FROM demo_suppliers WHERE company = 'ÖZAŞ'),
    'İlk stok girişi',
    'FT-2024-002',
    (SELECT id FROM demo_user);

-- Bir satış örneği
WITH demo_product AS (
    SELECT id FROM products WHERE sku = 'OBA-001' LIMIT 1
),
demo_user AS (
    SELECT id FROM users WHERE email = 'depo@stok.com' LIMIT 1
),
demo_location AS (
    SELECT id FROM locations WHERE name = 'Satış Mağazası' LIMIT 1
)
INSERT INTO stock_movements (product_id, type, quantity, from_location_id, reason, reference, user_id)
SELECT 
    (SELECT id FROM demo_product),
    'out',
    8,
    (SELECT id FROM demo_location),
    'Müşteri satışı',
    'SAT-2024-001',
    (SELECT id FROM demo_user);

-- 6. Demo Stok Hareketleri (Birkaç örnek)
WITH demo_products AS (
    SELECT id, sku FROM products WHERE sku IN ('OBA-001', 'YAF-001')
),
demo_suppliers AS (
    SELECT id, company FROM suppliers WHERE company IN ('MARTAŞ', 'ÖZAŞ')
)
INSERT INTO stock_movements (product_id, type, quantity, to_location_id, supplier_id, reason, reference, user_id)
SELECT 
    (SELECT id FROM demo_products WHERE sku = 'OBA-001'),
    'in',
    20,
    'l1l1l1l1-l1l1-l1l1-l1l1-111111111111',
    (SELECT id FROM demo_suppliers WHERE company = 'MARTAŞ'),
    'İlk stok girişi',
    'FT-2024-001',
    'u1u1u1u1-u1u1-u1u1-u1u1-222222222222'
UNION ALL
SELECT 
    (SELECT id FROM demo_products WHERE sku = 'YAF-001'),
    'in',
    30,
    'l1l1l1l1-l1l1-l1l1-l1l1-111111111111',
    (SELECT id FROM demo_suppliers WHERE company = 'ÖZAŞ'),
    'İlk stok girişi',
    'FT-2024-002',
    'u1u1u1u1-u1u1-u1u1-u1u1-222222222222';

-- Bir satış örneği
INSERT INTO stock_movements (product_id, type, quantity, from_location_id, reason, reference, user_id)
SELECT 
    (SELECT id FROM products WHERE sku = 'OBA-001'),
    'out',
    8,
    'l1l1l1l1-l1l1-l1l1-l1l1-222222222222',
    'Müşteri satışı',
    'SAT-2024-001',
    'u1u1u1u1-u1u1-u1u1-u1u1-222222222222';