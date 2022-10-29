/*

   SSL Channel.mq4
   Copyright 2013-2022, Novateq Pty Ltd
   https://www.novateq.com.au

*/

#property strict

#property copyright "Copyright 2013-2022, Novateq Pty Ltd"
#property link "https://www.novateq.com.au"
#property version "1.00"

#property indicator_chart_window

#property indicator_buffers 3

#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Leading"

#property indicator_color2 clrWhite
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Trailing"

// Indicator parameters
input int InpPeriod = 10; // Period

double    LeadingBuffer[];
double    TrailingBuffer[];
double    DirectionBuffer[];

;
int OnInit() {

   SetIndexBuffer( 0, LeadingBuffer, INDICATOR_DATA );
   SetIndexBuffer( 1, TrailingBuffer, INDICATOR_DATA );
   SetIndexBuffer( 2, DirectionBuffer );
   SetIndexLabel( 2, NULL );

   return ( INIT_SUCCEEDED );
}

int OnCalculate( const int       rates_total,     //
                 const int       prev_calculated, //
                 const datetime &time[],          //
                 const double   &open[],          //
                 const double   &high[],          //
                 const double   &low[],           //
                 const double   &close[],         //
                 const long     &tick_volume[],   //
                 const long     &volume[],        //
                 const int      &spread[] ) {

   //	Need a minimum number of available rates to function
   if ( rates_total < InpPeriod ) return ( 0 );

   // Skip values already calculated
   int limit = ( prev_calculated == 0 ) ? rates_total - InpPeriod - 1 : rates_total - prev_calculated + 1;

   //	Loop through bars
   for ( int i = limit; i >= 0; i-- ) {

      double hi          = iMA( Symbol(), Period(), InpPeriod, 0, MODE_SMA, PRICE_HIGH, i );
      double lo          = iMA( Symbol(), Period(), InpPeriod, 0, MODE_SMA, PRICE_LOW, i );

      DirectionBuffer[i] = close[i] > hi ? 1 : close[i] < lo ? -1 : DirectionBuffer[i + 1];
      LeadingBuffer[i]   = DirectionBuffer[i] < 0 ? lo : hi;
      TrailingBuffer[i]  = DirectionBuffer[i] < 0 ? hi : lo;
   }

   return ( rates_total );
}
