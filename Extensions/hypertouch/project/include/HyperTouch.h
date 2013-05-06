#ifndef Device
#define Device

namespace Hyperfiction{

	bool activateGesture( int gestureCode );
	bool deactivateGesture( int gestureCode );
	
	void init_hyp_touch( );
	
	void callbackTap( int touches , int fingers , float fx , float fy );	
	void callbackSwipe( int direction );
	void callbackRotation( float rotation , float velocity );
	void callbackPan( float fx , float fy , float vx , float vy );		
	void callback( const char * type , float* charArray );	
	void callbackPinch( float scale , float velocity );
	
	int getOrientation( );
	
}

#endif