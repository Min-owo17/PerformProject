-- PerformProject 데이터베이스 초기 스키마
-- 생성일: 2024

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- 텍스트 검색용

-- 1. users 테이블
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    nickname VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. user_profiles 테이블
CREATE TABLE IF NOT EXISTS user_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE UNIQUE,
    instruments TEXT[],
    user_type VARCHAR(50),
    bio TEXT,
    hashtags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. practice_sessions 테이블
CREATE TABLE IF NOT EXISTS practice_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    practice_date DATE NOT NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    actual_play_time INTEGER DEFAULT 0,
    instrument VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. groups 테이블
CREATE TABLE IF NOT EXISTS groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(200) NOT NULL,
    description TEXT,
    owner_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    is_public BOOLEAN DEFAULT false,
    max_members INTEGER DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. group_members 테이블
CREATE TABLE IF NOT EXISTS group_members (
    member_id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(group_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- 'owner', 'admin', 'member'
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

-- 6. posts 테이블
CREATE TABLE IF NOT EXISTS posts (
    post_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'general', -- 'tip', 'question', 'free'
    auto_tags TEXT[], -- 작성자의 악기, 성향 등 자동 태그
    manual_tags TEXT[], -- 사용자가 직접 추가한 태그
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. comments 테이블
CREATE TABLE IF NOT EXISTS comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    parent_comment_id INTEGER REFERENCES comments(comment_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. achievements 테이블
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    condition_type VARCHAR(50), -- 'practice_time', 'consecutive_days', 'instrument_count'
    condition_value INTEGER,
    icon_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. user_achievements 테이블
CREATE TABLE IF NOT EXISTS user_achievements (
    user_achievement_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(achievement_id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

-- 10. social_accounts 테이블
CREATE TABLE IF NOT EXISTS social_accounts (
    social_account_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL, -- 'google', 'kakao', 'naver'
    provider_user_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_user_id)
);

-- 11. recording_files 테이블
CREATE TABLE IF NOT EXISTS recording_files (
    recording_id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES practice_sessions(session_id) ON DELETE CASCADE,
    file_path VARCHAR(500),
    file_size BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- 12. post_likes 테이블 (게시글 좋아요)
CREATE TABLE IF NOT EXISTS post_likes (
    like_id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, user_id)
);

-- 13. comment_likes 테이블 (댓글 좋아요)
CREATE TABLE IF NOT EXISTS comment_likes (
    like_id SERIAL PRIMARY KEY,
    comment_id INTEGER REFERENCES comments(comment_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(comment_id, user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_user_id ON practice_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_practice_date ON practice_sessions(practice_date);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_instrument ON practice_sessions(instrument);
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_comment_id ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_social_accounts_user_id ON social_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_social_accounts_provider ON social_accounts(provider, provider_user_id);
CREATE INDEX IF NOT EXISTS idx_recording_files_session_id ON recording_files(session_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_likes_comment_id ON comment_likes(comment_id);

-- 텍스트 검색용 인덱스 (GIN 인덱스)
CREATE INDEX IF NOT EXISTS idx_posts_auto_tags_gin ON posts USING GIN(auto_tags);
CREATE INDEX IF NOT EXISTS idx_posts_manual_tags_gin ON posts USING GIN(manual_tags);
CREATE INDEX IF NOT EXISTS idx_user_profiles_instruments_gin ON user_profiles USING GIN(instruments);
CREATE INDEX IF NOT EXISTS idx_user_profiles_hashtags_gin ON user_profiles USING GIN(hashtags);

-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 좋아요 카운트 업데이트 함수 (게시글)
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- 좋아요 카운트 트리거 (게시글)
CREATE TRIGGER update_post_like_count_trigger
    AFTER INSERT OR DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- 좋아요 카운트 업데이트 함수 (댓글)
CREATE OR REPLACE FUNCTION update_comment_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE comments SET like_count = like_count + 1 WHERE comment_id = NEW.comment_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE comments SET like_count = like_count - 1 WHERE comment_id = OLD.comment_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- 좋아요 카운트 트리거 (댓글)
CREATE TRIGGER update_comment_like_count_trigger
    AFTER INSERT OR DELETE ON comment_likes
    FOR EACH ROW EXECUTE FUNCTION update_comment_like_count();

