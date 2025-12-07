-- ============================================
-- Mobile Scanner Database Initialization
-- Products table with barcode support + LLM
-- ============================================

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price DECIMAL(10, 2),
    stock INTEGER DEFAULT 0,
    manufacturer VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on barcode for fast lookups
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);

-- Insert sample products with real EAN-13 barcodes
INSERT INTO products (barcode, name, description, category, price, stock, manufacturer) VALUES
(
    '5901234123457',
    'Coca-Cola 330ml',
    'Beguda refrescant amb gas. Llauna de 330ml. Conté cafeïna i sucre. Ideal per acompanyar àpats o com a refresc.',
    'Begudes',
    1.50,
    150,
    'The Coca-Cola Company'
),
(
    '8410076472106',
    'Danone Activia Natural 4x125g',
    'Iogurt natural amb bífidus actius. Pack de 4 unitats de 125g. Sense gluten. Ajuda a la digestió i és font de calci.',
    'Lactis',
    2.85,
    75,
    'Danone'
),
(
    '8480000123459',
    'Mercadona Oli d''Oliva Verge Extra 1L',
    'Oli d''oliva verge extra de primera pressió en fred. Ampolla de 1 litre. Ideal per cuinar i amanir. Producte de qualitat superior.',
    'Alimentació',
    5.99,
    200,
    'Mercadona'
)
ON CONFLICT (barcode) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create view for product statistics
CREATE OR REPLACE VIEW product_stats AS
SELECT 
    category,
    COUNT(*) as total_products,
    SUM(stock) as total_stock,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM products
GROUP BY category;

-- Grant permissions (if needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO mobilscan;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO mobilscan;

-- Display inserted data
SELECT 
    '✅ Database initialized successfully!' as status,
    COUNT(*) as total_products 
FROM products;

SELECT 
    barcode,
    name,
    category,
    price,
    stock
FROM products
ORDER BY id;
