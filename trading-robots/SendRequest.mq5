// use the JAson library to build JSON strings
#include <JAson.mqh>

// First, set your unique TradersPost webhook URL:
input string Webhook_URL = "https://webhooks.traderspost.io/trading/webhook/...";

void SendRequest(string action, double quantity, string symbol)
{
    if (Webhook_URL == "") return;

    CJAVal json;
    json["time"] = TimeToString(TimeCurrent());
    json["ticker"] = symbol;
    json["action"] = action;

    // if the quantity is set and > 0, then set json property
    if (quantity > 0) json["quantity"] = quantity;


}

// Your EA rules and definitions here

int OnInit()
{
}

void OnTick()
{
}
