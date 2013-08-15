#ifndef Purchases
#define Purchases

namespace purchases 
{	
    extern "C"
    {	
        void initInAppPurchase();
        void restorePurchases();
        bool canPurchase();
        void purchaseProduct(const char* productID);
        void releaseInAppPurchase();
        
        void requestProductInfo(const char *inProductIDcommalist);

        const char* getTitle(const char *inProductID);
        const char* getPrice(const char *inProductID);
        const char* getDescription(const char *inProductID);
    }
}

#endif
