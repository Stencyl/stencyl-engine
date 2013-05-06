#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "Ads.h"
#include <stdio.h>

#ifdef ANDROID
#include <jni.h>
#endif

using namespace ads;

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

AutoGCRoot* adEventHandle = 0;

#ifdef IPHONE

static void ads_set_event_handle(value onEvent)
{
	adEventHandle = new AutoGCRoot(onEvent);
}
DEFINE_PRIM(ads_set_event_handle, 1);

void ads_showad(value position)
{
	showAd(val_int(position));
}
DEFINE_PRIM(ads_showad, 1);

void ads_hidead()
{
	hideAd();
}
DEFINE_PRIM(ads_hidead, 0);

#endif

extern "C" void ads_main() 
{	
	// Here you could do some initialization, if needed	
}
DEFINE_ENTRY_POINT(ads_main);

extern "C" int ads_register_prims() 
{ 
    return 0; 
}

extern "C" void sendEvent(char* type)
{
    printf("Send Event: %s\n", type);
    value o = alloc_empty_object();
    alloc_field(o,val_id("type"),alloc_string(type));
    val_call1(adEventHandle->get(), o);
}