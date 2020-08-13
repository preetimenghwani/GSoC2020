----------------------------------------------------------------------------
--  top.vhd (for cmv_hdmi)
--	Axiom Beta CMV HDMI Test
--	Version 1.3
--
--  Copyright (C) 2013-2015 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Vivado 2014.2:
--    mkdir -p build.vivado
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.axi3s_pkg.ALL;		-- AXI3 Slave

use work.reduce_pkg.ALL;	-- Logic Reduction
use work.vivado_pkg.ALL;	-- Vivado Attributes

use work.fifo_pkg.ALL;		-- FIFO Functions
use work.reg_array_pkg.ALL;	-- Register Arrays
use work.par_array_pkg.ALL;	-- Parallel Data
use work.helper_pkg.ALL;	-- Vivado Attributes


entity top is
    port (
	i2c_scl : inout std_ulogic;
	i2c_sda : inout std_ulogic
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal clk_100 : std_logic;

    --------------------------------------------------------------------
    -- PS7 Signals
    --------------------------------------------------------------------

    signal ps_fclk : std_logic_vector (3 downto 0);
    signal ps_reset_n : std_logic_vector (3 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI CMV Master Signals
    --------------------------------------------------------------------

    signal m_axi0_aclk : std_logic;
    signal m_axi0_areset_n : std_logic;

    signal m_axi0_ri : axi3m_read_in_r;
    signal m_axi0_ro : axi3m_read_out_r;
    signal m_axi0_wi : axi3m_write_in_r;
    signal m_axi0_wo : axi3m_write_out_r;

    signal m_axi0l_ri : axi3ml_read_in_r;
    signal m_axi0l_ro : axi3ml_read_out_r;
    signal m_axi0l_wi : axi3ml_write_in_r;
    signal m_axi0l_wo : axi3ml_write_out_r;

    signal m_axi0a_aclk : std_logic_vector (7 downto 0);
    signal m_axi0a_areset_n : std_logic_vector (7 downto 0);

    signal m_axi0a_ri : axi3ml_read_in_a(7 downto 0);
    signal m_axi0a_ro : axi3ml_read_out_a(7 downto 0);
    signal m_axi0a_wi : axi3ml_write_in_a(7 downto 0);
    signal m_axi0a_wo : axi3ml_write_out_a(7 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI HDMI Master Signals
    --------------------------------------------------------------------

    signal m_axi1_aclk : std_logic;
    signal m_axi1_areset_n : std_logic;

    signal m_axi1_ri : axi3m_read_in_r;
    signal m_axi1_ro : axi3m_read_out_r;
    signal m_axi1_wi : axi3m_write_in_r;
    signal m_axi1_wo : axi3m_write_out_r;

    signal m_axi1l_ri : axi3ml_read_in_r;
    signal m_axi1l_ro : axi3ml_read_out_r;
    signal m_axi1l_wi : axi3ml_write_in_r;
    signal m_axi1l_wo : axi3ml_write_out_r;

    signal m_axi1a_aclk : std_logic_vector (7 downto 0);
    signal m_axi1a_areset_n : std_logic_vector (7 downto 0);

    signal m_axi1a_ri : axi3ml_read_in_a(7 downto 0);
    signal m_axi1a_ro : axi3ml_read_out_a(7 downto 0);
    signal m_axi1a_wi : axi3ml_write_in_a(7 downto 0);
    signal m_axi1a_wo : axi3ml_write_out_a(7 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_logic_vector (3 downto 0);
    signal s_axi_areset_n : std_logic_vector (3 downto 0);

    signal s_axi_ri : axi3s_read_in_a(3 downto 0);
    signal s_axi_ro : axi3s_read_out_a(3 downto 0);
    signal s_axi_wi : axi3s_write_in_a(3 downto 0);
    signal s_axi_wo : axi3s_write_out_a(3 downto 0);

    --------------------------------------------------------------------
    -- PS7 EMIO GPIO Signals
    --------------------------------------------------------------------

    signal emio_gpio_i : std_logic_vector(63 downto 0);
    signal emio_gpio_o : std_logic_vector(63 downto 0);
    signal emio_gpio_t_n : std_logic_vector(63 downto 0);

    --------------------------------------------------------------------
    -- I2C0 Signals
    --------------------------------------------------------------------

    signal i2c0_sda_i : std_ulogic;
    signal i2c0_sda_o : std_ulogic;
    signal i2c0_sda_t : std_ulogic;
    signal i2c0_sda_t_n : std_ulogic;

    signal i2c0_scl_i : std_ulogic;
    signal i2c0_scl_o : std_ulogic;
    signal i2c0_scl_t : std_ulogic;
    signal i2c0_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- I2C1 Signals
    --------------------------------------------------------------------

    signal i2c1_sda_i : std_ulogic;
    signal i2c1_sda_o : std_ulogic;
    signal i2c1_sda_t : std_ulogic;
    signal i2c1_sda_t_n : std_ulogic;

    signal i2c1_scl_i : std_ulogic;
    signal i2c1_scl_o : std_ulogic;
    signal i2c1_scl_t : std_ulogic;
    signal i2c1_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- CMV MMCM Signals
    --------------------------------------------------------------------

    signal cmv_pll_locked : std_ulogic;

    signal cmv_lvds_clk : std_ulogic;
    signal cmv_cmd_clk : std_ulogic;
    signal cmv_spi_clk : std_ulogic;
    signal cmv_axi_clk : std_ulogic;
    signal cmv_dly_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS PLL Signals
    --------------------------------------------------------------------

    signal lvds_pll_locked : std_ulogic;

    signal lvds_clk : std_ulogic;
    signal word_clk : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- HDMI MMCM Signals
    --------------------------------------------------------------------

    signal data_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS IDELAY Signals
    --------------------------------------------------------------------

    constant CHANNELS : natural := 64;
    constant NUM_WRITERS : natural := 2;

    signal idelay_valid : std_logic;
    signal ser_out : std_logic_vector (CHANNELS + 1 downto 0)
	:= (others => '0');

    --------------------------------------------------------------------
    -- CMV Serdes Signals
    --------------------------------------------------------------------

    alias serdes_clk : std_logic is lvds_clk;
    alias serdes_clkdiv : std_logic is word_clk;

    signal serdes_phase : std_logic;

    signal serdes_bitslip : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- CMV Parallel Data Signals
    --------------------------------------------------------------------

    signal par_data : par12_a (CHANNELS downto 0);
    signal par_data_e : par12_a (CHANNELS downto 0);
    signal par_data_o : par12_a (CHANNELS downto 0);

    alias par_ctrl : std_logic_vector (11 downto 0)
	is par_data(CHANNELS);
    signal par_ctrl_d : std_logic_vector (11 downto 0);

    signal par_valid : std_logic;
    signal par_valid_d : std_logic;
    signal par_enable : std_logic;

    --------------------------------------------------------------------
    -- Remapper Signals
    --------------------------------------------------------------------

    signal map_ctrl : std_logic_vector (11 downto 0);
    signal map_data : par12_a (CHANNELS - 1 downto 0);

    signal remap_ctrl : std_logic_vector (11 downto 0);
    signal remap_data : par12_a (CHANNELS - 1 downto 0);

    signal chop_enable : std_logic;

    --------------------------------------------------------------------
    -- CMV Register File Signals
    --------------------------------------------------------------------

    constant REG_SPLIT : natural := 8;
    constant OREG_SIZE : natural := 16;

    signal reg_oreg : reg32_a(0 to OREG_SIZE - 1);

    alias waddr_buf0 : std_logic_vector (31 downto 0)
	is reg_oreg(0)(31 downto 0);

    alias waddr_pat0 : std_logic_vector (31 downto 0)
	is reg_oreg(1)(31 downto 0);

    alias waddr_buf1 : std_logic_vector (31 downto 0)
	is reg_oreg(2)(31 downto 0);

    alias waddr_pat1 : std_logic_vector (31 downto 0)
	is reg_oreg(3)(31 downto 0);

    alias waddr_buf2 : std_logic_vector (31 downto 0)
	is reg_oreg(4)(31 downto 0);

    alias waddr_pat2 : std_logic_vector (31 downto 0)
	is reg_oreg(5)(31 downto 0);

    alias waddr_buf3 : std_logic_vector (31 downto 0)
	is reg_oreg(6)(31 downto 0);

    alias waddr_pat3 : std_logic_vector (31 downto 0)
	is reg_oreg(7)(31 downto 0);

    alias waddr_cinc : std_logic_vector (31 downto 0)
	is reg_oreg(8)(31 downto 0);

    alias waddr_rinc : std_logic_vector (31 downto 0)
	is reg_oreg(9)(31 downto 0);

    alias waddr_ccnt : std_logic_vector (11 downto 0)
	is reg_oreg(10)(11 downto 0);

    alias fifo_data_reset : std_logic is reg_oreg(11)(0);

    alias oreg_wblock : std_logic is reg_oreg(11)(4);
    alias oreg_wreset : std_logic is reg_oreg(11)(5);
    alias oreg_wload : std_logic is reg_oreg(11)(6);
    alias oreg_wswitch : std_logic is reg_oreg(11)(7);

    alias serdes_reset : std_logic is reg_oreg(11)(8);

    alias count_enable : std_logic is reg_oreg(11)(9);

    alias wbuf_enable : std_logic_vector (3 downto 0)
	is reg_oreg(11)(15 downto 12);

    alias writer_enable : std_logic_vector (3 downto 0)
	is reg_oreg(11)(19 downto 16);

    alias rcn_clip : std_logic_vector (1 downto 0)
	is reg_oreg(11)(21 downto 20);

    alias write_strobe : std_logic_vector (7 downto 0)
	is reg_oreg(11)(31 downto 24);

    alias reg_pattern : std_logic_vector (11 downto 0)
	is reg_oreg(12)(11 downto 0);

    alias reg_mval : std_logic_vector (2 downto 0)
	is reg_oreg(13)(0 + 2 downto 0);

    alias reg_mask : std_logic_vector (2 downto 0)
	is reg_oreg(13)(8 + 2 downto 8);

    alias reg_amsk : std_logic_vector (2 downto 0)
	is reg_oreg(13)(16 + 2 downto 16);

    alias led_val : std_logic_vector (7 downto 0)
	is reg_oreg(14)(7 downto 0);

    alias i2c1_sel : std_logic_vector (1 downto 0)
	is reg_oreg(14)(13 downto 12);

    alias led_mask : std_logic_vector (7 downto 0)
	is reg_oreg(14)(23 downto 16);

    alias swi_val : std_logic_vector (7 downto 0)
	is reg_oreg(15)(7 downto 0);

    alias btn_val : std_logic_vector (4 downto 0)
	is reg_oreg(15)(8 + 4 downto 8);

    alias swi_mask : std_logic_vector (7 downto 0)
	is reg_oreg(15)(23 downto 16);

    alias btn_mask : std_logic_vector (4 downto 0)
	is reg_oreg(15)(24 + 4 downto 24);


    constant IREG_SIZE : natural := 8;

    signal led_done : std_logic;

    signal reg_ireg : reg32_a(0 to IREG_SIZE - 1);

    signal usr_access : std_logic_vector (31 downto 0);

    --------------------------------------------------------------------
    -- Scan Register File Signals
    --------------------------------------------------------------------

    constant DATA_WIDTH : natural := 64;

    constant ADDR_WIDTH : natural := 32;

    type addr_a is array (natural range <>) of
	std_logic_vector (ADDR_WIDTH - 1 downto 0);

    constant RADDR_MASK : addr_a(0 to 3) := 
	( x"07FFFFFF", x"07FFFFFF", x"07FFFFFF", x"07FFFFFF" );
    constant RADDR_BASE : addr_a(0 to 3) := 
	( x"18000000", x"20000000", x"18000000", x"20000000" );

    constant WADDR_MASK : addr_a(0 to 3) := 
	( x"07FFFFFF", x"07FFFFFF", x"07FFFFFF", x"07FFFFFF" );
    constant WADDR_BASE : addr_a(0 to 3) := 
        ( x"18000000", x"18004000", x"18000000", x"20000000" );
        
    --------------------------------------------------------------------
    -- Writer Constants and Signals
    --------------------------------------------------------------------

    type arr_dwidth is array (NUM_WRITERS-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type arr_addrwidth is array (NUM_WRITERS-1 downto 0) of  std_logic_vector(ADDR_WIDTH-1 downto 0);
    type arr_2 is array (NUM_WRITERS-1 downto 0) of  std_logic_vector(1 downto 0);
 
     signal wdata_clk : std_logic_vector(NUM_WRITERS-1 downto 0);
     signal wdata_enable : std_logic_vector(NUM_WRITERS-1 downto 0);
     signal wdata_in : arr_dwidth;
     signal wdata_empty : std_logic_vector(NUM_WRITERS-1 downto 0);
 
     signal wdata_full : std_logic_vector(NUM_WRITERS-1 downto 0);
 
     signal waddr_clk : std_logic_vector(NUM_WRITERS-1 downto 0);
     signal waddr_enable : std_logic_vector(NUM_WRITERS-1 downto 0);
     signal waddr_in : arr_addrwidth;
     signal waddr_empty : std_logic_vector(NUM_WRITERS-1 downto 0);
 
     signal waddr_match : std_logic_vector(NUM_WRITERS-1 downto 0);
     signal waddr_sel : arr_2;
     signal waddr_sel_in : arr_2;
 
     signal wbuf_sel : arr_2;
 
     alias writer_clk : std_logic is cmv_axi_clk;
 
     signal writer_inactive : std_logic_vector (3 downto 0);
     signal writer_error : std_logic_vector (3 downto 0);
 
     signal writer_active : std_logic_vector (3 downto 0);
     signal writer_unconf : std_logic_vector (3 downto 0);
 
     signal waddr_reset : std_logic;
     signal waddr_load : std_logic;
     signal waddr_switch : std_logic;
     signal waddr_block : std_logic;

    --------------------------------------------------------------------
    -- Data FIFO Signals
    --------------------------------------------------------------------

    signal fifo_data_in : arr_dwidth;
    signal fifo_data_out : arr_dwidth;

    constant DATA_CWIDTH : natural := cwidth_f(DATA_WIDTH, "36Kb");
    type arr_dcwidth is array (NUM_WRITERS-1 downto 0) of std_logic_vector(DATA_CWIDTH-1 downto 0);

    signal fifo_data_rdcount : arr_dcwidth;
    signal fifo_data_wrcount : arr_dcwidth;

    signal fifo_data_wclk : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_wen : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_high : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_full : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_wrerr : std_logic_vector(NUM_WRITERS-1 downto 0);

    signal fifo_data_rclk : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_ren : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_low : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_empty : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_rderr : std_logic_vector(NUM_WRITERS-1 downto 0);

    signal fifo_data_rst : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_rrdy : std_logic_vector(NUM_WRITERS-1 downto 0);
    signal fifo_data_wrdy : std_logic_vector(NUM_WRITERS-1 downto 0);

    signal data_ctrl : std_logic_vector( 23 downto 0);

    alias data_dval : std_logic is data_ctrl(0);
    alias data_lval : std_logic is data_ctrl(1);
    alias data_fval : std_logic is data_ctrl(2);

    signal match_en : std_logic;
    signal data_wen : std_logic_vector(NUM_WRITERS -1  downto 0);

    signal data_in : arr_dwidth;

    signal cmv_active : std_logic;


begin

    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
	    i2c0_sda_i => i2c0_sda_i,
	    i2c0_sda_o => i2c0_sda_o,
	    i2c0_sda_t_n => i2c0_sda_t_n,
	    --
	    i2c0_scl_i => i2c0_scl_i,
	    i2c0_scl_o => i2c0_scl_o,
	    i2c0_scl_t_n => i2c0_scl_t_n,
	    --
	    i2c1_sda_i => i2c1_sda_i,
	    i2c1_sda_o => i2c1_sda_o,
	    i2c1_sda_t_n => i2c1_sda_t_n,
	    --
	    i2c1_scl_i => i2c1_scl_i,
	    i2c1_scl_o => i2c1_scl_o,
	    i2c1_scl_t_n => i2c1_scl_t_n,
	    --
	    ps_fclk => ps_fclk,
	    ps_reset_n => ps_reset_n,
	    --
	    emio_gpio_i => emio_gpio_i,
	    emio_gpio_o => emio_gpio_o,
	    emio_gpio_t_n => emio_gpio_t_n,
	    --
	    m_axi0_aclk => m_axi0_aclk,
	    m_axi0_areset_n => m_axi0_areset_n,
	    --
	    m_axi0_arid => m_axi0_ro.arid,
	    m_axi0_araddr => m_axi0_ro.araddr,
	    m_axi0_arburst => m_axi0_ro.arburst,
	    m_axi0_arlen => m_axi0_ro.arlen,
	    m_axi0_arsize => m_axi0_ro.arsize,
	    m_axi0_arprot => m_axi0_ro.arprot,
	    m_axi0_arvalid => m_axi0_ro.arvalid,
	    m_axi0_arready => m_axi0_ri.arready,
	    --
	    m_axi0_rid => m_axi0_ri.rid,
	    m_axi0_rdata => m_axi0_ri.rdata,
	    m_axi0_rlast => m_axi0_ri.rlast,
	    m_axi0_rresp => m_axi0_ri.rresp,
	    m_axi0_rvalid => m_axi0_ri.rvalid,
	    m_axi0_rready => m_axi0_ro.rready,
	    --
	    m_axi0_awid => m_axi0_wo.awid,
	    m_axi0_awaddr => m_axi0_wo.awaddr,
	    m_axi0_awburst => m_axi0_wo.awburst,
	    m_axi0_awlen => m_axi0_wo.awlen,
	    m_axi0_awsize => m_axi0_wo.awsize,
	    m_axi0_awprot => m_axi0_wo.awprot,
	    m_axi0_awvalid => m_axi0_wo.awvalid,
	    m_axi0_awready => m_axi0_wi.wready,
	    --
	    m_axi0_wid => m_axi0_wo.wid,
	    m_axi0_wdata => m_axi0_wo.wdata,
	    m_axi0_wstrb => m_axi0_wo.wstrb,
	    m_axi0_wlast => m_axi0_wo.wlast,
	    m_axi0_wvalid => m_axi0_wo.wvalid,
	    m_axi0_wready => m_axi0_wi.wready,
	    --
	    m_axi0_bid => m_axi0_wi.bid,
	    m_axi0_bresp => m_axi0_wi.bresp,
	    m_axi0_bvalid => m_axi0_wi.bvalid,
	    m_axi0_bready => m_axi0_wo.bready,
	    --
	    m_axi1_aclk => m_axi1_aclk,
	    m_axi1_areset_n => m_axi1_areset_n,
	    --
	    m_axi1_arid => m_axi1_ro.arid,
	    m_axi1_araddr => m_axi1_ro.araddr,
	    m_axi1_arburst => m_axi1_ro.arburst,
	    m_axi1_arlen => m_axi1_ro.arlen,
	    m_axi1_arsize => m_axi1_ro.arsize,
	    m_axi1_arprot => m_axi1_ro.arprot,
	    m_axi1_arvalid => m_axi1_ro.arvalid,
	    m_axi1_arready => m_axi1_ri.arready,
	    --
	    m_axi1_rid => m_axi1_ri.rid,
	    m_axi1_rdata => m_axi1_ri.rdata,
	    m_axi1_rlast => m_axi1_ri.rlast,
	    m_axi1_rresp => m_axi1_ri.rresp,
	    m_axi1_rvalid => m_axi1_ri.rvalid,
	    m_axi1_rready => m_axi1_ro.rready,
	    --
	    m_axi1_awid => m_axi1_wo.awid,
	    m_axi1_awaddr => m_axi1_wo.awaddr,
	    m_axi1_awburst => m_axi1_wo.awburst,
	    m_axi1_awlen => m_axi1_wo.awlen,
	    m_axi1_awsize => m_axi1_wo.awsize,
	    m_axi1_awprot => m_axi1_wo.awprot,
	    m_axi1_awvalid => m_axi1_wo.awvalid,
	    m_axi1_awready => m_axi1_wi.wready,
	    --
	    m_axi1_wid => m_axi1_wo.wid,
	    m_axi1_wdata => m_axi1_wo.wdata,
	    m_axi1_wstrb => m_axi1_wo.wstrb,
	    m_axi1_wlast => m_axi1_wo.wlast,
	    m_axi1_wvalid => m_axi1_wo.wvalid,
	    m_axi1_wready => m_axi1_wi.wready,
	    --
	    m_axi1_bid => m_axi1_wi.bid,
	    m_axi1_bresp => m_axi1_wi.bresp,
	    m_axi1_bvalid => m_axi1_wi.bvalid,
	    m_axi1_bready => m_axi1_wo.bready,
	    --
	    s_axi0_aclk => s_axi_aclk(0),
	    s_axi0_areset_n => s_axi_areset_n(0),
	    --
	    s_axi0_arid => s_axi_ri(0).arid,
	    s_axi0_araddr => s_axi_ri(0).araddr,
	    s_axi0_arburst => s_axi_ri(0).arburst,
	    s_axi0_arlen => s_axi_ri(0).arlen,
	    s_axi0_arsize => s_axi_ri(0).arsize,
	    s_axi0_arprot => s_axi_ri(0).arprot,
	    s_axi0_arvalid => s_axi_ri(0).arvalid,
	    s_axi0_arready => s_axi_ro(0).arready,
	    s_axi0_racount => s_axi_ro(0).racount,
	    --
	    s_axi0_rid => s_axi_ro(0).rid,
	    s_axi0_rdata => s_axi_ro(0).rdata,
	    s_axi0_rlast => s_axi_ro(0).rlast,
	    s_axi0_rvalid => s_axi_ro(0).rvalid,
	    s_axi0_rready => s_axi_ri(0).rready,
	    s_axi0_rcount => s_axi_ro(0).rcount,
	    --
	    s_axi0_awid => s_axi_wi(0).awid,
	    s_axi0_awaddr => s_axi_wi(0).awaddr,
	    s_axi0_awburst => s_axi_wi(0).awburst,
	    s_axi0_awlen => s_axi_wi(0).awlen,
	    s_axi0_awsize => s_axi_wi(0).awsize,
	    s_axi0_awprot => s_axi_wi(0).awprot,
	    s_axi0_awvalid => s_axi_wi(0).awvalid,
	    s_axi0_awready => s_axi_wo(0).awready,
	    s_axi0_wacount => s_axi_wo(0).wacount,
	    --
	    s_axi0_wid => s_axi_wi(0).wid,
	    s_axi0_wdata => s_axi_wi(0).wdata,
	    s_axi0_wstrb => s_axi_wi(0).wstrb,
	    s_axi0_wlast => s_axi_wi(0).wlast,
	    s_axi0_wvalid => s_axi_wi(0).wvalid,
	    s_axi0_wready => s_axi_wo(0).wready,
	    s_axi0_wcount => s_axi_wo(0).wcount,
	    --
	    s_axi0_bid => s_axi_wo(0).bid,
	    s_axi0_bresp => s_axi_wo(0).bresp,
	    s_axi0_bvalid => s_axi_wo(0).bvalid,
	    s_axi0_bready => s_axi_wi(0).bready,
	    --
	    s_axi1_aclk => s_axi_aclk(1),
	    s_axi1_areset_n => s_axi_areset_n(1),
	    --
	    s_axi1_arid => s_axi_ri(1).arid,
	    s_axi1_araddr => s_axi_ri(1).araddr,
	    s_axi1_arburst => s_axi_ri(1).arburst,
	    s_axi1_arlen => s_axi_ri(1).arlen,
	    s_axi1_arsize => s_axi_ri(1).arsize,
	    s_axi1_arprot => s_axi_ri(1).arprot,
	    s_axi1_arvalid => s_axi_ri(1).arvalid,
	    s_axi1_arready => s_axi_ro(1).arready,
	    s_axi1_racount => s_axi_ro(1).racount,
	    --
	    s_axi1_rid => s_axi_ro(1).rid,
	    s_axi1_rdata => s_axi_ro(1).rdata,
	    s_axi1_rlast => s_axi_ro(1).rlast,
	    s_axi1_rvalid => s_axi_ro(1).rvalid,
	    s_axi1_rready => s_axi_ri(1).rready,
	    s_axi1_rcount => s_axi_ro(1).rcount,
	    --
	    s_axi1_awid => s_axi_wi(1).awid,
	    s_axi1_awaddr => s_axi_wi(1).awaddr,
	    s_axi1_awburst => s_axi_wi(1).awburst,
	    s_axi1_awlen => s_axi_wi(1).awlen,
	    s_axi1_awsize => s_axi_wi(1).awsize,
	    s_axi1_awprot => s_axi_wi(1).awprot,
	    s_axi1_awvalid => s_axi_wi(1).awvalid,
	    s_axi1_awready => s_axi_wo(1).awready,
	    s_axi1_wacount => s_axi_wo(1).wacount,
	    --
	    s_axi1_wid => s_axi_wi(1).wid,
	    s_axi1_wdata => s_axi_wi(1).wdata,
	    s_axi1_wstrb => s_axi_wi(1).wstrb,
	    s_axi1_wlast => s_axi_wi(1).wlast,
	    s_axi1_wvalid => s_axi_wi(1).wvalid,
	    s_axi1_wready => s_axi_wo(1).wready,
	    s_axi1_wcount => s_axi_wo(1).wcount,
	    --
	    s_axi1_bid => s_axi_wo(1).bid,
	    s_axi1_bresp => s_axi_wo(1).bresp,
	    s_axi1_bvalid => s_axi_wo(1).bvalid,
	    s_axi1_bready => s_axi_wi(1).bready,
	    --
	    s_axi2_aclk => s_axi_aclk(2),
	    s_axi2_areset_n => s_axi_areset_n(2),
	    --
	    s_axi2_arid => s_axi_ri(2).arid,
	    s_axi2_araddr => s_axi_ri(2).araddr,
	    s_axi2_arburst => s_axi_ri(2).arburst,
	    s_axi2_arlen => s_axi_ri(2).arlen,
	    s_axi2_arsize => s_axi_ri(2).arsize,
	    s_axi2_arprot => s_axi_ri(2).arprot,
	    s_axi2_arvalid => s_axi_ri(2).arvalid,
	    s_axi2_arready => s_axi_ro(2).arready,
	    s_axi2_racount => s_axi_ro(2).racount,
	    --
	    s_axi2_rid => s_axi_ro(2).rid,
	    s_axi2_rdata => s_axi_ro(2).rdata,
	    s_axi2_rlast => s_axi_ro(2).rlast,
	    s_axi2_rvalid => s_axi_ro(2).rvalid,
	    s_axi2_rready => s_axi_ri(2).rready,
	    s_axi2_rcount => s_axi_ro(2).rcount,
	    --
	    s_axi2_awid => s_axi_wi(2).awid,
	    s_axi2_awaddr => s_axi_wi(2).awaddr,
	    s_axi2_awburst => s_axi_wi(2).awburst,
	    s_axi2_awlen => s_axi_wi(2).awlen,
	    s_axi2_awsize => s_axi_wi(2).awsize,
	    s_axi2_awprot => s_axi_wi(2).awprot,
	    s_axi2_awvalid => s_axi_wi(2).awvalid,
	    s_axi2_awready => s_axi_wo(2).awready,
	    s_axi2_wacount => s_axi_wo(2).wacount,
	    --
	    s_axi2_wid => s_axi_wi(2).wid,
	    s_axi2_wdata => s_axi_wi(2).wdata,
	    s_axi2_wstrb => s_axi_wi(2).wstrb,
	    s_axi2_wlast => s_axi_wi(2).wlast,
	    s_axi2_wvalid => s_axi_wi(2).wvalid,
	    s_axi2_wready => s_axi_wo(2).wready,
	    s_axi2_wcount => s_axi_wo(2).wcount,
	    --
	    s_axi2_bid => s_axi_wo(2).bid,
	    s_axi2_bresp => s_axi_wo(2).bresp,
	    s_axi2_bvalid => s_axi_wo(2).bvalid,
	    s_axi2_bready => s_axi_wi(2).bready,
	    --
	    s_axi3_aclk => s_axi_aclk(3),
	    s_axi3_areset_n => s_axi_areset_n(3),
	    --
	    s_axi3_arid => s_axi_ri(3).arid,
	    s_axi3_araddr => s_axi_ri(3).araddr,
	    s_axi3_arburst => s_axi_ri(3).arburst,
	    s_axi3_arlen => s_axi_ri(3).arlen,
	    s_axi3_arsize => s_axi_ri(3).arsize,
	    s_axi3_arprot => s_axi_ri(3).arprot,
	    s_axi3_arvalid => s_axi_ri(3).arvalid,
	    s_axi3_arready => s_axi_ro(3).arready,
	    s_axi3_racount => s_axi_ro(3).racount,
	    --
	    s_axi3_rid => s_axi_ro(3).rid,
	    s_axi3_rdata => s_axi_ro(3).rdata,
	    s_axi3_rlast => s_axi_ro(3).rlast,
	    s_axi3_rvalid => s_axi_ro(3).rvalid,
	    s_axi3_rready => s_axi_ri(3).rready,
	    s_axi3_rcount => s_axi_ro(3).rcount,
	    --
	    s_axi3_awid => s_axi_wi(3).awid,
	    s_axi3_awaddr => s_axi_wi(3).awaddr,
	    s_axi3_awburst => s_axi_wi(3).awburst,
	    s_axi3_awlen => s_axi_wi(3).awlen,
	    s_axi3_awsize => s_axi_wi(3).awsize,
	    s_axi3_awprot => s_axi_wi(3).awprot,
	    s_axi3_awvalid => s_axi_wi(3).awvalid,
	    s_axi3_awready => s_axi_wo(3).awready,
	    s_axi3_wacount => s_axi_wo(3).wacount,
	    --
	    s_axi3_wid => s_axi_wi(3).wid,
	    s_axi3_wdata => s_axi_wi(3).wdata,
	    s_axi3_wstrb => s_axi_wi(3).wstrb,
	    s_axi3_wlast => s_axi_wi(3).wlast,
	    s_axi3_wvalid => s_axi_wi(3).wvalid,
	    s_axi3_wready => s_axi_wo(3).wready,
	    s_axi3_wcount => s_axi_wo(3).wcount,
	    --
	    s_axi3_bid => s_axi_wo(3).bid,
	    s_axi3_bresp => s_axi_wo(3).bresp,
	    s_axi3_bvalid => s_axi_wo(3).bvalid,
	    s_axi3_bready => s_axi_wi(3).bready );

    clk_100 <= ps_fclk(0);

    --------------------------------------------------------------------
    -- I2C Interface AB
    --------------------------------------------------------------------

    i2c1_sda_t <= not i2c1_sda_t_n;

    IOBUF_sda_inst : IOBUF
	port map (
	    I => i2c1_sda_o, O => i2c1_sda_i,
	    T => i2c1_sda_t, IO => i2c_sda );

    i2c1_scl_t <= not i2c1_scl_t_n;

    PULLUP_sda_inst : PULLUP
        port map ( O => i2c_sda );

    IOBUF_scl_inst : IOBUF
	port map (
	    I => i2c1_scl_o, O => i2c1_scl_i,
	    T => i2c1_scl_t, IO => i2c_scl );

    PULLUP_scl_inst : PULLUP
        port map ( O => i2c_scl );

    --------------------------------------------------------------------
    -- CMV/LVDS/HDMI MMCM/PLL
    --------------------------------------------------------------------

    cmv_pll_inst : entity work.cmv_pll (RTL_250MHZ)
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_locked => cmv_pll_locked,
	    --
	    lvds_clk => cmv_lvds_clk,
	    dly_clk => cmv_dly_clk,
	    cmv_clk => cmv_cmd_clk,
	    spi_clk => cmv_spi_clk,
	    axi_clk => cmv_axi_clk );

    lvds_pll_inst : entity work.lvds_pll (RTL_250MHZ)
	port map (
	    ref_clk_in => cmv_lvds_clk,
	    --
	    pll_locked => lvds_pll_locked,
	    --
	    lvds_clk => lvds_clk,
	    word_clk => word_clk );

    --------------------------------------------------------------------
    -- AXI3 CMV Interconnect
    --------------------------------------------------------------------

    axi_lite_inst0 : entity work.axi_lite
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,

	    s_axi_ro => m_axi0_ri,
	    s_axi_ri => m_axi0_ro,
	    s_axi_wo => m_axi0_wi,
	    s_axi_wi => m_axi0_wo,

	    m_axi_ro => m_axi0l_ro,
	    m_axi_ri => m_axi0l_ri,
	    m_axi_wo => m_axi0l_wo,
	    m_axi_wi => m_axi0l_wi );

    m_axi0_aclk <= clk_100;

    axi_split_inst0 : entity work.axi_split8
	generic map (
	    SPLIT_BIT0 => 20,
	    SPLIT_BIT1 => 21,
	    SPLIT_BIT2 => 22 )
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi0l_ri,
	    s_axi_ri => m_axi0l_ro,
	    s_axi_wo => m_axi0l_wi,
	    s_axi_wi => m_axi0l_wo,
	    --
	    m_axi_aclk => m_axi0a_aclk,
	    m_axi_areset_n => m_axi0a_areset_n,
	    --
	    m_axi_ri => m_axi0a_ri,
	    m_axi_ro => m_axi0a_ro,
	    m_axi_wi => m_axi0a_wi,
            m_axi_wo => m_axi0a_wo );
            
    --------------------------------------------------------------------
    -- Capture Register File
    --------------------------------------------------------------------

    reg_file_inst0 : entity work.reg_file
	generic map (
	    REG_SPLIT => REG_SPLIT,
	    OREG_SIZE => OREG_SIZE,
	    IREG_SIZE => IREG_SIZE,
	    INITIAL =>
		(11 => x"00000031", others => (others => '0')) )
	port map (
	    s_axi_aclk => m_axi0a_aclk(1),
	    s_axi_areset_n => m_axi0a_areset_n(1),
	    --
	    s_axi_ro => m_axi0a_ri(1),
	    s_axi_ri => m_axi0a_ro(1),
	    s_axi_wo => m_axi0a_wi(1),
	    s_axi_wi => m_axi0a_wo(1),
	    --
	    oreg => reg_oreg,
	    ireg => reg_ireg );

    reg_ireg(0) <= x"524547" & x"0" &
		   std_logic_vector(to_unsigned(REG_SPLIT, 4));
   -- reg_ireg(4) <= waddr_in(31 downto 0);
		   
    ser_to_par_inst : entity work.ser_to_par
	generic map (
	    CHANNELS => CHANNELS + 1 )
	port map (
	    serdes_clk	  => serdes_clk,	-- in
	    serdes_clkdiv => serdes_clkdiv,	-- in
	    serdes_phase  => serdes_phase,	-- in
	    serdes_rst	  => serdes_reset,	-- in
	    count_enable  => count_enable,	-- in
	    --
	    par_clk	  => serdes_clk,	-- in
	    par_enable	  => par_enable,	-- out
	    par_data	  => par_data,		-- out
	    --
	    bitslip	  => serdes_bitslip(CHANNELS downto 0) );

    phase_proc : process (serdes_clkdiv)
	variable phase_v : std_logic := '0';
    begin
	serdes_phase <= phase_v;
	if rising_edge(serdes_clkdiv) then
	    phase_v := not phase_v;
	end if;
    end process;

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    gen_waddr : for I in NUM_WRITERS - 1 downto 0 generate
        waddr_gen_inst : entity work.addr_qbuf
            port map (
                clk => waddr_clk(I),
                reset => waddr_reset,
                load => waddr_load,
                enable => waddr_enable(I),
                --
                sel_in => waddr_sel_in(I),
                switch => waddr_switch,
                --
                buf0_addr => waddr_buf0,
                buf1_addr => waddr_buf1,
                buf2_addr => waddr_buf2,
                buf3_addr => waddr_buf3,
                --
                col_inc => waddr_cinc,
                col_cnt => waddr_ccnt,
                --
                row_inc => waddr_rinc,
                --
                buf0_epat => waddr_pat0,
                buf1_epat => waddr_pat1,
                buf2_epat => waddr_pat2,
                buf3_epat => waddr_pat3,
                --
                addr => waddr_in(I),
                match => waddr_match(I),
                sel => waddr_sel(I) );
    
        waddr_empty(I) <= waddr_match(I) or waddr_block;
        end generate;

    --------------------------------------------------------------------
    -- Data FIFO
    --------------------------------------------------------------------

    gen_fifo : for I in NUM_WRITERS - 1 downto 0 generate
        FIFO_data_inst : FIFO_DUALCLOCK_MACRO
            generic map (
                DEVICE => "7SERIES",
                DATA_WIDTH => DATA_WIDTH,
                ALMOST_FULL_OFFSET => x"020",
                ALMOST_EMPTY_OFFSET => x"020",
                FIFO_SIZE => "36Kb",
                FIRST_WORD_FALL_THROUGH => TRUE )
            port map (
                DI => fifo_data_in(I),
                WRCLK => fifo_data_wclk(0),
                WREN => fifo_data_wen(I),
                FULL => fifo_data_full(I),
                ALMOSTFULL => fifo_data_high(I),
                WRERR => fifo_data_wrerr(I),
                WRCOUNT => fifo_data_wrcount(I),
                --
                DO => fifo_data_out(I),
                RDCLK => fifo_data_rclk(I),
                RDEN => fifo_data_ren(I),
                EMPTY => fifo_data_empty(I),
                ALMOSTEMPTY => fifo_data_low(I),
                RDERR => fifo_data_rderr(I),
                RDCOUNT => fifo_data_rdcount(I),
                --
                RST => fifo_data_rst(I) );
    
        fifo_reset_inst0 : entity work.fifo_reset
            port map (
                rclk => fifo_data_rclk(I),
                wclk => fifo_data_wclk(I),
                reset => fifo_data_reset,
                --
                fifo_rst => fifo_data_rst(I),
                fifo_rrdy => fifo_data_rrdy(I),
                fifo_wrdy => fifo_data_wrdy(I) );
        end generate;

    conf_delay_proc : process (serdes_clkdiv)
	type del_a is array (natural range <>) of
	    std_logic_vector (12 downto 0);
	type dat_a is array (natural range <>) of
	    par12_a (CHANNELS downto 0);

	variable del_v : del_a (15 downto 0)
	    := (others => (others => '0'));
	variable dat_v : dat_a (15 downto 0)
	    := (others => (others => (others => '0')));

	variable cpos_v : integer;
	variable vpos_v : integer;
	variable epos_v : integer;
	variable opos_v : integer;

    begin
	if rising_edge(serdes_clkdiv) then
	    par_valid_d <= del_v(vpos_v)(12);
	    par_ctrl_d <= del_v(cpos_v)(11 downto 0);
	    par_data_e <= dat_v(epos_v);
	    par_data_o <= dat_v(opos_v);

	    cpos_v := to_index(reg_oreg(14)(31 downto 28));
	    vpos_v := to_index(reg_oreg(14)(27 downto 24));
	    epos_v := to_index(reg_oreg(14)(23 downto 20));
	    opos_v := to_index(reg_oreg(14)(19 downto 16));

            for I in 15 downto 1 loop
		del_v(I) := del_v(I-1);
		dat_v(I) := dat_v(I-1);
	    end loop; 
	
	    del_v(0) := par_valid & par_ctrl;
	    dat_v(0) := par_data;
	end if;
    end process;

    pixel_remap_even_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk	     => serdes_clkdiv,
	    --
	    dv_par   => par_valid_d,
	    ctrl_in  => par_ctrl_d,
	    par_din  => par_data_e(31 downto 0),
	    --
	    ctrl_out => map_ctrl,
	    par_dout => map_data(31 downto 0) );

    pixel_remap_odd_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk	     => serdes_clkdiv,
	    --
	    dv_par   => par_valid_d,
	    ctrl_in  => par_ctrl_d,
	    par_din  => par_data_o(63 downto 32),
	    --
	    ctrl_out => open,
	    par_dout => map_data(63 downto 32) );

    valid_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    if serdes_phase = '1' then
		par_valid <= '1';
	    else
		par_valid <= '0';
	    end if;
	end if;
    end process;

    remap_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    remap_ctrl <= map_ctrl;
	    remap_data <=
		map_data;
	end if;
    end process;

    gen_chop : for I in NUM_WRITERS - 1 downto 0 generate
        fifo_chop_inst : entity work.fifo_chop (RTL_SHIFT)
            port map (
                par_clk => serdes_clk,
                par_enable => par_enable,
                par_data => remap_data(((I+1) * 32) - 1 downto I * 32),
                --
                par_ctrl => remap_ctrl,
                --
                fifo_clk => fifo_data_wclk(I),
                fifo_enable => data_wen(I),
                fifo_data => data_in(I),
                --
                fifo_ctrl => data_ctrl(((I + 1) * 12)-1 downto I * 12));
        end generate;

    gen_fifo_ctrl : for I in NUM_WRITERS - 1 downto 0 generate

	cmv_active <= or_reduce(data_ctrl(2 downto 0) and reg_amsk);

	fifo_data_wen(I) <= data_wen(I) and data_ctrl(2) and data_ctrl(1) 
	and data_ctrl(0);
	wdata_full(I) <= fifo_data_full(I) when fifo_data_wrdy(I) = '1' else '1';
	fifo_data_in(I) <= data_in(I);

	fifo_data_rclk(I) <= wdata_clk(I);
	fifo_data_ren(I) <=
	    wdata_enable(I) and not fifo_data_empty(I) when
		fifo_data_rrdy(I) = '1' else '0';
	wdata_empty(I) <=
	    fifo_data_low(I) when
		fifo_data_rrdy(I) = '1'  else
	    '0' when 
		fifo_data_rrdy(I) = '1'  else '1';
	wdata_in(I) <= fifo_data_out(I);
    end generate;

    --------------------------------------------------------------------
    -- AXIHP Writer
    --------------------------------------------------------------------

    gen_writer : for I in NUM_WRITERS - 1 downto 0 generate
        axihp_writer_inst : entity work.axihp_writer
            generic map (
                DATA_WIDTH => 64,
                DATA_COUNT => 16,
                ADDR_MASK => WADDR_MASK(0),
                ADDR_DATA => WADDR_BASE(I) )
            port map (
                m_axi_aclk => writer_clk,		
                m_axi_areset_n => s_axi_areset_n(I), 
                enable => writer_enable(I),		
                inactive => writer_inactive(I),	
                --
                m_axi_wo => s_axi_wi(I),
                m_axi_wi => s_axi_wo(I),
                --
                addr_clk => waddr_clk(I),
                addr_enable => waddr_enable(I),	
                addr_in => waddr_in(I),		
                addr_empty => waddr_empty(I),	
                --
		data_clk => wdata_clk(I),
                data_enable => wdata_enable(I),	
                data_in => wdata_in(I),		
                data_empty => wdata_empty(I),		
                --
		write_strobe => write_strobe,	
                --
		writer_error => writer_error(0),	
		writer_active => writer_active,	
		writer_unconf => writer_unconf );	
    
        s_axi_aclk(I) <= writer_clk;
        end generate;

    waddr_block <=  oreg_wblock;
    waddr_reset <=  oreg_wreset;
    waddr_load <=  oreg_wload;
    
end RTL;
