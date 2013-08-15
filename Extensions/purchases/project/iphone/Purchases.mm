#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h> 
#include "Purchases.h"
#include "PurchaseEvent.h"

extern "C" void sendPurchaseEvent(const char* type, const char* data);

@interface InAppPurchase: NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
	SKProductsRequest* productsRequest;
	NSMutableDictionary* authorizedProducts;
	BOOL arePurchasesEnabled;
}

- (void)initInAppPurchase;
- (void)restorePurchases;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(NSString*)productId;
- (void)requestProductInfo:(NSMutableSet*)productIdentifiers;
- (const char*)getProductTitle:(NSString*)productId;
- (const char*)getProductDescription:(NSString*)productId;
- (const char*)getProductPrice:(NSString*)productId;

@end

@implementation InAppPurchase

#pragma mark - Public methods

- (void)initInAppPurchase
{
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	sendPurchaseEvent("started", "");
	productsRequest = nil;
	authorizedProducts = [[NSMutableDictionary alloc] init];
	arePurchasesEnabled = NO;
}

- (void)restorePurchases
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL)canMakePurchases
{
	return (arePurchasesEnabled && [SKPaymentQueue canMakePayments]);
}

- (void)purchaseProduct:(NSString*)productId
{
	if(!arePurchasesEnabled || ![SKPaymentQueue canMakePayments])
	{
		sendPurchaseEvent("failed", [productId UTF8String]);
		return;
	}

	SKProduct *skProduct = [authorizedProducts objectForKey:productId];
	if(skProduct)
	{
		SKPayment *payment = [SKPayment paymentWithProduct:skProduct];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		return;
	}

	sendPurchaseEvent("failed", [productId UTF8String]);
}

// Multiple requests can be made, they'll be added into authorized list if not already there.
- (void)requestProductInfo:(NSMutableSet*)productIdentifiers
{
	if(productsRequest != nil)
	{ // A previous request is still pending, probably because of lost connection to App Store
		[productsRequest release];
	}
	arePurchasesEnabled = NO;

	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (const char*)getProductTitle:(NSString*)productId
{
	SKProduct *skProduct = [authorizedProducts objectForKey:productId];
	if(skProduct)
	{
		if(skProduct.localizedTitle != nil) // nil will crash app
		{
			return [skProduct.localizedTitle cStringUsingEncoding:NSUTF8StringEncoding];
		}
	}

	return "None";
}

- (const char*)getProductDescription:(NSString*)productId
{
	SKProduct *skProduct = [authorizedProducts objectForKey:productId];
	if(skProduct)
	{
		if(skProduct.localizedDescription != nil) // nil will crash app
		{
			return [skProduct.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding];
		}
	}

	return "None";
}

- (const char*)getProductPrice:(NSString*)productId
{
	SKProduct *skProduct = [authorizedProducts objectForKey:productId];
	if(skProduct)
	{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:skProduct.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:skProduct.price];
		[numberFormatter release];

		// Replace Euro UTF-16 with pseudo Unicode if it's in there.
		NSString *euroSymbol = [NSString stringWithFormat:@"%C", 0x20AC]; // UTF-16
		NSString *euroPseudo = @"~x20AC"; // Stencyl's pseudo Unicode ~x
		formattedString = [formattedString stringByReplacingOccurrencesOfString:euroSymbol withString:euroPseudo];

		return [formattedString cStringUsingEncoding:NSUTF8StringEncoding];
	}

	return "None";
}

#pragma mark - SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	NSArray *skProducts = response.products;
	for (SKProduct *skProduct in skProducts)
	{ // Add requested products, replacing duplicates that are already in there.
		[authorizedProducts setObject:skProduct forKey:[skProduct productIdentifier]];
	}

	[productsRequest release];
	productsRequest = nil;
	arePurchasesEnabled = YES;
	sendPurchaseEvent("productsVerified", "");
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error
{
	[productsRequest release];
	productsRequest = nil;
	arePurchasesEnabled = NO;
}

#pragma mark - SKPaymentTransactionObserver and Purchase helper methods

- (void)finishTransaction:(SKPaymentTransaction*)transaction wasSuccessful:(BOOL)wasSuccessful
{
	if(wasSuccessful)
	{
		sendPurchaseEvent("success", [transaction.payment.productIdentifier UTF8String]);
	}

	else
	{
		sendPurchaseEvent("failed", [transaction.payment.productIdentifier UTF8String]);
	}

	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	[self finishTransaction:transaction wasSuccessful:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
	sendPurchaseEvent("restore", [transaction.originalTransaction.payment.productIdentifier UTF8String]);
	[self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
	if(transaction.error.code != SKErrorPaymentCancelled)
	{
		switch (transaction.error.code)
		{
			case SKErrorUnknown:
				NSLog(@"SKErrorUnknown Transaction error: %@", transaction.error.localizedDescription);
			break;
			case SKErrorClientInvalid:
				NSLog(@"SKErrorClientInvalid Transaction error: %@", transaction.error.localizedDescription);
			break;
			case SKErrorPaymentInvalid:
				NSLog(@"SKErrorPaymentInvalid Transaction error: %@", transaction.error.localizedDescription);
			break;
			case SKErrorPaymentNotAllowed:
				NSLog(@"SKErrorPaymentNotAllowed Transaction error: %@", transaction.error.localizedDescription);
			break;
			default:
				NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
			break;
		}

		[self finishTransaction:transaction wasSuccessful:NO];
	}

	else
	{
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

#pragma mark - More Public methods

- (void)dealloc
{
	if(productsRequest)
		[productsRequest release];

	if(authorizedProducts)
		[authorizedProducts release];

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

	void requestProductInfo(const char *inProductIDcommalist)
	{
		NSString *productIDs = [[NSString alloc] initWithUTF8String:inProductIDcommalist];
		NSMutableSet *productIdentifiers = [NSMutableSet setWithArray:[productIDs componentsSeparatedByString:@","]];
		[inAppPurchase requestProductInfo:productIdentifiers];
	}

	const char* getTitle(const char *inProductID)
	{
		NSString *productID = [[NSString alloc] initWithUTF8String:inProductID];
		return [inAppPurchase getProductTitle:productID];
	}
    
	const char* getPrice(const char *inProductID)
	{
		NSString *productID = [[NSString alloc] initWithUTF8String:inProductID];
		return [inAppPurchase getProductPrice:productID];
	}
    
	const char* getDescription(const char *inProductID)
	{
		NSString *productID = [[NSString alloc] initWithUTF8String:inProductID];
		return [inAppPurchase getProductDescription:productID];
	}
}
