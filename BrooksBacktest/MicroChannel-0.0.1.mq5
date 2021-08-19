//+------------------------------------------------------------------+
//|                                           MicroChannel-0.0.1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.01"
#include <Dev\Brooks\Features.mqh>
#include <Trade\Trade.mqh>

input double maxStop = 1000;
input datetime start_time = D'2021.04.05';

double lot_size = 1;
datetime lastCandleTimeStamp;
MqlDateTime day;
int candleCount = 0;
MicroChannelStruc micro_channel;
double tick_size;
CTrade Trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  TimeToStruct(start_time, day);
  //---
  return (INIT_SUCCEEDED);
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
  int openPosition = PositionsTotal();
  ClosePositionAtDayEnd();
  if (NewCandle() && candleCount > 3 && !openPosition && !IsDayEnd())
  {
    IsNewDay();

    micro_channel = MicroChannel(3, micro_channel);

    if (micro_channel.ChannelOrientation == BULL_MC)
    {

      double sl = GetStops(POSITION_TYPE_BUY, micro_channel.size);
      double tp = GetTake(POSITION_TYPE_BUY, micro_channel.size);
      if (getStopSize(iOpen(_Symbol, _Period, 0), sl) >= maxStop)
        return;
      ClosePositions();
      Trade.Sell(lot_size, _Symbol, 0, tp, sl);
    }
    if (micro_channel.ChannelOrientation == BEAR_MC)
    {
      double sl = GetStops(POSITION_TYPE_SELL, micro_channel.size);
      double tp = GetTake(POSITION_TYPE_SELL, micro_channel.size);

      if (getStopSize(iOpen(_Symbol, _Period, 0), sl) >= maxStop)
        return;
      ClosePositions();
      Trade.Buy(lot_size, _Symbol, 0, tp, sl);
    }
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewCandle()
{
  datetime currentTimeStamp = iTime(_Symbol, _Period, 0);
  if (currentTimeStamp != lastCandleTimeStamp)
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
double IsNewDay()
{
  MqlDateTime current;
  TimeToStruct(TimeCurrent(), current);
  if (day.day != current.day)
  {
    day.day = current.day;
    candleCount = 0;
    return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDayEnd()
{
  MqlDateTime candle_timestamp, m_end_time_stru;
  datetime m_end_time;

  TimeToStruct(iTime(_Symbol, _Period, 0), candle_timestamp);
  m_end_time_stru.day = candle_timestamp.day;
  m_end_time_stru.mon = candle_timestamp.mon;
  m_end_time_stru.year = candle_timestamp.year;
  m_end_time_stru.hour = 17;
  m_end_time_stru.min = 50;
  m_end_time_stru.sec = 0;
  m_end_time = StructToTime(m_end_time_stru);

  if (iTime(_Symbol, _Period, 0) >= m_end_time)
    return true;

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionAtDayEnd()
{
  if (PositionsTotal() > 0 && IsDayEnd())
  {
    Trade.PositionClose(_Symbol);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
{
  if (PositionsTotal() > 0)
  {
    Trade.PositionClose(_Symbol);
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStops(ENUM_POSITION_TYPE positionType, int index)
{
  if (positionType == POSITION_TYPE_BUY)
  {
    return iLow(_Symbol, _Period, index) - tick_size;
  }
  if (positionType == POSITION_TYPE_SELL)
  {
    return iHigh(_Symbol, _Period, index) + tick_size;
  }

  return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getStopSize(double open, double sl)
{
  return MathAbs(open - sl);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTake(ENUM_POSITION_TYPE positionType, int index)
{
  if (positionType == POSITION_TYPE_BUY)
  {
    double stopSize = GetStops(POSITION_TYPE_BUY, index);
    double takeProfit = iOpen(_Symbol, _Period, 0) - stopSize;
    return iOpen(_Symbol, _Period, 0) + takeProfit;
  }
  if (positionType == POSITION_TYPE_SELL)
  {
    double stopSize = GetStops(POSITION_TYPE_SELL, index);
    double takeProfit = stopSize - iOpen(_Symbol, _Period, 0);
    return iOpen(_Symbol, _Period, 0) - takeProfit;
  }
  return 0;
}
//+------------------------------------------------------------------+
