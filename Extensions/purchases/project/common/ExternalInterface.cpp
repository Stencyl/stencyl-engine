#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "Purchases.h"
#include "PurchaseEvent.h"
#include <stdio.h>

using namespace purchases;

AutoGCRoot* purchaseEventHandle = 0;

#ifdef IPHONE

static void purchases_set_event_handle(value onEvent)
{
	purchaseEventHandle = new AutoGCRoot(onEvent);
}
DEFINE_PRIM(purchases_set_event_handle, 1);

static void purchases_initialize() 
{
	initInAppPurchase();
}
DEFINE_PRIM (purchases_initialize, 0);

static void purchases_restore() 
{
	restorePurchases();
}
DEFINE_PRIM (purchases_restore, 0);

static void purchases_buy(value productID)
{
	purchaseProduct(val_string(productID));
}
DEFINE_PRIM(purchases_buy, 1);

static value purchases_title(value productID)
{
	return alloc_string(getTitle(val_string(productID)));
}
DEFINE_PRIM(purchases_title, 1);

static value purchases_desc(value productID)
{
	return alloc_string(getDescription(val_string(productID)));
}
DEFINE_PRIM(purchases_desc, 1);

static value purchases_price(value productID)
{
	return alloc_string(getPrice(val_string(productID)));
}
DEFINE_PRIM(purchases_price, 1);

static value purchases_canbuy() 
{
	return alloc_bool(canPurchase());
}
DEFINE_PRIM (purchases_canbuy, 0);

static void purchases_release() 
{
	releaseInAppPurchase();
}
DEFINE_PRIM (purchases_release, 0);

#endif

extern "C" void purchases_main() 
{	
	// Here you could do some initialization, if needed	
}
DEFINE_ENTRY_POINT(purchases_main);

extern "C" int purchases_register_prims() 
{ 
    return 0; 
}

extern "C" void sendPurchaseEvent(const char* type, const char* data)
{
    value o = alloc_empty_object();
    alloc_field(o,val_id("type"),alloc_string(type));
    alloc_field(o,val_id("data"),alloc_string(data));
    val_call1(purchaseEventHandle->get(), o);
}