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
        
        char* getTitle(const char *inProductID);
        char* getPrice(const char *inProductID);
        char* getDescription(const char *inProductID);
    }
}

#endif
