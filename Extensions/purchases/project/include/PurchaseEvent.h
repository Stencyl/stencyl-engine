#ifndef PurchaseEvents_H_
#define PurchaseEvents_H_

enum PurchaseEventType
{
   UNKNOWN,                   // 0
   IN_APP_PURCHASE_SUCCESS,   // 1
   IN_APP_PURCHASE_FAIL,      // 2
   IN_APP_PURCHASE_CANCEL,    // 3
};

struct PurchaseEvent
{	
   PurchaseEvent(PurchaseEventType inType = UNKNOWN, int inCode = 0, int inValue = 0, const char* inData = "")
   :type(inType), code(inCode), value(inValue), data(inData) {}

   PurchaseEventType type;
   int code;
   int value;
   const char* data;
};

#endif