-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  NeuroNest — Complete Supabase SQL Setup Script                ║
-- ║  Copy-paste this ENTIRE script into Supabase SQL Editor & Run  ║
-- ║  Generated for index.html (current version)                    ║
-- ╚══════════════════════════════════════════════════════════════════╝


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 1. PROFILES TABLE — stores user details
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  batch TEXT,
  avatar_gradient INTEGER DEFAULT 0,
  bio TEXT DEFAULT '',
  study_hours INTEGER DEFAULT 6,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read profiles" ON profiles;
CREATE POLICY "Anyone can read profiles"
  ON profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow insert for authenticated users" ON profiles;
CREATE POLICY "Allow insert for authenticated users"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 2. CHECK-INS TABLE — daily student submissions
--    Includes: lectures_attended, homework_completed, mcqs_solved,
--    backlogs (used by index.html submitCheckin & renderBacklogsUI)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS checkins (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  target TEXT NOT NULL,
  mood INTEGER NOT NULL CHECK (mood BETWEEN 1 AND 5),
  goals TEXT NOT NULL CHECK (goals IN ('Yes', 'No', 'Partial')),
  lectures_attended BOOLEAN DEFAULT false,
  homework_completed BOOLEAN DEFAULT false,
  mcqs_solved INTEGER DEFAULT 0,
  backlogs TEXT DEFAULT '',
  note TEXT DEFAULT '',
  study_hours REAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Students can insert own checkins" ON checkins;
CREATE POLICY "Students can insert own checkins"
  ON checkins FOR INSERT
  WITH CHECK (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can read own checkins" ON checkins;
CREATE POLICY "Students can read own checkins"
  ON checkins FOR SELECT
  USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Admins can read all checkins" ON checkins;
CREATE POLICY "Admins can read all checkins"
  ON checkins FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 3. MENTOR NOTES — notes the mentor writes about each student
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE IF NOT EXISTS mentor_notes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  mentor_id UUID REFERENCES profiles(id),
  note TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE mentor_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage notes" ON mentor_notes;
CREATE POLICY "Admins can manage notes"
  ON mentor_notes FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Students can read own notes" ON mentor_notes;
CREATE POLICY "Students can read own notes"
  ON mentor_notes FOR SELECT
  USING (auth.uid() = student_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 4. SEED DATA — Profiles
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO profiles (id, email, full_name, role, batch)
VALUES (
  '2a4d5b5e-be40-42ec-b2c7-162344376540',
  'sawantvedant2207@gmail.com',
  'Mentor',
  'admin',
  NULL
) ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, email, full_name, role, batch)
VALUES (
  '14ffb296-f69a-4043-96e3-c88d23ce69d2',
  'mainkararnav@gmail.com',
  'Arnav Mainkar',
  'student',
  'MHT-CET 2026'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, email, full_name, role, batch)
VALUES (
  '159ee0ab-da31-4ca8-890e-715d60f30135',
  'rohangadhave236@gmail.com',
  'Rohan Gadhave',
  'student',
  'MHT-CET 2026'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, email, full_name, role, batch)
VALUES (
  '2292e361-16d8-4386-a480-8204590f57e4',
  'kaushikpatel11042008@gmail.com',
  'Kaushik Patel',
  'student',
  'MHT-CET 2026'
) ON CONFLICT (id) DO NOTHING;


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  ✅ DONE — All 3 tables + RLS policies + seed data created     ║
-- ╚══════════════════════════════════════════════════════════════════╝
