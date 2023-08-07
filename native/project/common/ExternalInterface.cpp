#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "Native.h"
#include <stdio.h>

using namespace native;

AutoGCRoot* keyEventHandle = 0;

#ifdef IPHONE

static void keyboard_set_event_handle(value onEvent)
{
	keyEventHandle = new AutoGCRoot(onEvent);
}
DEFINE_PRIM(keyboard_set_event_handle, 1);

value native_device_os()
{
	return alloc_string(os());
}
DEFINE_PRIM(native_device_os,0);

value native_device_vervion()
{
	return alloc_string(vervion());
}
DEFINE_PRIM(native_device_vervion,0);

value native_device_name()
{
	return alloc_string(deviceName());
}
DEFINE_PRIM(native_device_name,0);

value native_device_model()
{
	return alloc_string(model());
}
DEFINE_PRIM(native_device_model,0);

value native_device_network_available()
{
	return alloc_bool(networkAvailable());
}
DEFINE_PRIM(native_device_network_available,0);

void native_device_vibrate(value time)
{
	vibrate(val_float(time));
}
DEFINE_PRIM(native_device_vibrate,1);

void native_device_badge(value n)
{
	setBadgeNumber(val_int(n));
}
DEFINE_PRIM(native_device_badge,1);

void native_device_show_keyboard()
{
	showKeyboard();
}
DEFINE_PRIM(native_device_show_keyboard,0);

void native_device_hide_keyboard()
{
	hideKeyboard();
}
DEFINE_PRIM(native_device_hide_keyboard,0);

void native_setKeyboardText(value text)
{
	setKeyboardText(val_string(text));
}
DEFINE_PRIM(native_setKeyboardText,1);

void native_system_ui_show_alert(value title,value message)
{
	showSystemAlert(val_string(title),val_string(message));
}
DEFINE_PRIM(native_system_ui_show_alert,2);

void native_system_ui_show_system_loading_view()
{
	showLoadingScreen();
}
DEFINE_PRIM(native_system_ui_show_system_loading_view,0);

void native_system_ui_hide_system_loading_view()
{
	hideLoadingScreen();
}
DEFINE_PRIM(native_system_ui_hide_system_loading_view,0);

value native_set_user_preference(value inId,value inValue)
{
   bool result=SetUserPreference(val_string(inId),val_string(inValue));
   return alloc_bool(result);
}
DEFINE_PRIM(native_set_user_preference,2);

value native_get_user_preference(value inId)
{
   std::string result=GetUserPreference(val_string(inId));
   return alloc_string(result.c_str());
}
DEFINE_PRIM(native_get_user_preference,1);

value native_clear_user_preference(value inId)
{
   bool result=ClearUserPreference(val_string(inId));
   return alloc_bool(result);
}
DEFINE_PRIM(native_clear_user_preference,1);

value native_get_program_arguments()
{
   std::vector<std::string> result=getProgramArguments();
   value returnArray = alloc_array(result.size());
   for(int i = 0; i < result.size(); ++i)
      val_array_set_i(returnArray, i, alloc_string(result[i].c_str()));
   return returnArray;
}
DEFINE_PRIM(native_get_program_arguments,0);

value native_get_safe_inset_left()
{
   int result=getSafeInsetLeft();
   return alloc_int(result);
}
DEFINE_PRIM(native_get_safe_inset_left,0);

value native_get_safe_inset_top()
{
   int result=getSafeInsetTop();
   return alloc_int(result);
}
DEFINE_PRIM(native_get_safe_inset_top,0);

value native_get_safe_inset_right()
{
   int result=getSafeInsetRight();
   return alloc_int(result);
}
DEFINE_PRIM(native_get_safe_inset_right,0);

value native_get_safe_inset_bottom()
{
   int result=getSafeInsetBottom();
   return alloc_int(result);
}
DEFINE_PRIM(native_get_safe_inset_bottom,0);

#endif

extern "C" void native_main() 
{	
	// Here you could do some initialization, if needed	
}
DEFINE_ENTRY_POINT(native_main);

extern "C" int native_register_prims() 
{ 
    return 0; 
}

extern "C" void sendKeyEvent(int key)
{
    value o = alloc_empty_object();
    alloc_field(o,val_id("data"),alloc_int(key));
    val_call1(keyEventHandle->get(), o);
}

extern "C" void sendTextFieldEvent(const char* data)
{
    value o = alloc_empty_object();
    alloc_field(o,val_id("data"),alloc_string(data));
    val_call1(keyEventHandle->get(), o);
}

extern "C" void sendTextFieldEvent2(const char* data)
{
    value o = alloc_empty_object();
    alloc_field(o,val_id("data"),alloc_string("@SUBMIT@"));
    alloc_field(o,val_id("data2"),alloc_string(data));
    val_call1(keyEventHandle->get(), o);
}

