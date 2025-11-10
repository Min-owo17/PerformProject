import React, { useState, useMemo } from 'react';
import { PerformanceRecord } from '../types';
import { formatTime, getLocalDateString } from '../utils/time';
import { commonStyles } from '../styles/commonStyles';

interface MemberCalendarModalProps {
  memberData: {
    name: string;
    records: PerformanceRecord[];
    profilePicture: string | null;
  };
  onClose: () => void;
}

const MemberCalendarModal: React.FC<MemberCalendarModalProps> = ({ memberData, onClose }) => {
  const [currentDate, setCurrentDate] = useState(new Date());

  const recordsByDate = useMemo(() => {
    const map = new Map<string, PerformanceRecord[]>();
    memberData.records.forEach(record => {
      const localDate = new Date(record.date);
      const dateStr = getLocalDateString(localDate);
      if (!map.has(dateStr)) {
        map.set(dateStr, []);
      }
      map.get(dateStr)?.push(record);
    });
    return map;
  }, [memberData.records]);

  const daysInMonth = useMemo(() => {
    const date = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
    const days = [];
    while (date.getMonth() === currentDate.getMonth()) {
      days.push(new Date(date));
      date.setDate(date.getDate() + 1);
    }
    return days;
  }, [currentDate]);

  const startDayOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1).getDay();

  const changeMonth = (amount: number) => {
    setCurrentDate(prev => {
      const newDate = new Date(prev);
      newDate.setMonth(newDate.getMonth() + amount);
      return newDate;
    });
  };

  const isSameDay = (d1: Date, d2: Date) =>
    d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate();

  return (
    <div className={commonStyles.modalOverlay} aria-modal="true" role="dialog">
      <div className={`${commonStyles.modalContainerLarge} flex flex-col max-h-[90vh]`}>
        <div className={`p-4 border-b ${commonStyles.divider} flex-shrink-0 flex items-center justify-between`}>
          <div className="flex items-center gap-3">
            <img
              src={memberData.profilePicture || ''}
              alt={memberData.name}
              className="w-10 h-10 rounded-full bg-gray-700"
            />
            <h3 className="text-xl font-bold text-purple-600 dark:text-purple-300">{memberData.name}의 연습 기록</h3>
          </div>
          <button onClick={onClose} className={commonStyles.iconButton}>
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-4">
          <div className="flex justify-between items-center mb-4">
            <button onClick={() => changeMonth(-1)} className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
              &lt;
            </button>
            <h2 className="text-xl font-semibold">
              {currentDate.toLocaleString('ko-KR', { month: 'long', year: 'numeric' })}
            </h2>
            <button onClick={() => changeMonth(1)} className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
              &gt;
            </button>
          </div>

          <div className="grid grid-cols-7 gap-1 text-center text-xs text-gray-500 dark:text-gray-400 mb-2">
            {['일', '월', '화', '수', '목', '금', '토'].map(day => (
              <div key={day}>{day}</div>
            ))}
          </div>

          <div className="grid grid-cols-7 gap-1">
            {Array.from({ length: startDayOfMonth }).map((_, i) => (
              <div key={`empty-${i}`}></div>
            ))}
            {daysInMonth.map(day => {
              const dateStr = getLocalDateString(day);
              const dayRecords = recordsByDate.get(dateStr) || [];
              const hasRecord = dayRecords.length > 0;
              const isToday = isSameDay(day, new Date());

              return (
                <div
                  key={day.toISOString()}
                  className={`relative p-2 h-10 w-10 md:h-14 md:w-14 flex items-center justify-center rounded-full ${
                    isToday ? 'bg-gray-200 dark:bg-gray-700' : 'hover:bg-gray-100 dark:hover:bg-gray-800'
                  }`}
                >
                  <span>{day.getDate()}</span>
                  {hasRecord && (
                    <div className="absolute bottom-1 h-1.5 w-1.5 rounded-full bg-purple-400"></div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="mt-6 space-y-3">
            <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-300">이번 달 연습 기록</h3>
            {Array.from(recordsByDate.entries())
              .filter(([dateStr]) => {
                const date = new Date(dateStr);
                return date.getMonth() === currentDate.getMonth() && date.getFullYear() === currentDate.getFullYear();
              })
              .map(([dateStr, records]) => (
                <div key={dateStr} className={commonStyles.card}>
                  <p className="text-sm font-semibold text-gray-600 dark:text-gray-400 mb-2">{dateStr}</p>
                  {records.map(record => (
                    <div key={record.id} className="mb-2 last:mb-0">
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-semibold text-purple-600 dark:text-purple-300">{record.title}</p>
                          <p className="text-sm text-gray-500 dark:text-gray-400">{record.instrument}</p>
                        </div>
                        <span className="text-sm font-mono bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">
                          {formatTime(record.duration)}
                        </span>
                      </div>
                      {record.summary && (
                        <p className="text-sm text-gray-600 dark:text-gray-300 mt-1 italic">"{record.summary}"</p>
                      )}
                    </div>
                  ))}
                </div>
              ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MemberCalendarModal;

