#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h> 
#include "Purchases.h"
#include "PurchaseEvent.h"

extern "C" void sendPurchaseEvent(const char* type, const char* data);

@interface InAppPurchase: NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct* myProduct;
    SKProductsRequest* productsRequest;
	NSString* productID;
}

- (void)initInAppPurchase;
- (void)restorePurchases;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(NSString*)productIdentifiers;

@end

@implementation InAppPurchase

#pragma Public methods 

- (void)initInAppPurchase 
{
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	sendPurchaseEvent("started", "");
}

- (void)restorePurchases 
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
} 

- (void)purchaseProduct:(NSString*)productIdentifiers
{
	if(productsRequest != NULL)
	{
		NSLog(@"Can't start another purchase until previous one is complete.");
		return;
	}
	
	productID = productIdentifiers;
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
	productsRequest.delegate = self;
	[productsRequest start];
} 

#pragma mark -
#pragma mark SKProductsRequestDelegate methods 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse*)response
{   	
	int count = [response.products count];
    
	NSLog(@"Number of Products: %i", count);
    
	if(count > 0) 
    {
		myProduct = [response.products objectAtIndex:0];
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:productID];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	} 
    
    else 
    {
		NSLog(@"No products are available");
	}
    
    [productsRequest release];
    productsRequest = NULL;
}

- (void)finishTransaction:(SKPaymentTransaction*)transaction wasSuccessful:(BOOL)wasSuccessful
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if(wasSuccessful)
    {
    	NSLog(@"Successful Purchase");
		sendPurchaseEvent("success", [transaction.payment.productIdentifier UTF8String]);
    }
    
    else
    {
    	NSLog(@"Failed Purchase");
        sendPurchaseEvent("failed", [transaction.payment.productIdentifier UTF8String]);
    }
}

- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	NSLog(@"Finish Transaction");
    [self finishTransaction:transaction wasSuccessful:YES];
} 

- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
	NSLog(@"Restoring Transaction");
	sendPurchaseEvent("restore", [transaction.payment.productIdentifier UTF8String]);
    [self finishTransaction:transaction wasSuccessful:YES];
} 

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
    if(transaction.error.code != SKErrorPaymentCancelled)
    {
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    
    else
    {
    	NSLog(@"Canceled Purchase");
    	sendPurchaseEvent("cancel", [transaction.payment.productIdentifier UTF8String]);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray*)transactions
{
	for(SKPaymentTransaction *transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

- (void)dealloc
{
	if(myProduct) 
        [myProduct release];
    
	if(productsRequest) 
        [productsRequest release];
    
	if(productID) 
        [productID release];
    
	[super dealloc];
}

@end

extern "C"
{
	static InAppPurchase* inAppPurchase = nil;
    
	void initInAppPurchase()
    {
		inAppPurchase = [[InAppPurchase alloc] init];
		[inAppPurchase initInAppPurchase];
	}
	
	void restorePurchases() 
	{
		[inAppPurchase restorePurchases];
	}
    
	bool canPurchase()
    {
		return [inAppPurchase canMakePurchases];
	}
    
	void purchaseProduct(const char *inProductID)
    {
		NSString *productID = [[NSString alloc] initWithUTF8String:inProductID];
		[inAppPurchase purchaseProduct:productID];
	}
    
	void releaseInAppPurchase()
    {
		[inAppPurchase release];
	}
	
	char* getTitle(const char *inProductID)
	{
		return "TODO";
	}
    
    char* getPrice(const char *inProductID)
    {
    	return "TODO";
    }
    
    char* getDescription(const char *inProductID)
    {
    	return "TODO";
    }
}



