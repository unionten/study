`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/01/20 10:33:45
// Design Name: 
// Module Name: idelay
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////
/*
idelay  
   #(.C_DEVICE      ( "K7" ),
     .C_DLY_SRC     ( "IDATAIN"),
     .C_DLY_FORMAT  ( "COUNT"),
     .C_DLY_TYPE    ( "VAR_LOAD"),
     .C_DLY_VALUE   ( 0),
     .C_REFCLK_FREQ ( 200.0)
    )
    idelay_u(
    .DATA_I     (),
    .IDATA_I    (),
    .CLK_I      (),  //The CLK of the IDELAYE3 must be  the same CLK as the ISERDESE3 CLKDIV.
    .RST_I      (),
    .CE_I       (),
    .INC_I      (),
    .LD_I       (),
    .CNTVALUE_I (),
    .DATA_O     (),
    .CNTVALUE_O ()

    );
*/






module idelay(
input  DATA_I     ,
input  IDATA_I    ,
input  CLK_I      , //独立时钟, 仅对用户逻辑使用，和底层无关
input  RST_I      ,
input  CE_I       ,
input  INC_I      ,
input  LD_I       ,
input  [8:0] CNTVALUE_I ,
output  DATA_O     ,
output [8:0] CNTVALUE_O 

    );

parameter C_DEVICE      =  "K7" ;
parameter C_DLY_SRC     =  "IDATAIN";
parameter C_DLY_FORMAT  =  "COUNT";
parameter C_DLY_TYPE    =  "VAR_LOAD";
parameter C_DLY_VALUE   =  0;
parameter C_REFCLK_FREQ =  200.0;


generate  
        if(C_DEVICE=="K7" | C_DEVICE=="A7")begin  
         wire [4:0] CNTVALUE_tmp;
         assign CNTVALUE_O = {0,CNTVALUE_tmp};
         wire DATA_O_1;
         IDELAYE2 #(   
            .CINVCTRL_SEL("FALSE"),          /* Enable dynamic clock inversion (FALSE, TRUE)*/   
            .DELAY_SRC(C_DLY_SRC),           /* Delay input (IDATAIN, DATAIN)*/   
            .HIGH_PERFORMANCE_MODE("FALSE"), /* Reduced jitter ("TRUE"), Reduced power ("FALSE")*/   
            .IDELAY_TYPE(C_DLY_TYPE),           /* FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE*/   
            .IDELAY_VALUE(C_DLY_VALUE),                /* Input delay tap setting (0-31)*/   
            .PIPE_SEL("FALSE"),              /* Select pipelined mode, FALSE, TRUE*/   
            .REFCLK_FREQUENCY(C_REFCLK_FREQ),        /* IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).*/   
            .SIGNAL_PATTERN("DATA")          /* DATA, CLOCK input signal*/   
         )   
         IDELAYE2_inst_stage1 (   
            .CNTVALUEOUT(CNTVALUE_tmp), /* 5-bit output: Counter value output*/   
            //.DATAOUT(DATA_O_1),         /* 1-bit output: Delayed data output*/   
            .DATAOUT(DATA_O),
            .C(CLK_I),                     /* 1-bit input: Clock input*/   
            .CE(CE_I),                   /* 1-bit input: Active high enable increment/decrement input*/   
            .CINVCTRL(0),       /* 1-bit input: Dynamic clock inversion input*/   
            .CNTVALUEIN(CNTVALUE_I),   /* 5-bit input: Counter value input*/   
            .DATAIN(DATA_I),           /* 1-bit input: Internal delay data input*/   
            .IDATAIN(IDATA_I),         /* 1-bit input: Data input from the I/O*/   
            .INC(INC_I),                 /* 1-bit input: Increment / Decrement tap delay input*/   
            .LD(LD_I),                   /* 1-bit input: Load IDELAY_VALUE input*/   
            .LDPIPEEN(0),       /* 1-bit input: Enable PIPELINE register to load data input*/   
            .REGRST(RST_I)            /* 1-bit input: Active-high reset tap-delay input*/   
         );   
         
         
        // IDELAYE2 #(   
        //    .CINVCTRL_SEL("FALSE"),          /* Enable dynamic clock inversion (FALSE, TRUE)*/   
        //    .DELAY_SRC("DATAIN"),           /* Delay input (IDATAIN, DATAIN)*/   
        //    .HIGH_PERFORMANCE_MODE("FALSE"), /* Reduced jitter ("TRUE"), Reduced power ("FALSE")*/   
        //    .IDELAY_TYPE(C_DLY_TYPE),           /* FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE*/   
        //    .IDELAY_VALUE(C_DLY_VALUE),                /* Input delay tap setting (0-31)*/   
        //    .PIPE_SEL("FALSE"),              /* Select pipelined mode, FALSE, TRUE*/   
        //    .REFCLK_FREQUENCY(C_REFCLK_FREQ),        /* IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).*/   
        //    .SIGNAL_PATTERN("DATA")          /* DATA, CLOCK input signal*/   
        // )   
        // IDELAYE2_inst_stage2(   
        //    .CNTVALUEOUT(    ), /* 5-bit output: Counter value output*/   
        //    .DATAOUT(DATA_O),         /* 1-bit output: Delayed data output*/   
        //    .C(CLK_I),                     /* 1-bit input: Clock input*/   
        //    .CE(CE_I),                   /* 1-bit input: Active high enable increment/decrement input*/   
        //    .CINVCTRL(0),       /* 1-bit input: Dynamic clock inversion input*/   
        //    .CNTVALUEIN(CNTVALUE_I),   /* 5-bit input: Counter value input*/   
        //    .DATAIN(DATA_O_1),           /* 1-bit input: Internal delay data input*/   
        //    .IDATAIN( ),         /* 1-bit input: Data input from the I/O*/   
        //    .INC(0),                 /* 1-bit input: Increment / Decrement tap delay input*/   
        //    .LD(0),                   /* 1-bit input: Load IDELAY_VALUE input*/   
        //    .LDPIPEEN(0),       /* 1-bit input: Enable PIPELINE register to load data input*/   
        //    .REGRST(RST_I)            /* 1-bit input: Active-high reset tap-delay input*/   
        // );   
         
        
         
   end   
   
   else if(C_DEVICE=="KU" | C_DEVICE=="KUP")begin /*KU*/ 
        wire [8:0] CNTVALUE_tmp;
        assign CNTVALUE_O = {0,CNTVALUE_tmp};
        IDELAYE3 #(    // 总结：两种模式，time模式，即自校准模式； count模式，即tap模式
           .CASCADE("NONE"),          /* Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)*/   
           .DELAY_FORMAT(C_DLY_FORMAT),     /* Units of the DELAY_VALUE (COUNT, TIME)*/   
           .DELAY_SRC(C_DLY_SRC),     /* Delay input (DATAIN, IDATAIN)*/   
           .DELAY_TYPE(C_DLY_TYPE),      /* Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)*/   
           .DELAY_VALUE(C_DLY_VALUE),           /* Input delay value setting*/   
           .IS_CLK_INVERTED(1'b0),    /* Optional inversion for CLK*/   
           .IS_RST_INVERTED(1'b0),    /* Optional inversion for RST*/   
           .REFCLK_FREQUENCY(C_REFCLK_FREQ),  /* IDELAYCTRL clock input frequency in MHz (200.0-800.0)*/   
           .SIM_DEVICE(C_DEVICE=="KU" ? "ULTRASCALE" : "ULTRASCALE_PLUS"), /* Set the device version for simulation functionality (ULTRASCALE)*/   
           .UPDATE_MODE("ASYNC")      /* Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)*/   
        )   
        IDELAYE3_inst (   
           .CASC_OUT( ),       /* 1-bit output: Cascade delay output to ODELAY input cascade*/   
           .CNTVALUEOUT(CNTVALUE_tmp), /* 9-bit output: Counter value output*/   
           .DATAOUT(DATA_O),         /* 1-bit output: Delayed data output*/   
           .CASC_IN( 0 ),         /* 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT*/   
           .CASC_RETURN( 0 ), /* 1-bit input: Cascade delay returning from slave ODELAY DATAOUT*/   
           .CE(CE_I),                   /* 1-bit input: Active-High enable increment/decrement input*/   
           .CLK(CLK_I),                 /* 1-bit input: Clock input*/   
           .CNTVALUEIN(CNTVALUE_I),   /* 9-bit input: Counter value input*/   
           .DATAIN(DATA_I),           /* 1-bit input: Data input from the logic*/   
           .EN_VTC(C_DLY_TYPE=="FIXED"?1:0),   /* 1-bit input: Keep delay constant over VT*/   
           .IDATAIN(IDATA_I),         /* 1-bit input: Data input from the IOBUF*/   
           .INC(INC_I),                 /* 1-bit input: Increment / Decrement tap delay input*/   
           .LOAD(LD_I),               /* 1-bit input: Load DELAY_VALUE input*/   
           .RST(RST_I)                  /* 1-bit input: Asynchronous Reset to the DELAY_VALUE*/   
        );   
   end   
  
endgenerate  

    
endmodule
