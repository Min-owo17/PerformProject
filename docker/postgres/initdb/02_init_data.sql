-- PerformProject 초기 데이터 삽입
-- 생성일: 2024

-- 초기 도전과제(칭호) 데이터 삽입
INSERT INTO achievements (title, description, condition_type, condition_value, icon_url) VALUES
-- 연습 시간 관련
('첫 걸음', '첫 연습을 시작하세요', 'practice_time', 1, '/icons/first-step.svg'),
('연습 시작', '총 10분 연습하세요', 'practice_time', 10, '/icons/practice-start.svg'),
('열심히 연습', '총 1시간 연습하세요', 'practice_time', 60, '/icons/practice-hard.svg'),
('연습 마스터', '총 10시간 연습하세요', 'practice_time', 600, '/icons/practice-master.svg'),
('연습의 달인', '총 100시간 연습하세요', 'practice_time', 6000, '/icons/practice-expert.svg'),
('연습의 신', '총 1000시간 연습하세요', 'practice_time', 60000, '/icons/practice-god.svg'),

-- 연속 일수 관련
('하루 한 번', '연속 1일 연습하세요', 'consecutive_days', 1, '/icons/daily-1.svg'),
('일주일 도전', '연속 7일 연습하세요', 'consecutive_days', 7, '/icons/daily-7.svg'),
('한 달 도전', '연속 30일 연습하세요', 'consecutive_days', 30, '/icons/daily-30.svg'),
('백일 도전', '연속 100일 연습하세요', 'consecutive_days', 100, '/icons/daily-100.svg'),
('일년 도전', '연속 365일 연습하세요', 'consecutive_days', 365, '/icons/daily-365.svg'),

-- 악기 종류 관련
('다재다능', '2가지 이상의 악기를 연주하세요', 'instrument_count', 2, '/icons/multi-instrument.svg'),
('음악가', '3가지 이상의 악기를 연주하세요', 'instrument_count', 3, '/icons/musician.svg'),
('마에스트로', '5가지 이상의 악기를 연주하세요', 'instrument_count', 5, '/icons/maestro.svg'),

-- 연습 횟수 관련 (추가)
('연습 습관', '10번 연습하세요', 'practice_count', 10, '/icons/habit-10.svg'),
('꾸준한 연습', '50번 연습하세요', 'practice_count', 50, '/icons/habit-50.svg'),
('노력가', '100번 연습하세요', 'practice_count', 100, '/icons/habit-100.svg'),
('전문가', '500번 연습하세요', 'practice_count', 500, '/icons/habit-500.svg'),
('대가', '1000번 연습하세요', 'practice_count', 1000, '/icons/habit-1000.svg')

ON CONFLICT DO NOTHING;

