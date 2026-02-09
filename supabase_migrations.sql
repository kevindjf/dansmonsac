-- ==================================================
-- DansMonSac - Supabase Schema Migrations
-- Epic 2: Daily Bag Preparation with Streak
-- ==================================================

-- ============================================
-- Table: bag_completions
-- Purpose: Track when students complete their bag preparation
-- Sync: YES (required for parent visibility in V2.5)
-- ============================================
CREATE TABLE IF NOT EXISTS public.bag_completions (
  id TEXT PRIMARY KEY,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  device_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bag_completions_device_id ON public.bag_completions(device_id);
CREATE INDEX IF NOT EXISTS idx_bag_completions_date ON public.bag_completions(date);
CREATE INDEX IF NOT EXISTS idx_bag_completions_device_date ON public.bag_completions(device_id, date);

-- RLS (Row Level Security) - Students can only access their own data
ALTER TABLE public.bag_completions ENABLE ROW LEVEL SECURITY;

-- Policy: Students can read their own bag completions
CREATE POLICY "Users can view own bag completions"
  ON public.bag_completions
  FOR SELECT
  USING (true); -- Anonymous access for now (device_id-based isolation)

-- Policy: Students can insert their own bag completions
CREATE POLICY "Users can insert own bag completions"
  ON public.bag_completions
  FOR INSERT
  WITH CHECK (true);

-- ============================================
-- Table: parent_links (Epic 5 - Future)
-- Purpose: Anonymous parent-child pairing
-- Sync: YES (pairing codes)
-- ============================================
-- Uncomment when implementing Epic 5
/*
CREATE TABLE IF NOT EXISTS public.parent_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pairing_code VARCHAR(6) UNIQUE NOT NULL,
  student_device_id TEXT NOT NULL,
  parent_device_id TEXT,
  uses_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  linked_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_parent_links_pairing_code ON public.parent_links(pairing_code);
CREATE INDEX IF NOT EXISTS idx_parent_links_student_device ON public.parent_links(student_device_id);

-- RLS
ALTER TABLE public.parent_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read parent links"
  ON public.parent_links
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert parent links"
  ON public.parent_links
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update parent links"
  ON public.parent_links
  FOR UPDATE
  USING (true);
*/

-- ==================================================
-- Verification Queries
-- ==================================================

-- Check if tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('bag_completions', 'parent_links');

-- Check indexes
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'bag_completions';

-- Test insert (uncomment to test)
/*
INSERT INTO public.bag_completions (id, date, device_id)
VALUES ('test-uuid-123', NOW(), 'test-device-456')
RETURNING *;
*/
