//+------------------------------------------------------------------+
//|                                                 TestPullBack.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Dev\Brooks\Features.mqh>

input double maxStop = 1000;
input datetime start_time = D'2021.04.05';

CManageExtremes ExtremeManager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   TimeToStruct(start_time, day);
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
   new_candle = NewCandle();
   if(candleCount > 3 && !IsDayEnd())
     {
      ExtremeManager.Run();
      ExtremeManager.GetNode(ExtremeManager.graph_extremes_.GetLastIndex()).PrintNode(); //ExtremeManager.graph_extremes_.GetLastIndex()
     }
  }
//+------------------------------------------------------------------+
