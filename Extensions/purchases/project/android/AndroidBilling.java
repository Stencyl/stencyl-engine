import com.blundell.test.*;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import org.haxe.nme.GameActivity;
import org.haxe.nme.HaxeObject;

public class AndroidBilling
{
	private static String publicKey = "";
	private static HaxeObject callback = null;

	private static void runInHaxe(Runnable r)
	{
		GameActivity.getInstance().runOnUiThread(r);
	}

	public static void initialize(String publicKey, final HaxeObject callback)
	{
		Log.i("IAP", "Attempt to init billing service");
	
		AndroidBilling.callback = callback;
		setPublicKey(publicKey);
		
		GameActivity.getInstance().runOnUiThread(new Runnable() 
		{
			public void run() 
			{
				GameActivity.getInstance().startService(new Intent(GameActivity.getInstance(), BillingService.class));
		
				Handler transactionHandler = new Handler()
				{
					public void handleMessage(android.os.Message msg) 
					{
						if(BillingHelper.latestPurchase != null)
						{
							Log.i("IAP", "Transaction Complete");
							Log.i("IAP", "Transaction Status: " + BillingHelper.latestPurchase.purchaseState);
							Log.i("IAP", "Attempted to Purchase: " + BillingHelper.latestPurchase.productId);
				
							if(BillingHelper.latestPurchase.isPurchased())
							{
								//SUCCESS
								Log.i("IAP", "Transaction Success");
								
								GameActivity.getInstance().runOnUiThread
								(
									new Runnable()
									{ 
										public void run() 
										{
											callback.call("onPurchase", new Object[] {BillingHelper.latestPurchase.productId});
										}
									}
								);
							} 
							
							else 
							{
								//FAILURE
								Log.i("IAP", "Transaction Failed");
								
								GameActivity.getInstance().runOnUiThread
								(
									new Runnable()
									{ 
										public void run() 
										{
											callback.call("onFailedPurchase", new Object[] {BillingHelper.latestPurchase.productId});
											callback.call("onCanceledPurchase", new Object[] {BillingHelper.latestPurchase.productId});
										}
									}
								);
							}
						}
						
						else
						{
							//FAILED
							Log.i("IAP", "Transaction Failed");
							
							GameActivity.getInstance().runOnUiThread
							(
								new Runnable()
								{ 
									public void run() 
									{
										callback.call("onFailedPurchase", new Object[] {BillingSecurity.latestProductID});
										callback.call("onCanceledPurchase", new Object[] {BillingSecurity.latestProductID});
									}
								}
							);
						}
					};     
				};
				
				BillingHelper.setCompletedHandler(transactionHandler);
				
				GameActivity.getInstance().runOnUiThread
				(
					new Runnable()
					{ 
						public void run() 
						{
							callback.call("onStarted", new Object[] {});
						}
					}
				);
			}
		});
	}
	
	public static void buy(String productID)
	{
		Log.i("IAP", "Attempt to Buy: " + productID);
		
		if(BillingHelper.isBillingSupported())
		{
        	BillingHelper.requestPurchase(GameActivity.getInstance(), productID);
        }
        
        else 
        {
	       	Log.i("IAP", "Can't purchase on this device");
	    }
	}
	
	public static void restore()
	{
		Log.i("IAP", "Attempt to Restore Purchases");
	
		if(BillingHelper.isBillingSupported())
		{
        	BillingHelper.restoreTransactionInformation(BillingSecurity.generateNonce());
        }
        
        else 
        {
	       	Log.i("IAP", "Can't restore transactions since this device doesn't support in-app purchases.");
	    }
	}
	
	public static void setPublicKey(String s)
	{
		publicKey = s;
	}
	
	public static String getPublicKey()
	{
		return publicKey;
	}
}