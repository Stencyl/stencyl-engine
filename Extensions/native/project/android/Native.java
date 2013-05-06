import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.util.HashMap;

import org.haxe.nme.*;

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

public class Native
{
	public static GameActivity activity;
	
	public static void vibrate(final int duration)
	{
		if(activity == null)
		{
			activity = GameActivity.getInstance();
		}
		
		Vibrator v = (Vibrator) activity.getSystemService(Context.VIBRATOR_SERVICE);
		v.vibrate(duration);
	}
	
	public static void showAlert(final String title, final String message)
	{
		if(activity == null)
		{
			activity = GameActivity.getInstance();
		}
		
		activity.runOnUiThread
		(
			new Runnable() 
			{
				public void run() 
				{
					Dialog dialog = new AlertDialog.Builder(activity).setTitle(title).setMessage(message).setPositiveButton
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
				}
			}
		);
    }
    
    private static boolean gotHandle = false;
    
    public static void showKeyboard() 
    {
    	if(activity == null)
		{
			activity = GameActivity.getInstance();
		}
		
		if(!gotHandle)
		{
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
			
			gotHandle = true;
		}
		
        activity.showKeyboard(true);
    }
    
    public static void hideKeyboard() 
    {
    	if(activity == null)
		{
			activity = GameActivity.getInstance();
		}
		
        activity.showKeyboard(false);
    }
}