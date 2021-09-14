//+------------------------------------------------------------------+
//|                                           TestDayRetracement.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Dev\Brooks\Features\Index.mqh>
#include <Dev\Brooks\Features\Structs\Index.mqh>
#include <Trade\Trade.mqh>

input datetime start_time = D'1970.01.05';
input double max_stop = 400;
input string signal_direction = "original";
input int candle_count_ = 8;
double lot = 5;

CTrade Trade;
CDayRetracement DayRet;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   TimeToStruct(start_time, day);
   simbol_tick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTradeRequest trade_request = DayRet.CalcEntry();
   MqlTradeResult trade_result;
   trade_request.symbol = Symbol();
   trade_request.volume = lot;
   trade_request.type_filling = ORDER_FILLING_FOK;

//Print("trade_request: ", trade_request.type);

   new_candle = NewCandle();
   ClosePositionAtDayEnd();
   if(IsNewDay())
      candleCount = 0;
   double stop = AllowStop(trade_request.sl);
   if(stop >= max_stop)
      return;

   if(!PositionsTotal() && !IsDayEnd())
     {
      if(trade_request.type == ORDER_TYPE_BUY)
        {
         Trade.Buy(trade_request.volume, _Symbol, trade_request.price, trade_request.sl, trade_request.tp, "stop: "+DoubleToString(stop));
        }
      if(trade_request.type == ORDER_TYPE_SELL)
        {
         Trade.Sell(trade_request.volume, _Symbol, trade_request.price, trade_request.sl, trade_request.tp, "stop: "+DoubleToString(stop));
        }
      //Print("trade_result: ", trade_result.retcode);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AllowStop(double sl)
  {
   double last = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   return MathAbs(sl - last);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionAtDayEnd()
  {
   if(PositionsTotal() > 0 && IsDayEnd())
     {
      Trade.PositionClose(_Symbol);
     }
  }
//+------------------------------------------------------------------+
