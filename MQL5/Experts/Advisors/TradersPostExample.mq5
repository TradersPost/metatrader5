//+------------------------------------------------------------------+
//|                                           TradersPostExample.mq5 |
//|                                                 TradersPost, Inc |
//|                                           https://traderspost.io |
//+------------------------------------------------------------------+
#property copyright "TradersPost, Inc"
#property link      "https://traderspost.io"
#property version   "1.00"
#property strict

#include <TradersPostWebhookRequest.mqh>

input string Webhook_URL = "https://webhooks.traderspost.io/trading/webhook/...";

TradersPostWebhookRequest webhookRequest(Webhook_URL);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   Print("TradersPost Example EA initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    static bool orderSent = false;

    if (!orderSent) {
        // include the built-in JSON serializer
        TPJSON json;

        // Build your properties according to the webhook documentation: https://docs.traderspost.io/docs/core-concepts/webhooks#request-body
        json["ticker"] = "MSFT";
        json["action"] = "buy";
        json["quantity"] = 1;

        // Add take profit and stop loss
        json["takeProfit"]["percent"] = 5.0;
        json["stopLoss"]["percent"] = 2.5;

        // Convert JSON object to string
        string jsonPayload = json.Serialize();  

        // Send the serialized JSON request
        bool result = webhookRequest.SendRequest(jsonPayload);

        if (result) {
            Print("Buy order sent for MSFT.");
            orderSent = true;  // Only send once
        } else {
            Print("Failed to send the buy order.");
            orderSent = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}