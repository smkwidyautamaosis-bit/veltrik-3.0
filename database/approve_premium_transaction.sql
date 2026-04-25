-- PostgreSQL Script untuk Membuat Fungsi RPC approval
-- PENTING: Gunakan 'CREATE OR REPLACE FUNCTION' sebagai standar PostgreSQL 
-- agar tidak error jika fungsi dijalankan ulang (timpa fungsi lama jika sudah ada).

CREATE OR REPLACE FUNCTION approve_premium_transaction(t_id UUID, u_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER -- Menjalankan fungsi dengan hak istimewa pembuat (bypass RLS untuk aksi ini)
AS $$
DECLARE
    caller_role TEXT;
BEGIN
    -- 1. Verifikasi bahwa pemanggil fungsi adalah pengguna yang terautentikasi
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Unauthorized: Anda harus login untuk melakukan aksi ini.';
    END IF;

    -- 2. Ambil 'role' dari pengguna yang sedang memanggil RPC
    SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();

    -- 3. Cek apakah pengguna tersebut adalah 'admin'
    IF caller_role != 'admin' THEN
        RAISE EXCEPTION 'Forbidden: Hanya admin yang diizinkan menyetujui transaksi.';
    END IF;

    -- 4. Jika validasi lolos, update status transaksi menjadi 'approved'
    UPDATE transactions 
    SET status = 'approved' 
    WHERE id = t_id;

    -- 5. Berikan akses premium kepada user terkait
    UPDATE profiles 
    SET is_premium = true 
    WHERE id = u_id;
END;
$$;
