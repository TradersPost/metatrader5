# Sending Meta Trader 5 (MT5) trades to TradersPost

Meta Trader 5 (MT5) is a powerful electronic trading platform widely used by forex and stock traders. It provides a comprehensive suite of tools for market analysis, automated trading, and risk management. MT5 allows users to trade a variety of financial instruments, including stocks, futures, and currencies, across multiple markets. With its advanced charting capabilities, customizable indicators, and support for algorithmic trading through Expert Advisors (EAs), MT5 offers both novice and experienced traders a robust environment to execute their trading strategies efficiently and effectively.

Expert Advisors (EAs) in MT5 can leverage the TradersPostWebhookRequest library to seamlessly transmit trading signals to TradersPost. This integration allows traders to automate the process of sending trade information directly from their MT5 platform to TradersPost's system. By utilizing the webhook functionality as outlined in the TradersPost documentation (https://docs.traderspost.io/docs/core-concepts/webhooks#request-body), EAs can construct and send structured JSON payloads containing crucial trade details such as action, ticker, quantity, and takeProfit and stopLoss details among others. This powerful feature enables traders to maintain a real-time connection between their MT5 trading activities and TradersPost's order execution tools, facilitating more efficient trading, and strategy optimization.

## Enabling TraderPost and WebRequests in MT5

To enable algorithmic trading and WebRequests in MT5, follow these steps:

1. Enable Algorithmic Trading:
   a. Open MetaTrader 5
   b. Go to "Tools" in the top menu
   c. Select "Options"
   d. Navigate to the "Expert Advisors" tab
   e. Check the box next to "Allow automated trading"
   f. Click "OK" to save the changes

2. Enable WebRequests:
   a. In MetaTrader 5, go to "Tools" > "Options" again
   b. Navigate to the "Expert Advisors" tab
   c. Check the box next to "Allow WebRequest for listed URL"
   d. In the field below, add: https://webhooks.traderspost.io
   e. Click "OK" to save the changes

3. Restart MetaTrader 5 to ensure all changes take effect

These steps are crucial for allowing your Expert Advisors to perform automated trading and send WebRequests to TradersPost. Make sure to add the exact URL (https://webhooks.traderspost.io) to the allowed list to ensure your EA can communicate with TradersPost's webhook service.

Note: Always exercise caution when enabling automated trading and allowing external connections in your trading platform. Only use trusted Expert Advisors and connect to verified, secure endpoints.

## Setting up TradersPostWebhookRequest in MT5

Before you can use the TradersPostWebhookRequest library in your Expert Advisors, you need to add the `TradersPostWebhookRequest.mqh` file to your MT5 data folder. Here's how to do it:

1. Download `TradersPostWebhookRequest.mqh` in [MQL5/Include/TradersPostWebhookRequest.mqh](MQL5/Include/TradersPostWebhookRequest.mqh).

2. Open your MT5 data folder. You can do this in two ways:
   - Click on "File" in the MT5 menu, then select "Open Data Folder"
   - Use the keyboard shortcut: CTRL + SHIFT + D

3. In the opened folder, navigate to the following path:
   MQL5/Include

4. Copy the `TradersPostWebhookRequest.mqh` file into this Include folder.

Once you've completed these steps, you'll be able to use the TradersPostWebhookRequest library in your Expert Advisors by including it at the beginning of your EA code:

```
#include <TradersPostWebhookRequest.mqh>

input string Webhook_URL = "https://webhooks.traderspost.io/trading/webhook/...";

TradersPostWebhookRequest webhookRequest(Webhook_URL);

[...]

void OnTick() {
    // include the built-in JSON serializer
    TPJSON json;
    [...]
}
```

## Example EA

An example Expert Advisor (EA) has been created to demonstrate how to build and send a webhook request using the TradersPostWebhookRequest library. You can find this example EA in the file [MQL5/Experts/Advisors/TradersPostExample.mq5](MQL5/Experts/Advisors/TradersPostExample.mq5).

It's important to note that this EA is not a functioning trading strategy. Instead, it serves as an illustrative example of how to construct and send a webhook request within the OnTick() method. The EA sends a single buy order for NQ Nasdaq 100 Futures (NQZ2024) with a specified quantity, take profit, and stop loss.

When developing your own EA, we strongly encourage you to refer to the webhook documentation available at https://docs.traderspost.io/docs/core-concepts/webhooks#request-body. This documentation provides detailed information on how to construct the message payload according to your specific trading needs. You can customize the properties in the JSON object to match your desired trading actions, whether it's buying, selling, or managing existing positions.

Remember to replace the placeholder webhook URL in the example with your actual TradersPost webhook URL when implementing this in your own EA.

## Symbol Usage

It's important to note that using dynamic symbols in your Expert Advisor is not supported when using TradersPost webhooks. Instead, users should navigate to the Tickers page of their broker connection on TradersPost to determine the exact symbol they want to trade. Once you've identified the correct symbol, you should hard-code this symbol in the "ticker" property of the JSON message in your EA. This ensures that your trades are executed on the intended instrument and helps prevent any potential mismatches between your EA's symbol and the broker's available symbols. By using a fixed, pre-determined symbol, you can maintain consistency in your trading operations and avoid potential errors that might arise from dynamic symbol selection.
