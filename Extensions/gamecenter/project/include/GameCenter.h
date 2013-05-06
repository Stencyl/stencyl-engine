#ifndef GameCenter
#define GameCenter

namespace gamecenter 
{	
    //User
	void initializeGameCenter();
    bool isGameCenterAvailable();
	bool isUserAuthenticated();
    void authenticateLocalUser();
    
    const char* getPlayerName();
    const char* getPlayerID();
    
    //Leaderboards
    void showLeaderboard(const char* categoryID);
    void reportScore(const char* categoryID, int score);
    
    //Achievements
    void showAchievements();
    void resetAchievements();
    void reportAchievement(const char* achievementID, float percent);
    
    //Other
    void registerForAuthenticationNotification();
}

#endif
