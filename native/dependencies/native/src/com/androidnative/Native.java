package com.androidnative;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.util.HashMap;

import org.haxe.lime.*;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import org.libsdl.app.SDLActivity;

import android.util.Log;
import android.app.*;
import android.content.*;
import android.content.res.AssetManager;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.net.Uri;
import android.os.*;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.text.*;

import androidx.annotation.RequiresApi;

public class Native extends Extension
{
    
    private static HaxeObject callback;
    private static View view;
    private static String text = "";
    private static InputMethodManager imm;
    
    private static final String GLOBAL_PREF_FILE = "nmeAppPrefs";
    
	public static void vibrate(final int duration)
	{
        mainActivity.runOnUiThread(new Runnable()
                                   {
            public void run()
            {
                Vibrator v = (Vibrator) mainContext.getSystemService(mainContext.VIBRATOR_SERVICE);
                v.vibrate(duration);
            }
        });
	}
	
	public static void showAlert(final String title, final String message)
	{
		
		mainActivity.runOnUiThread
		(
			new Runnable() 
			{
				public void run() 
				{
					Dialog dialog = new AlertDialog.Builder(mainActivity).setTitle(title).setMessage(message).setPositiveButton
					(
						"OK",
						new DialogInterface.OnClickListener()
						{
							public void onClick(DialogInterface dialog, int whichButton)
							{
								//Throw event?	
							}
						}
					).create();
			
					dialog.show();
					
					if (callback != null)
					{
						callback.call("onPause", new Object[] {}); // reset keyboard because alert replaces key listener
					}
				}
			}
		);
    }

    static public void initialize(final HaxeObject cb){
        
        callback = cb;
        
        view = mainActivity.getCurrentFocus();
        
        view.setOnKeyListener(new OnKeyListener() {
            @Override
            public boolean onKey(View view, int keyCode, KeyEvent event)
            {
                if(event.getAction()==KeyEvent.ACTION_DOWN)
                {
					if (keyCode == KeyEvent.KEYCODE_BACK)
					{
						SDLActivity.onNativeKeyDown(keyCode);
					}
                    return true;
                }
				
				if (keyCode == KeyEvent.KEYCODE_BACK)
				{
					SDLActivity.onNativeKeyUp(keyCode);
					return true;
				}
                
                if(keyCode==KeyEvent.KEYCODE_ALT_LEFT || keyCode==KeyEvent.KEYCODE_ALT_RIGHT || keyCode==KeyEvent.KEYCODE_SHIFT_LEFT || keyCode==KeyEvent.KEYCODE_SHIFT_RIGHT)
                {
                   return true;
                }
                
                if (keyCode == KeyEvent.KEYCODE_DEL)
                {
                    int len = text.length();
                    
                    if (len > 0)
                    {
                        text = text.substring(0, len - 1);
                    }
                    
                    callback.call("onKeyPressed", new Object[] {text});
                    
                    
                    return true;
                } else if (keyCode == KeyEvent.KEYCODE_ENTER) {
                    hideKeyboard();
                    
                    callback.call("onEnterPressed", new Object[] {});
                    
                    return true;
                }
                
                
                if (event.getAction()==KeyEvent.ACTION_UP)
                {
                    text += String.valueOf((char)event.getUnicodeChar());
                    
                    //Toast.makeText(mainActivity,text + "Action UP",Toast.LENGTH_LONG).show();
                    
                    callback.call("onKeyPressed", new Object[] {text});
                    
                    return true;
                }
                else if (event.getAction()==KeyEvent.ACTION_MULTIPLE)
                {
                    
                    text += String.valueOf(event.getCharacters());
                    
                    //Toast.makeText(mainActivity,text + "Action Multi",Toast.LENGTH_LONG).show();
                    
                    callback.call("onKeyPressed", new Object[] {text});
                    
                    return true;
                }
            return false;
                
            }

    });
        
        mainActivity.runOnUiThread(new Runnable()
                                   {
            public void run()
            {

                imm = (InputMethodManager) mainContext.getSystemService(mainContext.INPUT_METHOD_SERVICE);
                
            }
        });
      
        
		/*EditText textField = (EditText) activity.findViewById(R.id.editTextConvertValue);
	
		textField.addTextChangedListener
		(
			new TextWatcher()
			{
				public void afterTextChanged(Editable s) 
				{
					System.out.println("TESTING: " + s);
				}
			}
		);*/
		
	}

    public static void showKeyboard() 
    {
		mainActivity.runOnUiThread(new Runnable()
        {
			public void run()
			{
				imm.showSoftInput(view, InputMethodManager.SHOW_FORCED);
			}
        });
		
        //activity.showKeyboard(true);
    }
    
    public static void hideKeyboard() 
    {
    	
    	mainActivity.runOnUiThread(new Runnable()
        {
    		public void run()
    		{
    			imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    		}
        });
    	
        //activity.showKeyboard(false);
    }
    
    public static String getUserPreference (String inId)
    {
        
        SharedPreferences prefs = mainActivity.getSharedPreferences (GLOBAL_PREF_FILE, Context.MODE_PRIVATE);
        return prefs.getString (inId, "");
        
    }
    
    public static void setUserPreference (String inId, String inPreference)
    {
        
        SharedPreferences prefs = mainActivity.getSharedPreferences (GLOBAL_PREF_FILE, Context.MODE_PRIVATE);
        SharedPreferences.Editor prefEditor = prefs.edit ();
        prefEditor.putString (inId, inPreference);
        prefEditor.commit ();
        
    }
    
    public static void clearUserPreference (String inId)
    {
        
        SharedPreferences prefs = mainActivity.getSharedPreferences (GLOBAL_PREF_FILE, Context.MODE_PRIVATE);
        SharedPreferences.Editor prefEditor = prefs.edit ();
        prefEditor.putString (inId, "");
        prefEditor.commit ();
        
    }
    
    static public void setText(final String newText)
    {
        text = newText;
    }
	
	@Override
	public void onPause()
	{
		super.onPause();

		mainActivity.runOnUiThread
		(
			new Runnable()
			{
				public void run()
				{
					if (callback != null)
					{
						callback.call("onPause", new Object[] {});
					}
				}
			}
		);
	}
}