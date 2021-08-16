//+------------------------------------------------------------------+
//|                                                 brooks-0.0.1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "0.0.2"

#include <Trade\Trade.mqh>
#include <Dev\Brooks\Backtest.mqh>
#include <Dev\Brooks\DirectionAnalyser.mqh>
#include <Dev\Brooks\AlwaysInEnum.mqh>
#include <Dev\Brooks\CheckDirection.mqh>

//--- input parameters
input datetime start_time = D'2021.01.04 09:00:00';
input datetime end_time = D'2021.01.04 17:50:00';

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

ALWAYS_IN Direction = ALWAYS_IN_RANGE;

CControlsDialog ExtDialog(start_time, end_time);
CCheckDirection CheckDirection(start_time, end_time);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//--- create application dialog
   if(!ExtDialog.Create(0,"Controls",0,40,40,380,344))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- clear comments
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }