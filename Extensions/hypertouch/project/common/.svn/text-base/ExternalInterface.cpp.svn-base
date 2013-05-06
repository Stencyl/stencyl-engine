
#ifndef IPHONE
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>
#include <hx/Macros.h>
#include <stdio.h>
#include <hxcpp.h>
#include "HyperTouch.h"

#ifdef ANDROID
#include <jni.h>
#endif

using namespace Hyperfiction;

#ifdef ANDROID
	extern JNIEnv *GetEnv();
	enum JNIType{
	   jniUnknown,
	   jniVoid,
	   jniObjectString,
	   jniObjectArray,
	   jniObject,
	   jniBoolean,
	   jniByte,
	   jniChar,
	   jniShort,
	   jniInt,
	   jniLong,
	   jniFloat,
	   jniDouble,
	};
#endif

AutoGCRoot *eval_callback_pan = 0;
AutoGCRoot *eval_callback_pinch = 0;
AutoGCRoot *eval_callback_rotation = 0;
AutoGCRoot *eval_callback_swipe = 0;
AutoGCRoot *eval_callback_tap = 0;
AutoGCRoot *eval_callback_tap2 = 0;
AutoGCRoot *eval_callback_twix = 0;

extern "C"{
	
	int hypertouch_register_prims(){
		printf("HyperTouch: register_prims()\n");
		//nme_extensions_main( );
		return 0;
	}
	#ifdef IPHONE
	void callbackTap( float fx , float fy ){
		//printf("HyperTouch: callbackTap( ) %f %f \n",fx,fy);
		val_call2( eval_callback_tap -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
   	}

   	void callbackTap2( float fx, float fy ){
   		//printf("HyperTouch: callbackTap2( ) %f %f \n",fx,fy);
		val_call2( eval_callback_tap2 -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
   	}

   	void callbackTwix( float fx , float fy ){
   		//printf("HyperTouch: callbackTwix( ) %f %f \n",fx,fy);
		val_call2( eval_callback_twix -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
   	}

	void callbackSwipe( int direction ){
		val_call1( eval_callback_swipe -> get( ) , alloc_int( direction ) ); 
	}

	void callbackRotation( float rotation , float velocity ){
		val_call2( eval_callback_rotation -> get( ) , alloc_float( rotation )  , alloc_float( velocity ) ); 
	}

	void callbackPinch( float scale , float velocity ){
		val_call2( eval_callback_pinch -> get( ) , alloc_float( scale )  , alloc_float( velocity ) ); 
	}

	void callbackPan( int phase , float tx , float ty , float vx , float vy , float cx , float cy ){
		value args = alloc_array( 7 );
		val_array_set_i( args , 0 , alloc_int( phase ) );
		val_array_set_i( args , 1 , alloc_float( tx ) );
		val_array_set_i( args , 2 , alloc_float( ty ) );
		val_array_set_i( args , 3 , alloc_float( vx ) );
		val_array_set_i( args , 4 , alloc_float( vy ) );
		val_array_set_i( args , 5 , alloc_float( cx ) );
		val_array_set_i( args , 6 , alloc_float( cy ) );
   		val_call1( eval_callback_pan -> get( ) , args ); 
   	}

   	#endif
   	
  	#ifdef ANDROID

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onTap(JNIEnv * env, jobject  obj , jfloat fx , jfloat fy ){
        val_call2( eval_callback_tap -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
    }

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onTwix(JNIEnv * env, jobject  obj , jfloat fx , jfloat fy ){
        val_call2( eval_callback_twix -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
    }

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onDoubleTap(JNIEnv * env, jobject  obj , jfloat fx , jfloat fy ){
		val_call2( eval_callback_tap2 -> get( ) , alloc_float( fx ) , alloc_float( fy ) );
    }

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onSwipe( JNIEnv * env, jobject  obj , jint dir ){
		val_call1( eval_callback_swipe -> get( ) , alloc_int( dir ) ); 
    }

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onPinch( JNIEnv * env, jobject  obj , jfloat scale  ){
		val_call1( eval_callback_pinch -> get( ) , alloc_float( scale ) ); 
    }

    JNIEXPORT void JNICALL Java_fr_hyperfiction_HyperTouch_onPan( JNIEnv * env, jobject  obj , jint phase , jfloat fx , jfloat fy , jfloat vx , jfloat vy , jfloat cx , jfloat cy , jfloat pressure ){
    	value args = alloc_array( 8 );
		val_array_set_i( args , 0 , alloc_int( phase ) );
		val_array_set_i( args , 1 , alloc_float( fx ) );
		val_array_set_i( args , 2 , alloc_float( fy ) );
		val_array_set_i( args , 3 , alloc_float( vx ) );
		val_array_set_i( args , 4 , alloc_float( vy ) );
		val_array_set_i( args , 5 , alloc_float( cx ) );
		val_array_set_i( args , 6 , alloc_float( cy ) );
		val_array_set_i( args , 7 , alloc_float( pressure ) );
   		val_call1( eval_callback_pan -> get( ) , args ); 
    }
    #endif

}

	#ifdef IPHONE

		static value hyp_touch_init( ){
			init_hyp_touch( );
			return alloc_null( );
		}
		DEFINE_PRIM( hyp_touch_init , 0 );
	#endif

// Callbacks ------------------------------------------------------------------------------------------------------------------

	//
		static value hyp_touch_callback_pan( value onCall ){
			eval_callback_pan = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_pan , 1 );

		static value hyp_touch_callback_pinch( value onCall ){
			eval_callback_pinch = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_pinch , 1 );

		static value hyp_touch_callback_rotation( value onCall ){
			eval_callback_rotation = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_rotation , 1 );

		static value hyp_touch_callback_swipe( value onCall ){
			eval_callback_swipe = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_swipe , 1 );

		static value hyp_touch_callback_tap( value onCall ){
			printf("Set Tap callback");
			eval_callback_tap = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_tap , 1 );

		static value hyp_touch_callback_tap2( value onCall ){
			printf("Set Tap2 callback");
			eval_callback_tap2 = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_tap2 , 1 );

		static value hyp_touch_callback_twix( value onCall ){
			printf("Set Twix callback");
			eval_callback_twix = new AutoGCRoot( onCall );
		    return alloc_bool( true );
		}
		DEFINE_PRIM( hyp_touch_callback_twix , 1 );

// Activate / Deactivate -------------------------------------------------------------------------------------------------------------
	
	#ifdef IPHONE

		static value hyp_touch_activate( value gestureCode ){
			activateGesture( val_int( gestureCode ) );
			return alloc_null( );
		}
		DEFINE_PRIM( hyp_touch_activate , 1 );

		static value hyp_touch_deactivate( value gestureCode ){
			deactivateGesture( val_int( gestureCode ) );
			return alloc_null( );
		}
		DEFINE_PRIM( hyp_touch_deactivate , 1 );

	#endif

// Misc -------------------------------------------------------------------------------------------------------------

	#ifdef IPHONE

		static value hyp_touch_get_orientation( ){
			return alloc_int( getOrientation( ) );
 		}
		DEFINE_PRIM( hyp_touch_get_orientation , 0 );

	#endif