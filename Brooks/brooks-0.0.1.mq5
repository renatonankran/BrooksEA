//+------------------------------------------------------------------+
//|                                                 brooks-0.0.1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>


//--- input parameters
input int      Input1;
input datetime startTime = D'2021.01.01';
input datetime endTime = D'2021.02.01';

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate

//+------------------------------------------------------------------+
//| Class CBackTest                                                  |
//+------------------------------------------------------------------+
class CBacktest
  {
private:
   int               currentCandleIndex;
   MqlRates          rates[];

public:
                     CBacktest(datetime startTime,datetime endTime);
   void              NextCandle();
   void              CreateArrowCurrentCandle(datetime time, double price);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBacktest::CBacktest(datetime startTime,datetime endTime)
  {
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,_Period,startTime,endTime,rates);
   currentCandleIndex = copied-1;
   if(copied < 0)
      Print("Rates copie error");
      
   NextCandle();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBacktest::NextCandle()
  {
   CreateArrowCurrentCandle(rates[currentCandleIndex].time, rates[currentCandleIndex].low);
   currentCandleIndex--;
  }

void CBacktest::CreateArrowCurrentCandle(datetime time,double price)
  {
   if(!ObjectCreate(0,"CurrentCandle",OBJ_ARROW_BUY,0,time,price-price*0.001))
     {
      Print(__FUNCTION__,
            ": failed to create \"Buy\" sign! Error code = ",GetLastError());
     }
  }
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CButton           m_button1;

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateButton1(void);
   //--- handlers of the dependent controls events
   void              OnClickButton1(void);
  };

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,m_button1,OnClickButton1)
EVENT_MAP_END(CAppDialog)

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButton1())
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButton1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(EDIT_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button1.Create(m_chart_id,m_name+"NextCandle",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button1.Text("Next candle"))
      return(false);
   if(!Add(m_button1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton1(void)
  {
   Backtest.NextCandle();
  }

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double lotSize = 5;
long lastCandleTimeStamp = 0;
long magicNumber = 0;
double tickSize = 0;
int candleCount = 0;

CTrade Trade;
CControlsDialog ExtDialog;
CBacktest Backtest(startTime,endTime);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
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
   bool newCandle = NewCandle();
   int openPosition = PositionsTotal();

   if(newCandle && !openPosition)
     {
      int gap = Gap();

      if(gap == POSITION_TYPE_SELL)
        {

         double sl=GetStops(POSITION_TYPE_SELL);
         double tp=GetTake(POSITION_TYPE_SELL);

         Trade.Sell(lotSize, _Symbol,0,sl,tp);
        }
      if(gap == POSITION_TYPE_BUY)
        {

         double sl=GetStops(POSITION_TYPE_BUY);
         double tp=GetTake(POSITION_TYPE_BUY);

         Trade.Buy(lotSize, _Symbol,0,sl,tp);
        }
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Gap()
  {
   if(candleCount>3)
     {
      if(iHigh(_Symbol,_Period,1) < iLow(_Symbol,_Period,3))
        {
         return POSITION_TYPE_SELL;
        }

      if(iLow(_Symbol,_Period,1) > iHigh(_Symbol,_Period,3))
        {
         return POSITION_TYPE_BUY;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+

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
