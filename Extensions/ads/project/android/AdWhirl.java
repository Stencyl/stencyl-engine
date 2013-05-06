import org.haxe.nme.GameActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.net.Uri;
import android.os.Bundle;
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

import com.adwhirl.AdWhirlManager;
import com.adwhirl.AdWhirlLayout;
import com.adwhirl.AdWhirlTargeting;

import dalvik.system.DexClassLoader;

public class AdWhirl
{
	public static RelativeLayout adLayout;
	public static GameActivity activity;
	public static String code;

	public static void init(String code)
	{
		AdWhirl.code = code;
		activity = GameActivity.getInstance();
 
        activity.runOnUiThread(new Runnable() 
		{
			public void run() 
			{
				adLayout = new RelativeLayout(activity);
				
				//Nothing works till this is set.
				AdWhirlManager.setConfigExpireTimeout(1000 * 60 * 5);
			
				RelativeLayout.LayoutParams p = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT); 
				ViewGroup view = (ViewGroup) activity.getWindow().getDecorView();
				ViewGroup content = (ViewGroup) view.getChildAt(0);
				content.addView(adLayout, p);
			}
		});
	}
	
	public static void showAd(final int position)
	{
		if(activity == null)
		{
			return;
		}
	
		activity.runOnUiThread(new Runnable() 
		{
			public void run() 
			{
				AdWhirlLayout l = new AdWhirlLayout(activity, code);
				l.setMaxHeight(75); //AdMob asks for this minimum height
				
				RelativeLayout.LayoutParams p = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT); 
				
				//Bottom-Center
				if(position == 0)
				{
					p.addRule(RelativeLayout.CENTER_HORIZONTAL);
					p.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
				}
				
				//Top-Center
				else
				{
					p.addRule(RelativeLayout.CENTER_HORIZONTAL);
					p.addRule(RelativeLayout.ALIGN_PARENT_TOP);
				}
				
				adLayout.addView(l, p);
			}
		});
	}
	
	public static void hideAd()
	{
		if(activity == null)
		{
			return;
		}
		
		activity.runOnUiThread(new Runnable() 
		{
			public void run() 
			{
				adLayout.removeAllViews();
			}
		});
	}
}