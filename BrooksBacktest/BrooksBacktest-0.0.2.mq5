//+------------------------------------------------------------------+
//|                                                 brooks-0.0.1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property tester_file "win2021.04.01-2021.04.30.csv"

#include <Trade\Trade.mqh>
#include <Dev\Brooks\Enums.mqh>
#include <Dev\Brooks\CheckDirection.mqh>

//--- input parameters
input datetime start_time = D'2021.04.01 09:00:00';
input datetime end_time = D'2021.04.30 17:50:00';
input int maxStop = 500;

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

ALWAYS_IN Direction = ALWAYS_IN_RANGE;
double lotSize = 1;
long lastCandleTimeStamp = 0;
long magicNumber = 0;
double tickSize = 0;
int candleCount = 0;

CTrade Trade;
CCheckDirection CheckDirection(start_time,end_time);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CheckDirection.LoadFile("win");
   tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
//--- create application dialog

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
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool newCandle = NewCandle();
   int openPosition = PositionsTotal();
     ClosePositionAtDayEnd();
   if(newCandle && !openPosition && !IsDayEnd())
     {
     

      int gap = Gap();

      if(gap == POSITION_TYPE_SELL)
        {

         double sl=GetStops(POSITION_TYPE_SELL);
         double tp=GetTake(POSITION_TYPE_SELL);
         if(getStopSize(iOpen(_Symbol,_Period,0),sl) >= maxStop)
            return;

         Trade.Sell(lotSize, _Symbol,0,sl,tp);
        }
      if(gap == POSITION_TYPE_BUY)
        {

         double sl=GetStops(POSITION_TYPE_BUY);
         double tp=GetTake(POSITION_TYPE_BUY);
         if(getStopSize(iOpen(_Symbol,_Period,0),sl) >= maxStop)
            return;

         Trade.Buy(lotSize, _Symbol,0,sl,tp);
        }
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionAtDayEnd()
  {
   if(PositionsTotal()>0 && IsDayEnd())
     {
      Trade.PositionClose(_Symbol);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDayEnd()
  {
   MqlDateTime candle_timestamp,m_end_time_stru;
   datetime m_end_time;
   
   TimeToStruct(iTime(_Symbol,_Period,0),candle_timestamp);
   m_end_time_stru.day=candle_timestamp.day;
   m_end_time_stru.mon=candle_timestamp.mon;
   m_end_time_stru.year=candle_timestamp.year;
   m_end_time_stru.hour=17;
   m_end_time_stru.min=50;
   m_end_time_stru.sec=0;
   m_end_time = StructToTime(m_end_time_stru);
   
   if(iTime(_Symbol,_Period,0)>=m_end_time)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Gap()
  {
   if(candleCount>3)
     {
      ALWAYS_IN direction = CheckDirection.Direction(iTime(_Symbol,_Period,0));
      if(direction == ALWAYS_IN_SHORT && IsBearBar(2) && IsBearBar(3))
        {
         if(iHigh(_Symbol,_Period,1) < iLow(_Symbol,_Period,3))
           {
            return POSITION_TYPE_SELL;
           }
        }

      if(direction == ALWAYS_IN_LONG && IsBullBar(2) && IsBullBar(3))
        {
         if(iLow(_Symbol,_Period,1) > iHigh(_Symbol,_Period,3))
           {
            return POSITION_TYPE_BUY;
           }
        }
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullBar(int index)
  {
   if(iOpen(_Symbol,_Period,index) < iClose(_Symbol,_Period,index))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearBar(int index)
  {
   if(iOpen(_Symbol,_Period,index) > iClose(_Symbol,_Period,index))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewCandle()
  {
   long currentTimeStamp = iTime(_Symbol,_Period,0);
   if(currentTimeStamp != lastCandleTimeStamp)
     {
      lastCandleTimeStamp = currentTimeStamp;
      candleCount++;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStops(ENUM_POSITION_TYPE positionType)
  {
   if(positionType == POSITION_TYPE_BUY)
     {
      return iLow(_Symbol,_Period,2) - tickSize;
     }
   if(positionType == POSITION_TYPE_SELL)
     {
      return iHigh(_Symbol,_Period,2) + tickSize;
     }

   return 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getStopSize(double open, double sl)
  {
   return MathAbs(open-sl);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTake(ENUM_POSITION_TYPE positionType)
  {
   if(positionType == POSITION_TYPE_BUY)
     {
      double stopSize = GetStops(POSITION_TYPE_BUY);
      double takeProfit = iOpen(_Symbol,_Period,0) - stopSize;
      return iOpen(_Symbol,_Period,0) + takeProfit;
     }
   if(positionType == POSITION_TYPE_SELL)
     {
      double stopSize = GetStops(POSITION_TYPE_SELL);
      double takeProfit = stopSize - iOpen(_Symbol,_Period,0);
      return iOpen(_Symbol,_Period,0) - takeProfit;
     }
   return 0;
  }
//+------------------------------------------------------------------+
