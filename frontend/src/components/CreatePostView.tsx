import React, { useState, useMemo, useRef, useEffect } from 'react';
import { BoardPost } from '../types';
import { useAppContext } from '../context/AppContext';
import { allFeatures, instruments } from '../utils/constants';
import { commonStyles } from '../styles/commonStyles';

interface CreatePostViewProps {
  postToEdit?: BoardPost;
  onSave: (postData: { title: string; content: string; tags: string[] }) => void;
  onCancel: () => void;
}

const CreatePostView: React.FC<CreatePostViewProps> = ({ postToEdit, onSave, onCancel }) => {
  const { userProfile } = useAppContext();
  const [title, setTitle] = useState(postToEdit?.title || '');
  const [content, setContent] = useState(postToEdit?.content || '');
  const [tags, setTags] = useState<string[]>(postToEdit?.tags || []);
  const [tagSearch, setTagSearch] = useState('');
  const [isTagDropdownOpen, setIsTagDropdownOpen] = useState(false);
  const tagDropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (tagDropdownRef.current && !tagDropdownRef.current.contains(event.target as Node)) {
        setIsTagDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // 자동 태그 생성 (사용자의 악기, 성향 등)
  const autoTags = useMemo(() => {
    const autoTagsList: string[] = [];
    if (userProfile.instrument) {
      autoTagsList.push(userProfile.instrument);
    }
    if (userProfile.features && userProfile.features.length > 0) {
      autoTagsList.push(...userProfile.features);
    }
    return autoTagsList;
  }, [userProfile]);

  // 전체 사용 가능한 태그
  const allAvailableTags = useMemo(() => {
    const tagsFromConstants = [...allFeatures, ...instruments];
    return [...new Set(tagsFromConstants)].sort();
  }, []);

  // 필터링된 태그
  const filteredTags = useMemo(() => {
    return allAvailableTags.filter(tag =>
      !tags.includes(tag) &&
      tag.toLowerCase().includes(tagSearch.toLowerCase())
    );
  }, [tagSearch, tags, allAvailableTags]);

  const handleAddTag = (tag: string) => {
    if (!tags.includes(tag)) {
      setTags(prev => [...prev, tag]);
    }
    setTagSearch('');
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(prev => prev.filter(t => t !== tagToRemove));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !content.trim()) {
      return;
    }
    // 자동 태그와 수동 태그 결합
    const allTags = [...new Set([...autoTags, ...tags])];
    onSave({ title: title.trim(), content: content.trim(), tags: allTags });
  };

  return (
    <div className={commonStyles.pageContainerFullHeight}>
      <div className="flex items-center mb-4">
        <button onClick={onCancel} className={commonStyles.iconButton} aria-label="취소">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 className={commonStyles.mainTitle}>{postToEdit ? '게시물 수정' : '새 게시물 작성'}</h1>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col h-full">
        <div className="flex-1 space-y-4 overflow-y-auto">
          <div>
            <label className={commonStyles.label}>제목</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="게시물 제목을 입력하세요"
              className={commonStyles.textInputP3}
              required
            />
          </div>

          <div>
            <label className={commonStyles.label}>내용</label>
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="게시물 내용을 입력하세요"
              rows={10}
              className={`${commonStyles.textInputP3} resize-none`}
              required
            />
          </div>

          <div className="relative" ref={tagDropdownRef}>
            <label className={commonStyles.label}>태그</label>
            {autoTags.length > 0 && (
              <div className="mb-2">
                <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">자동 태그:</p>
                <div className="flex flex-wrap gap-2">
                  {autoTags.map(tag => (
                    <span key={tag} className="bg-blue-100 text-blue-700 dark:bg-blue-600/50 dark:text-blue-200 text-xs font-medium px-2 py-1 rounded-full">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            )}
            <div className="w-full bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md p-2 focus-within:ring-2 focus-within:ring-purple-500 transition-colors flex flex-wrap gap-2 items-center">
              {tags.map(tag => (
                <span key={tag} className="bg-purple-600/50 text-purple-200 text-sm font-medium px-2 py-1 rounded-full flex items-center gap-1">
                  {tag}
                  <button
                    type="button"
                    onClick={() => handleRemoveTag(tag)}
                    className="text-purple-200 hover:text-white"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </span>
              ))}
              <input
                type="text"
                value={tagSearch}
                onChange={(e) => setTagSearch(e.target.value)}
                onFocus={() => setIsTagDropdownOpen(true)}
                placeholder={tags.length === 0 ? "태그 검색 및 추가..." : ""}
                autoComplete="off"
                className="bg-transparent flex-1 focus:outline-none p-1 min-w-[120px]"
              />
            </div>
            {isTagDropdownOpen && (
              <ul className="absolute z-30 w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md mt-1 max-h-48 overflow-y-auto shadow-lg animate-fade-in">
                {filteredTags.length > 0 ? (
                  filteredTags.map(tag => (
                    <li
                      key={tag}
                      onClick={() => handleAddTag(tag)}
                      className="px-4 py-2 text-sm text-gray-800 dark:text-gray-200 cursor-pointer hover:bg-purple-500 hover:text-white"
                    >
                      {tag}
                    </li>
                  ))
                ) : (
                  <li className="px-4 py-2 text-sm text-gray-500 dark:text-gray-400">결과 없음</li>
                )}
              </ul>
            )}
          </div>
        </div>

        <div className={`mt-4 pt-4 ${commonStyles.divider}`}>
          <div className="flex gap-4">
            <button
              type="button"
              onClick={onCancel}
              className={`${commonStyles.buttonBase} ${commonStyles.secondaryButton} py-3`}
            >
              취소
            </button>
            <button
              type="submit"
              disabled={!title.trim() || !content.trim()}
              className={`${commonStyles.buttonBase} ${commonStyles.primaryButton} py-3 disabled:bg-purple-300 dark:disabled:bg-purple-800 disabled:cursor-not-allowed`}
            >
              {postToEdit ? '수정' : '작성'}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default CreatePostView;

