import React, { useState } from 'react';
import { AppProvider } from './context/AppContext';
import { View } from './types';
import AuthView from './components/AuthView';
import RecordView from './components/RecordView';
import CalendarView from './components/CalendarView';
import GroupsView from './components/GroupsView';
import BoardView from './components/BoardView';
import ProfileView from './components/ProfileView';
import SettingsView from './components/SettingsView';
import Navigation from './components/Navigation';

function App() {
  const [currentView, setCurrentView] = useState<View>(View.RECORD);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setCurrentView(View.RECORD);
  };

  if (!isAuthenticated) {
    return (
      <AppProvider>
        <AuthView />
      </AppProvider>
    );
  }

  const renderView = () => {
    switch (currentView) {
      case View.RECORD:
        return <RecordView />;
      case View.CALENDAR:
        return <CalendarView />;
      case View.GROUPS:
        return <GroupsView />;
      case View.BOARD:
        return <BoardView />;
      case View.PROFILE:
        return <ProfileView />;
      case View.SETTINGS:
        return <SettingsView />;
      default:
        return <RecordView />;
    }
  };

  return (
    <AppProvider>
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        <div className="flex flex-col h-screen">
          <main className="flex-1 overflow-y-auto pb-20">
            {renderView()}
          </main>
          <Navigation currentView={currentView} setCurrentView={setCurrentView} />
        </div>
      </div>
    </AppProvider>
  );
}

export default App;

