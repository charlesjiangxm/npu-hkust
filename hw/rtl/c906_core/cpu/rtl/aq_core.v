/*Copyright 2020-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

module aq_core(
  // BIU (Bus Interface Unit) to CP0 (Control Processor 0) Interface
  input   [2  :0]  biu_cp0_coreid,          // Core ID from bus interface unit
  input            biu_cp0_me_int,          // Machine mode external interrupt from BIU
  input            biu_cp0_ms_int,          // Machine mode software interrupt from BIU
  input            biu_cp0_mt_int,          // Machine mode timer interrupt from BIU
  input   [39 :0]  biu_cp0_rvba,            // Reset vector base address from BIU
  input            biu_cp0_se_int,          // Supervisor mode external interrupt from BIU
  input            biu_cp0_ss_int,          // Supervisor mode software interrupt from BIU
  input            biu_cp0_st_int,          // Supervisor mode timer interrupt from BIU
  
  // BIU to IFU (Instruction Fetch Unit) AXI Read Interface
  input            biu_ifu_arready,         // AXI address read ready from BIU to IFU
  input   [127:0]  biu_ifu_rdata,           // AXI read data from BIU to IFU (128-bit instruction data)
  input            biu_ifu_rid,             // AXI read transaction ID from BIU to IFU
  input            biu_ifu_rlast,           // AXI read last transfer from BIU to IFU
  input   [1  :0]  biu_ifu_rresp,           // AXI read response from BIU to IFU (00=OKAY, 01=EXOKAY, 10=SLVERR, 11=DECERR)
  input            biu_ifu_rvalid,          // AXI read data valid from BIU to IFU
  
  // BIU to LSU (Load/Store Unit) AXI Interface
  input            biu_lsu_arready,         // AXI address read ready from BIU to LSU
  input            biu_lsu_no_op,           // BIU has no pending operations for LSU
  input   [127:0]  biu_lsu_rdata,           // AXI read data from BIU to LSU (128-bit data)
  input   [3  :0]  biu_lsu_rid,             // AXI read transaction ID from BIU to LSU
  input            biu_lsu_rlast,           // AXI read last transfer from BIU to LSU
  input   [1  :0]  biu_lsu_rresp,           // AXI read response from BIU to LSU
  input            biu_lsu_rvalid,          // AXI read data valid from BIU to LSU
  input            biu_lsu_stb_awready,     // AXI address write ready for store buffer from BIU
  input            biu_lsu_stb_wready,      // AXI write data ready for store buffer from BIU
  input            biu_lsu_vb_awready,      // AXI address write ready for victim buffer from BIU
  input            biu_lsu_vb_wready,       // AXI write data ready for victim buffer from BIU
  
  // System Control and Reset
  input            cpurst_b,                // CPU reset (active low)
  
  // DTU (Debug Trace Unit) to CP0 Interface
  input            dtu_cp0_dcsr_mprven,     // Debug Control and Status Register machine privilege enable
  input   [1  :0]  dtu_cp0_dcsr_prv,       // Debug Control and Status Register privilege mode
  input   [63 :0]  dtu_cp0_rdata,          // Debug data from DTU to CP0
  input            dtu_cp0_wake_up,         // Debug wake up signal from DTU
  
  // DTU to IFU Interface
  input   [31 :0]  dtu_ifu_debug_inst,     // Debug instruction from DTU to IFU
  input            dtu_ifu_debug_inst_vld, // Debug instruction valid from DTU to IFU
  input   [21 :0]  dtu_ifu_halt_info0,     // Halt information 0 from DTU to IFU
  input   [21 :0]  dtu_ifu_halt_info1,     // Halt information 1 from DTU to IFU
  input            dtu_ifu_halt_info_vld,  // Halt information valid from DTU to IFU
  input            dtu_ifu_halt_on_reset,  // Halt on reset signal from DTU to IFU
  
  // DTU to LSU Interface
  input            dtu_lsu_addr_trig_en,   // Address trigger enable from DTU to LSU
  input            dtu_lsu_data_trig_en,   // Data trigger enable from DTU to LSU
  input   [21 :0]  dtu_lsu_halt_info,      // Halt information from DTU to LSU
  input            dtu_lsu_halt_info_vld,  // Halt information valid from DTU to LSU
  
  // DTU to RTU Interface
  input            dtu_rtu_async_halt_req, // Asynchronous halt request from DTU to RTU
  input   [63 :0]  dtu_rtu_dpc,            // Debug PC from DTU to RTU
  input            dtu_rtu_ebreak_action,  // Ebreak action from DTU to RTU
  input            dtu_rtu_int_mask,       // Interrupt mask from DTU to RTU
  input   [63 :0]  dtu_rtu_pending_tval,   // Pending trap value from DTU to RTU
  input            dtu_rtu_resume_req,     // Resume request from DTU to RTU
  input            dtu_rtu_step_en,        // Single step enable from DTU to RTU
  input            dtu_rtu_sync_flush,     // Synchronous flush from DTU to RTU
  input            dtu_rtu_sync_halt_req,  // Synchronous halt request from DTU to RTU
  
  // Global Clock
  input            forever_cpuclk,         // Global CPU clock (always running)
  
  // HPCP (Hardware Performance Counter) Interface
  input   [63 :0]  hpcp_cp0_data,          // Performance counter data from HPCP to CP0
  input            hpcp_cp0_int_vld,       // Performance counter interrupt valid from HPCP
  input            hpcp_cp0_sce,           // Performance counter special condition event from HPCP
  input            hpcp_idu_cnt_en,        // Performance counter enable for IDU from HPCP
  input            hpcp_ifu_cnt_en,        // Performance counter enable for IFU from HPCP
  input            hpcp_iu_cnt_en,         // Performance counter enable for IU from HPCP
  input            hpcp_lsu_cnt_en,        // Performance counter enable for LSU from HPCP
  input            hpcp_rtu_cnt_en,        // Performance counter enable for RTU from HPCP
  
  // MMU (Memory Management Unit) to Core Interface
  input            mmu_cp0_cmplt,          // MMU operation complete to CP0
  input   [63 :0]  mmu_cp0_data,           // MMU data to CP0
  input            mmu_cp0_tlb_inv_done,   // TLB invalidation done signal from MMU to CP0
  input            mmu_ifu_access_fault,   // Access fault signal from MMU to IFU
  input   [27 :0]  mmu_ifu_pa,             // Physical address from MMU to IFU
  input            mmu_ifu_pa_vld,         // Physical address valid from MMU to IFU
  input   [4  :0]  mmu_ifu_prot,           // Protection attributes from MMU to IFU
  input            mmu_lsu_access_fault,   // Access fault signal from MMU to LSU
  input            mmu_lsu_buf,            // Buffer attribute from MMU to LSU
  input            mmu_lsu_ca,             // Cacheable attribute from MMU to LSU
  input            mmu_lsu_data_req,       // Data request from MMU to LSU
  input   [39 :0]  mmu_lsu_data_req_addr,  // Data request address from MMU to LSU
  input            mmu_lsu_data_req_size,  // Data request size from MMU to LSU
  input   [27 :0]  mmu_lsu_pa,             // Physical address from MMU to LSU
  input            mmu_lsu_pa_vld,         // Physical address valid from MMU to LSU
  input            mmu_lsu_page_fault,     // Page fault signal from MMU to LSU
  input            mmu_lsu_sec,            // Security attribute from MMU to LSU
  input            mmu_lsu_sh,             // Shareable attribute from MMU to LSU
  input            mmu_lsu_so,             // Strongly ordered attribute from MMU to LSU
  input            mmu_xx_mmu_en,          // MMU enable signal
  input            mmu_yy_xx_no_op,        // MMU no operation signal
  
  // System Interface
  input            pad_yy_icg_scan_en,     // Integrated clock gating scan enable
  input            pad_yy_scan_mode,       // Scan mode enable
  input   [63 :0]  pmp_cp0_data,           // Physical Memory Protection data to CP0
  input   [39 :0]  sysio_cp0_apb_base,     // System I/O APB base address
  
  // ================================================================
  // OUTPUT PORTS
  // ================================================================
  
  // CP0 to BIU Interface
  output           cp0_biu_icg_en,         // Integrated clock gating enable from CP0 to BIU
  output  [1  :0]  cp0_biu_lpmd_b,         // Low power mode disable from CP0 to BIU
  
  // CP0 to DTU Interface
  output  [11 :0]  cp0_dtu_addr,           // Address from CP0 to DTU for register access
  output  [5  :0]  cp0_dtu_debug_info,     // Debug information from CP0 to DTU
  output           cp0_dtu_icg_en,         // Integrated clock gating enable from CP0 to DTU
  output           cp0_dtu_mexpt_vld,      // Machine exception valid from CP0 to DTU
  output           cp0_dtu_pcfifo_frz,     // PC FIFO freeze signal from CP0 to DTU
  output           cp0_dtu_rreg,           // Register read enable from CP0 to DTU
  output  [63 :0]  cp0_dtu_satp,           // Supervisor Address Translation and Protection register
  output  [63 :0]  cp0_dtu_wdata,          // Write data from CP0 to DTU
  output           cp0_dtu_wreg,           // Register write enable from CP0 to DTU
  
  // CP0 to HPCP Interface
  output           cp0_hpcp_icg_en,        // Integrated clock gating enable from CP0 to HPCP
  output  [11 :0]  cp0_hpcp_index,         // Index for performance counter access
  output           cp0_hpcp_int_off_vld,   // Interrupt off valid signal from CP0 to HPCP
  output  [31 :0]  cp0_hpcp_mcntwen,       // Machine counter write enable from CP0 to HPCP
  output           cp0_hpcp_pmdm,          // Performance monitor debug mode from CP0 to HPCP
  output           cp0_hpcp_pmds,          // Performance monitor debug supervisor from CP0 to HPCP
  output           cp0_hpcp_pmdu,          // Performance monitor debug user from CP0 to HPCP
  output           cp0_hpcp_sync_stall_vld, // Synchronous stall valid from CP0 to HPCP
  output  [63 :0]  cp0_hpcp_wdata,         // Write data from CP0 to HPCP
  output           cp0_hpcp_wreg,          // Register write enable from CP0 to HPCP
  
  // CP0 to MMU Interface
  output  [11 :0]  cp0_mmu_addr,           // Address from CP0 to MMU for register access
  output           cp0_mmu_icg_en,         // Integrated clock gating enable from CP0 to MMU
  output           cp0_mmu_lpmd_req,       // Low power mode request from CP0 to MMU
  output           cp0_mmu_maee,           // Memory attribute extension enable from CP0 to MMU
  output           cp0_mmu_mxr,            // Make executable readable from CP0 to MMU
  output           cp0_mmu_ptw_en,         // Page table walker enable from CP0 to MMU
  output  [63 :0]  cp0_mmu_satp_data,      // SATP (Supervisor Address Translation and Protection) data
  output           cp0_mmu_satp_wen,       // SATP write enable from CP0 to MMU
  output           cp0_mmu_sum,            // Supervisor user memory access from CP0 to MMU
  output           cp0_mmu_tlb_all_inv,    // TLB invalidate all from CP0 to MMU
  output  [15 :0]  cp0_mmu_tlb_asid,       // TLB Address Space ID from CP0 to MMU
  output           cp0_mmu_tlb_asid_all_inv, // TLB invalidate all ASIDs from CP0 to MMU
  output  [26 :0]  cp0_mmu_tlb_va,         // TLB virtual address from CP0 to MMU
  output           cp0_mmu_tlb_va_all_inv, // TLB invalidate all virtual addresses from CP0 to MMU
  output           cp0_mmu_tlb_va_asid_inv, // TLB invalidate specific VA and ASID from CP0 to MMU
  output  [63 :0]  cp0_mmu_wdata,          // Write data from CP0 to MMU
  output           cp0_mmu_wreg,           // Register write enable from CP0 to MMU
  
  // CP0 to PMP Interface
  output  [11 :0]  cp0_pmp_addr,           // Address from CP0 to PMP for register access
  output           cp0_pmp_icg_en,         // Integrated clock gating enable from CP0 to PMP
  output  [63 :0]  cp0_pmp_wdata,          // Write data from CP0 to PMP
  output           cp0_pmp_wreg,           // Register write enable from CP0 to PMP
  
  // CP0 Global Outputs
  output           cp0_yy_clk_en,          // Global clock enable from CP0
  output  [1  :0]  cp0_yy_priv_mode,       // Current privilege mode from CP0
  
  // IDU (Instruction Decode Unit) Outputs
  output  [14 :0]  idu_dtu_debug_info,     // Debug information from IDU to DTU
  output           idu_hpcp_backend_stall, // Backend stall signal from IDU to HPCP
  output           idu_hpcp_frontend_stall, // Frontend stall signal from IDU to HPCP
  output  [6  :0]  idu_hpcp_inst_type,     // Instruction type from IDU to HPCP
  
  // IFU (Instruction Fetch Unit) to BIU AXI Interface
  output  [39 :0]  ifu_biu_araddr,         // AXI address read address from IFU to BIU
  output  [1  :0]  ifu_biu_arburst,        // AXI address read burst type from IFU to BIU
  output  [3  :0]  ifu_biu_arcache,        // AXI address read cache attributes from IFU to BIU
  output           ifu_biu_arid,           // AXI address read transaction ID from IFU to BIU
  output  [1  :0]  ifu_biu_arlen,          // AXI address read burst length from IFU to BIU
  output  [2  :0]  ifu_biu_arprot,         // AXI address read protection attributes from IFU to BIU
  output  [2  :0]  ifu_biu_arsize,         // AXI address read transfer size from IFU to BIU
  output           ifu_biu_arvalid,        // AXI address read valid from IFU to BIU
  
  // IFU to DTU Interface
  output           ifu_dtu_addr_vld0,      // Address valid 0 from IFU to DTU
  output           ifu_dtu_addr_vld1,      // Address valid 1 from IFU to DTU
  output           ifu_dtu_data_vld0,      // Data valid 0 from IFU to DTU
  output           ifu_dtu_data_vld1,      // Data valid 1 from IFU to DTU
  output  [20 :0]  ifu_dtu_debug_info,     // Debug information from IFU to DTU
  output  [39 :0]  ifu_dtu_exe_addr0,      // Execution address 0 from IFU to DTU
  output  [39 :0]  ifu_dtu_exe_addr1,      // Execution address 1 from IFU to DTU
  output  [31 :0]  ifu_dtu_exe_data0,      // Execution data 0 from IFU to DTU
  output  [31 :0]  ifu_dtu_exe_data1,      // Execution data 1 from IFU to DTU
  
  // IFU to HPCP Interface
  output           ifu_hpcp_icache_access, // Instruction cache access from IFU to HPCP
  output           ifu_hpcp_icache_miss,   // Instruction cache miss from IFU to HPCP
  
  // IFU to MMU Interface
  output           ifu_mmu_abort,          // Abort signal from IFU to MMU
  output  [51 :0]  ifu_mmu_va,             // Virtual address from IFU to MMU
  output           ifu_mmu_va_vld,         // Virtual address valid from IFU to MMU
  
  // IU (Integer Unit) Outputs
  output  [8  :0]  iu_dtu_debug_info,      // Debug information from IU to DTU
  output           iu_hpcp_inst_bht_mispred, // BHT misprediction from IU to HPCP
  output           iu_hpcp_inst_condbr,    // Conditional branch instruction from IU to HPCP
  output           iu_hpcp_jump_8m,        // 8MB jump from IU to HPCP
  
  // LSU (Load/Store Unit) to BIU AXI Interface
  output  [39 :0]  lsu_biu_araddr,         // AXI read address from LSU to BIU
  output  [1  :0]  lsu_biu_arburst,        // AXI read burst type from LSU to BIU
  output  [3  :0]  lsu_biu_arcache,        // AXI read cache attributes from LSU to BIU
  output  [3  :0]  lsu_biu_arid,           // AXI read transaction ID from LSU to BIU
  output  [1  :0]  lsu_biu_arlen,          // AXI read burst length from LSU to BIU
  output  [2  :0]  lsu_biu_arprot,         // AXI read protection attributes from LSU to BIU
  output  [2  :0]  lsu_biu_arsize,         // AXI read transfer size from LSU to BIU
  output           lsu_biu_aruser,         // AXI read user signals from LSU to BIU
  output           lsu_biu_arvalid,        // AXI read address valid from LSU to BIU
  
  // LSU Store Buffer to BIU AXI Interface
  output  [39 :0]  lsu_biu_stb_awaddr,     // AXI write address from store buffer to BIU
  output  [1  :0]  lsu_biu_stb_awburst,    // AXI write burst type from store buffer to BIU
  output  [3  :0]  lsu_biu_stb_awcache,    // AXI write cache attributes from store buffer to BIU
  output  [1  :0]  lsu_biu_stb_awid,       // AXI write transaction ID from store buffer to BIU
  output  [1  :0]  lsu_biu_stb_awlen,      // AXI write burst length from store buffer to BIU
  output  [2  :0]  lsu_biu_stb_awprot,     // AXI write protection from store buffer to BIU
  output  [2  :0]  lsu_biu_stb_awsize,     // AXI write transfer size from store buffer to BIU
  output           lsu_biu_stb_awuser,     // AXI write user signals from store buffer to BIU
  output           lsu_biu_stb_awvalid,    // AXI write address valid from store buffer to BIU
  output  [127:0]  lsu_biu_stb_wdata,      // AXI write data from store buffer to BIU
  output           lsu_biu_stb_wlast,      // AXI write last from store buffer to BIU
  output  [15 :0]  lsu_biu_stb_wstrb,      // AXI write strobe from store buffer to BIU
  output           lsu_biu_stb_wvalid,     // AXI write data valid from store buffer to BIU
  
  // LSU Victim Buffer to BIU AXI Interface
  output  [39 :0]  lsu_biu_vb_awaddr,      // AXI write address from victim buffer to BIU
  output  [1  :0]  lsu_biu_vb_awburst,     // AXI write burst type from victim buffer to BIU
  output  [3  :0]  lsu_biu_vb_awcache,     // AXI write cache attributes from victim buffer to BIU
  output  [3  :0]  lsu_biu_vb_awid,        // AXI write transaction ID from victim buffer to BIU
  output  [1  :0]  lsu_biu_vb_awlen,       // AXI write burst length from victim buffer to BIU
  output  [2  :0]  lsu_biu_vb_awprot,      // AXI write protection from victim buffer to BIU
  output  [2  :0]  lsu_biu_vb_awsize,      // AXI write transfer size from victim buffer to BIU
  output           lsu_biu_vb_awvalid,     // AXI write address valid from victim buffer to BIU
  output  [127:0]  lsu_biu_vb_wdata,       // AXI write data from victim buffer to BIU
  output           lsu_biu_vb_wlast,       // AXI write last from victim buffer to BIU
  output  [15 :0]  lsu_biu_vb_wstrb,       // AXI write strobe from victim buffer to BIU
  output           lsu_biu_vb_wvalid,      // AXI write data valid from victim buffer to BIU
  
  // LSU Debug and Performance Monitoring Outputs
  output  [93 :0]  lsu_dtu_debug_info,     // Debug information from LSU to DTU
  output  [21 :0]  lsu_dtu_halt_info,      // Halt information from LSU to DTU
  output           lsu_dtu_last_check,     // Last check signal from LSU to DTU
  output  [39 :0]  lsu_dtu_ldst_addr,      // Load/store address from LSU to DTU
  output           lsu_dtu_ldst_addr_vld,  // Load/store address valid from LSU to DTU
  output  [15 :0]  lsu_dtu_ldst_bytes_vld, // Load/store bytes valid from LSU to DTU
  output  [63 :0]  lsu_dtu_ldst_data,      // Load/store data from LSU to DTU
  output           lsu_dtu_ldst_data_vld,  // Load/store data valid from LSU to DTU
  output  [1  :0]  lsu_dtu_ldst_type,      // Load/store type from LSU to DTU
  output  [2  :0]  lsu_dtu_mem_access_size, // Memory access size from LSU to DTU
  output           lsu_hpcp_cache_read_access, // Cache read access from LSU to HPCP
  output           lsu_hpcp_cache_read_miss,   // Cache read miss from LSU to HPCP
  output           lsu_hpcp_cache_write_access, // Cache write access from LSU to HPCP
  output           lsu_hpcp_cache_write_miss,  // Cache write miss from LSU to HPCP
  output           lsu_hpcp_inst_store,     // Store instruction from LSU to HPCP
  output           lsu_hpcp_unalign_inst,   // Unaligned instruction from LSU to HPCP
  
  // LSU to MMU Interface
  output           lsu_mmu_abort,          // Abort signal from LSU to MMU
  output           lsu_mmu_bus_error,      // Bus error from LSU to MMU
  output  [63 :0]  lsu_mmu_data,           // Data from LSU to MMU
  output           lsu_mmu_data_vld,       // Data valid from LSU to MMU
  output  [1  :0]  lsu_mmu_priv_mode,      // Privilege mode from LSU to MMU
  output           lsu_mmu_st_inst,        // Store instruction from LSU to MMU
  output  [51 :0]  lsu_mmu_va,             // Virtual address from LSU to MMU
  output           lsu_mmu_va_vld,         // Virtual address valid from LSU to MMU
  
  // RTU (Retire Unit) Outputs
  output           rtu_cpu_no_retire,      // No retire signal from RTU to CPU
  output  [14 :0]  rtu_dtu_debug_info,     // Debug information from RTU to DTU
  output  [63 :0]  rtu_dtu_dpc,            // Debug PC from RTU to DTU
  output           rtu_dtu_halt_ack,       // Halt acknowledge from RTU to DTU
  output           rtu_dtu_pending_ack,    // Pending acknowledge from RTU to DTU
  output           rtu_dtu_retire_chgflw,  // Retire change flow from RTU to DTU
  output           rtu_dtu_retire_debug_expt_vld, // Retire debug exception valid from RTU
  output  [21 :0]  rtu_dtu_retire_halt_info, // Retire halt information from RTU to DTU
  output           rtu_dtu_retire_mret,    // Retire machine return from RTU to DTU
  output  [39 :0]  rtu_dtu_retire_next_pc, // Retire next PC from RTU to DTU
  output           rtu_dtu_retire_sret,    // Retire supervisor return from RTU to DTU
  output           rtu_dtu_retire_vld,     // Retire valid from RTU to DTU
  output  [63 :0]  rtu_dtu_tval,           // Trap value from RTU to DTU
  output           rtu_hpcp_int_vld,       // Interrupt valid from RTU to HPCP
  output           rtu_hpcp_retire_inst_vld, // Retire instruction valid from RTU to HPCP
  output  [39 :0]  rtu_hpcp_retire_pc,     // Retire PC from RTU to HPCP
  output  [26 :0]  rtu_mmu_bad_vpn,        // Bad virtual page number from RTU to MMU
  output           rtu_mmu_expt_vld,       // Exception valid from RTU to MMU
  output           rtu_pad_halted,         // Halted signal from RTU to pad
  output           rtu_pad_retire,         // Retire signal from RTU to pad
  output  [39 :0]  rtu_pad_retire_pc,      // Retire PC from RTU to pad
  output           rtu_yy_xx_dbgon,        // Debug on signal from RTU
  output           rtu_yy_xx_expt_int,     // Exception interrupt from RTU
  output  [4  :0]  rtu_yy_xx_expt_vec,     // Exception vector from RTU
  output           rtu_yy_xx_expt_vld,     // Exception valid from RTU
  
  // VPU (Vector Processing Unit) Debug Outputs
  output  [7  :0]  vidu_dtu_debug_info,    // Debug information from VIDU to DTU
  output  [28 :0]  vpu_dtu_dbg_info        // Debug information from VPU to DTU
);

aq_ifu_top  x_aq_ifu_top (
  .biu_ifu_arready              (biu_ifu_arready             ),
  .biu_ifu_rdata                (biu_ifu_rdata               ),
  .biu_ifu_rid                  (biu_ifu_rid                 ),
  .biu_ifu_rlast                (biu_ifu_rlast               ),
  .biu_ifu_rresp                (biu_ifu_rresp               ),
  .biu_ifu_rvalid               (biu_ifu_rvalid              ),
  .cp0_ifu_bht_en               (cp0_ifu_bht_en              ),
  .cp0_ifu_bht_inv              (cp0_ifu_bht_inv             ),
  .cp0_ifu_btb_clr              (cp0_ifu_btb_clr             ),
  .cp0_ifu_btb_en               (cp0_ifu_btb_en              ),
  .cp0_ifu_icache_en            (cp0_ifu_icache_en           ),
  .cp0_ifu_icache_inv_addr      (cp0_ifu_icache_inv_addr     ),
  .cp0_ifu_icache_inv_req       (cp0_ifu_icache_inv_req      ),
  .cp0_ifu_icache_inv_type      (cp0_ifu_icache_inv_type     ),
  .cp0_ifu_icache_pref_en       (cp0_ifu_icache_pref_en      ),
  .cp0_ifu_icache_read_index    (cp0_ifu_icache_read_index   ),
  .cp0_ifu_icache_read_req      (cp0_ifu_icache_read_req     ),
  .cp0_ifu_icache_read_tag      (cp0_ifu_icache_read_tag     ),
  .cp0_ifu_icache_read_way      (cp0_ifu_icache_read_way     ),
  .cp0_ifu_icg_en               (cp0_ifu_icg_en              ),
  .cp0_ifu_in_lpmd              (cp0_ifu_in_lpmd             ),
  .cp0_ifu_iwpe                 (cp0_ifu_iwpe                ),
  .cp0_ifu_lpmd_req             (cp0_ifu_lpmd_req            ),
  .cp0_ifu_ras_en               (cp0_ifu_ras_en              ),
  .cp0_ifu_rst_inv_done         (cp0_ifu_rst_inv_done        ),
  .cp0_xx_mrvbr                 (cp0_xx_mrvbr                ),
  .cp0_yy_clk_en                (cp0_yy_clk_en               ),
  .cpurst_b                     (cpurst_b                    ),
  .dtu_ifu_debug_inst           (dtu_ifu_debug_inst          ),
  .dtu_ifu_debug_inst_vld       (dtu_ifu_debug_inst_vld      ),
  .dtu_ifu_halt_info0           (dtu_ifu_halt_info0          ),
  .dtu_ifu_halt_info1           (dtu_ifu_halt_info1          ),
  .dtu_ifu_halt_info_vld        (dtu_ifu_halt_info_vld       ),
  .dtu_ifu_halt_on_reset        (dtu_ifu_halt_on_reset       ),
  .forever_cpuclk               (forever_cpuclk              ),
  .hpcp_ifu_cnt_en              (hpcp_ifu_cnt_en             ),
  .idu_ifu_id_stall             (idu_ifu_id_stall            ),
  .ifu_biu_araddr               (ifu_biu_araddr              ),
  .ifu_biu_arburst              (ifu_biu_arburst             ),
  .ifu_biu_arcache              (ifu_biu_arcache             ),
  .ifu_biu_arid                 (ifu_biu_arid                ),
  .ifu_biu_arlen                (ifu_biu_arlen               ),
  .ifu_biu_arprot               (ifu_biu_arprot              ),
  .ifu_biu_arsize               (ifu_biu_arsize              ),
  .ifu_biu_arvalid              (ifu_biu_arvalid             ),
  .ifu_cp0_bht_inv_done         (ifu_cp0_bht_inv_done        ),
  .ifu_cp0_icache_inv_done      (ifu_cp0_icache_inv_done     ),
  .ifu_cp0_icache_read_data     (ifu_cp0_icache_read_data    ),
  .ifu_cp0_icache_read_data_vld (ifu_cp0_icache_read_data_vld),
  .ifu_cp0_rst_inv_req          (ifu_cp0_rst_inv_req         ),
  .ifu_cp0_warm_up              (ifu_cp0_warm_up             ),
  .ifu_dtu_addr_vld0            (ifu_dtu_addr_vld0           ),
  .ifu_dtu_addr_vld1            (ifu_dtu_addr_vld1           ),
  .ifu_dtu_data_vld0            (ifu_dtu_data_vld0           ),
  .ifu_dtu_data_vld1            (ifu_dtu_data_vld1           ),
  .ifu_dtu_debug_info           (ifu_dtu_debug_info          ),
  .ifu_dtu_exe_addr0            (ifu_dtu_exe_addr0           ),
  .ifu_dtu_exe_addr1            (ifu_dtu_exe_addr1           ),
  .ifu_dtu_exe_data0            (ifu_dtu_exe_data0           ),
  .ifu_dtu_exe_data1            (ifu_dtu_exe_data1           ),
  .ifu_hpcp_icache_access       (ifu_hpcp_icache_access      ),
  .ifu_hpcp_icache_miss         (ifu_hpcp_icache_miss        ),
  .ifu_idu_id_bht_pred          (ifu_idu_id_bht_pred         ),
  .ifu_idu_id_expt_acc_error    (ifu_idu_id_expt_acc_error   ),
  .ifu_idu_id_expt_high         (ifu_idu_id_expt_high        ),
  .ifu_idu_id_expt_page_fault   (ifu_idu_id_expt_page_fault  ),
  .ifu_idu_id_halt_info         (ifu_idu_id_halt_info        ),
  .ifu_idu_id_inst              (ifu_idu_id_inst             ),
  .ifu_idu_id_inst_vld          (ifu_idu_id_inst_vld         ),
  .ifu_idu_warm_up              (ifu_idu_warm_up             ),
  .ifu_iu_chgflw_pc             (ifu_iu_chgflw_pc            ),
  .ifu_iu_chgflw_vld            (ifu_iu_chgflw_vld           ),
  .ifu_iu_ex1_pc_pred           (ifu_iu_ex1_pc_pred          ),
  .ifu_iu_reset_vld             (ifu_iu_reset_vld            ),
  .ifu_iu_warm_up               (ifu_iu_warm_up              ),
  .ifu_lsu_warm_up              (ifu_lsu_warm_up             ),
  .ifu_mmu_abort                (ifu_mmu_abort               ),
  .ifu_mmu_va                   (ifu_mmu_va                  ),
  .ifu_mmu_va_vld               (ifu_mmu_va_vld              ),
  .ifu_rtu_reset_halt_req       (ifu_rtu_reset_halt_req      ),
  .ifu_rtu_warm_up              (ifu_rtu_warm_up             ),
  .ifu_vidu_warm_up             (ifu_vidu_warm_up            ),
  .ifu_vpu_warm_up              (ifu_vpu_warm_up             ),
  .ifu_yy_xx_no_op              (ifu_yy_xx_no_op             ),
  .iu_ifu_bht_cur_pc            (iu_ifu_bht_cur_pc           ),
  .iu_ifu_bht_mispred           (iu_ifu_bht_mispred          ),
  .iu_ifu_bht_mispred_gate      (iu_ifu_bht_mispred_gate     ),
  .iu_ifu_bht_pred              (iu_ifu_bht_pred             ),
  .iu_ifu_bht_taken             (iu_ifu_bht_taken            ),
  .iu_ifu_br_vld                (iu_ifu_br_vld               ),
  .iu_ifu_br_vld_gate           (iu_ifu_br_vld_gate          ),
  .iu_ifu_link_vld              (iu_ifu_link_vld             ),
  .iu_ifu_link_vld_gate         (iu_ifu_link_vld_gate        ),
  .iu_ifu_pc_mispred            (iu_ifu_pc_mispred           ),
  .iu_ifu_pc_mispred_gate       (iu_ifu_pc_mispred_gate      ),
  .iu_ifu_ret_vld               (iu_ifu_ret_vld              ),
  .iu_ifu_ret_vld_gate          (iu_ifu_ret_vld_gate         ),
  .iu_ifu_tar_pc                (iu_ifu_tar_pc               ),
  .iu_ifu_tar_pc_vld            (iu_ifu_tar_pc_vld           ),
  .iu_ifu_tar_pc_vld_gate       (iu_ifu_tar_pc_vld_gate      ),
  .mmu_ifu_access_fault         (mmu_ifu_access_fault        ),
  .mmu_ifu_pa                   (mmu_ifu_pa                  ),
  .mmu_ifu_pa_vld               (mmu_ifu_pa_vld              ),
  .mmu_ifu_prot                 (mmu_ifu_prot                ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .rtu_ifu_chgflw_pc            (rtu_ifu_chgflw_pc           ),
  .rtu_ifu_chgflw_vld           (rtu_ifu_chgflw_vld          ),
  .rtu_ifu_dbg_mask             (rtu_ifu_dbg_mask            ),
  .rtu_ifu_flush_fe             (rtu_ifu_flush_fe            ),
  .rtu_yy_xx_dbgon              (rtu_yy_xx_dbgon             )
);


aq_idu_top  x_aq_idu_top (
  .cp0_idu_cskyee               (cp0_idu_cskyee              ),
  .cp0_idu_dis_fence_in_dbg     (cp0_idu_dis_fence_in_dbg    ),
  .cp0_idu_frm                  (cp0_idu_frm                 ),
  .cp0_idu_fs                   (cp0_idu_fs                  ),
  .cp0_idu_icg_en               (cp0_idu_icg_en              ),
  .cp0_idu_issue_stall          (cp0_idu_issue_stall         ),
  .cp0_idu_ucme                 (cp0_idu_ucme                ),
  .cp0_idu_vill                 (cp0_idu_vill                ),
  .cp0_idu_vl_zero              (cp0_idu_vl_zero             ),
  .cp0_idu_vlmul                (cp0_idu_vlmul               ),
  .cp0_idu_vs                   (cp0_idu_vs                  ),
  .cp0_idu_vsetvl_dis_stall     (cp0_idu_vsetvl_dis_stall    ),
  .cp0_idu_vsew                 (cp0_idu_vsew                ),
  .cp0_idu_vstart               (cp0_idu_vstart              ),
  .cp0_yy_clk_en                (cp0_yy_clk_en               ),
  .cp0_yy_priv_mode             (cp0_yy_priv_mode            ),
  .cpurst_b                     (cpurst_b                    ),
  .forever_cpuclk               (forever_cpuclk              ),
  .hpcp_idu_cnt_en              (hpcp_idu_cnt_en             ),
  .idu_alu_ex1_gateclk_sel      (idu_alu_ex1_gateclk_sel     ),
  .idu_bju_ex1_gateclk_sel      (idu_bju_ex1_gateclk_sel     ),
  .idu_cp0_ex1_dp_sel           (idu_cp0_ex1_dp_sel          ),
  .idu_cp0_ex1_dst0_reg         (idu_cp0_ex1_dst0_reg        ),
  .idu_cp0_ex1_expt_acc_error   (idu_cp0_ex1_expt_acc_error  ),
  .idu_cp0_ex1_expt_high        (idu_cp0_ex1_expt_high       ),
  .idu_cp0_ex1_expt_illegal     (idu_cp0_ex1_expt_illegal    ),
  .idu_cp0_ex1_expt_page_fault  (idu_cp0_ex1_expt_page_fault ),
  .idu_cp0_ex1_func             (idu_cp0_ex1_func            ),
  .idu_cp0_ex1_gateclk_sel      (idu_cp0_ex1_gateclk_sel     ),
  .idu_cp0_ex1_halt_info        (idu_cp0_ex1_halt_info       ),
  .idu_cp0_ex1_length           (idu_cp0_ex1_length          ),
  .idu_cp0_ex1_opcode           (idu_cp0_ex1_opcode          ),
  .idu_cp0_ex1_sel              (idu_cp0_ex1_sel             ),
  .idu_cp0_ex1_split            (idu_cp0_ex1_split           ),
  .idu_cp0_ex1_src0_data        (idu_cp0_ex1_src0_data       ),
  .idu_cp0_ex1_src1_data        (idu_cp0_ex1_src1_data       ),
  .idu_div_ex1_gateclk_sel      (idu_div_ex1_gateclk_sel     ),
  .idu_dtu_debug_info           (idu_dtu_debug_info          ),
  .idu_hpcp_backend_stall       (idu_hpcp_backend_stall      ),
  .idu_hpcp_frontend_stall      (idu_hpcp_frontend_stall     ),
  .idu_hpcp_inst_type           (idu_hpcp_inst_type          ),
  .idu_ifu_id_stall             (idu_ifu_id_stall            ),
  .idu_iu_ex1_alu_dp_sel        (idu_iu_ex1_alu_dp_sel       ),
  .idu_iu_ex1_alu_sel           (idu_iu_ex1_alu_sel          ),
  .idu_iu_ex1_bht_pred          (idu_iu_ex1_bht_pred         ),
  .idu_iu_ex1_bju_br_sel        (idu_iu_ex1_bju_br_sel       ),
  .idu_iu_ex1_bju_dp_sel        (idu_iu_ex1_bju_dp_sel       ),
  .idu_iu_ex1_bju_sel           (idu_iu_ex1_bju_sel          ),
  .idu_iu_ex1_div_dp_sel        (idu_iu_ex1_div_dp_sel       ),
  .idu_iu_ex1_div_sel           (idu_iu_ex1_div_sel          ),
  .idu_iu_ex1_dst0_reg          (idu_iu_ex1_dst0_reg         ),
  .idu_iu_ex1_func              (idu_iu_ex1_func             ),
  .idu_iu_ex1_inst_vld          (idu_iu_ex1_inst_vld         ),
  .idu_iu_ex1_length            (idu_iu_ex1_length           ),
  .idu_iu_ex1_mult_dp_sel       (idu_iu_ex1_mult_dp_sel      ),
  .idu_iu_ex1_mult_sel          (idu_iu_ex1_mult_sel         ),
  .idu_iu_ex1_pipedown_vld      (idu_iu_ex1_pipedown_vld     ),
  .idu_iu_ex1_split             (idu_iu_ex1_split            ),
  .idu_iu_ex1_src0_data         (idu_iu_ex1_src0_data        ),
  .idu_iu_ex1_src0_ready        (idu_iu_ex1_src0_ready       ),
  .idu_iu_ex1_src0_reg          (idu_iu_ex1_src0_reg         ),
  .idu_iu_ex1_src1_data         (idu_iu_ex1_src1_data        ),
  .idu_iu_ex1_src1_ready        (idu_iu_ex1_src1_ready       ),
  .idu_iu_ex1_src1_reg          (idu_iu_ex1_src1_reg         ),
  .idu_iu_ex1_src2_data         (idu_iu_ex1_src2_data        ),
  .idu_lsu_ex1_dp_sel           (idu_lsu_ex1_dp_sel          ),
  .idu_lsu_ex1_dst0_reg         (idu_lsu_ex1_dst0_reg        ),
  .idu_lsu_ex1_dst1_reg         (idu_lsu_ex1_dst1_reg        ),
  .idu_lsu_ex1_func             (idu_lsu_ex1_func            ),
  .idu_lsu_ex1_gateclk_sel      (idu_lsu_ex1_gateclk_sel     ),
  .idu_lsu_ex1_halt_info        (idu_lsu_ex1_halt_info       ),
  .idu_lsu_ex1_length           (idu_lsu_ex1_length          ),
  .idu_lsu_ex1_sel              (idu_lsu_ex1_sel             ),
  .idu_lsu_ex1_split            (idu_lsu_ex1_split           ),
  .idu_lsu_ex1_src0_data        (idu_lsu_ex1_src0_data       ),
  .idu_lsu_ex1_src1_data        (idu_lsu_ex1_src1_data       ),
  .idu_lsu_ex1_src2_data        (idu_lsu_ex1_src2_data       ),
  .idu_lsu_ex1_src2_ready       (idu_lsu_ex1_src2_ready      ),
  .idu_lsu_ex1_src2_reg         (idu_lsu_ex1_src2_reg        ),
  .idu_lsu_ex1_vlmul            (idu_lsu_ex1_vlmul           ),
  .idu_lsu_ex1_vsew             (idu_lsu_ex1_vsew            ),
  .idu_mult_ex1_gateclk_sel     (idu_mult_ex1_gateclk_sel    ),
  .idu_vidu_ex1_fp_dp_sel       (idu_vidu_ex1_fp_dp_sel      ),
  .idu_vidu_ex1_fp_gateclk_sel  (idu_vidu_ex1_fp_gateclk_sel ),
  .idu_vidu_ex1_fp_sel          (idu_vidu_ex1_fp_sel         ),
  .idu_vidu_ex1_inst_data       (idu_vidu_ex1_inst_data      ),
  .idu_vidu_ex1_vec_dp_sel      (idu_vidu_ex1_vec_dp_sel     ),
  .idu_vidu_ex1_vec_gateclk_sel (idu_vidu_ex1_vec_gateclk_sel),
  .idu_vidu_ex1_vec_sel         (idu_vidu_ex1_vec_sel        ),
  .ifu_idu_id_bht_pred          (ifu_idu_id_bht_pred         ),
  .ifu_idu_id_expt_acc_error    (ifu_idu_id_expt_acc_error   ),
  .ifu_idu_id_expt_high         (ifu_idu_id_expt_high        ),
  .ifu_idu_id_expt_page_fault   (ifu_idu_id_expt_page_fault  ),
  .ifu_idu_id_halt_info         (ifu_idu_id_halt_info        ),
  .ifu_idu_id_inst              (ifu_idu_id_inst             ),
  .ifu_idu_id_inst_vld          (ifu_idu_id_inst_vld         ),
  .ifu_idu_warm_up              (ifu_idu_warm_up             ),
  .iu_idu_bju_full              (iu_idu_bju_full             ),
  .iu_idu_bju_global_full       (iu_idu_bju_global_full      ),
  .iu_idu_div_full              (iu_idu_div_full             ),
  .iu_idu_mult_full             (iu_idu_mult_full            ),
  .iu_idu_mult_issue_stall      (iu_idu_mult_issue_stall     ),
  .iu_yy_xx_cancel              (iu_yy_xx_cancel             ),
  .lsu_idu_full                 (lsu_idu_full                ),
  .lsu_idu_global_full          (lsu_idu_global_full         ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .rtu_idu_commit               (rtu_idu_commit              ),
  .rtu_idu_commit_for_bju       (rtu_idu_commit_for_bju      ),
  .rtu_idu_flush_fe             (rtu_idu_flush_fe            ),
  .rtu_idu_flush_stall          (rtu_idu_flush_stall         ),
  .rtu_idu_flush_wbt            (rtu_idu_flush_wbt           ),
  .rtu_idu_fwd0_data            (rtu_idu_fwd0_data           ),
  .rtu_idu_fwd0_reg             (rtu_idu_fwd0_reg            ),
  .rtu_idu_fwd0_vld             (rtu_idu_fwd0_vld            ),
  .rtu_idu_fwd1_data            (rtu_idu_fwd1_data           ),
  .rtu_idu_fwd1_reg             (rtu_idu_fwd1_reg            ),
  .rtu_idu_fwd1_vld             (rtu_idu_fwd1_vld            ),
  .rtu_idu_fwd2_data            (rtu_idu_fwd2_data           ),
  .rtu_idu_fwd2_reg             (rtu_idu_fwd2_reg            ),
  .rtu_idu_fwd2_vld             (rtu_idu_fwd2_vld            ),
  .rtu_idu_pipeline_empty       (rtu_idu_pipeline_empty      ),
  .rtu_idu_wb0_data             (rtu_idu_wb0_data            ),
  .rtu_idu_wb0_reg              (rtu_idu_wb0_reg             ),
  .rtu_idu_wb0_vld              (rtu_idu_wb0_vld             ),
  .rtu_idu_wb1_data             (rtu_idu_wb1_data            ),
  .rtu_idu_wb1_reg              (rtu_idu_wb1_reg             ),
  .rtu_idu_wb1_vld              (rtu_idu_wb1_vld             ),
  .rtu_yy_xx_dbgon              (rtu_yy_xx_dbgon             ),
  .vidu_idu_fp_full             (vidu_idu_fp_full            ),
  .vidu_idu_vec_full            (vidu_idu_vec_full           )
);

aq_vidu_top  x_aq_vidu_top (
  .cp0_idu_icg_en                   (cp0_idu_icg_en                  ),
  .cp0_yy_clk_en                    (cp0_yy_clk_en                   ),
  .cpurst_b                         (cpurst_b                        ),
  .forever_cpuclk                   (forever_cpuclk                  ),
  .idu_vidu_ex1_fp_dp_sel           (idu_vidu_ex1_fp_dp_sel          ),
  .idu_vidu_ex1_fp_gateclk_sel      (idu_vidu_ex1_fp_gateclk_sel     ),
  .idu_vidu_ex1_fp_sel              (idu_vidu_ex1_fp_sel             ),
  .idu_vidu_ex1_inst_data           (idu_vidu_ex1_inst_data          ),
  .idu_vidu_ex1_vec_dp_sel          (idu_vidu_ex1_vec_dp_sel         ),
  .idu_vidu_ex1_vec_gateclk_sel     (idu_vidu_ex1_vec_gateclk_sel    ),
  .idu_vidu_ex1_vec_sel             (idu_vidu_ex1_vec_sel            ),
  .ifu_vidu_warm_up                 (ifu_vidu_warm_up                ),
  .pad_yy_icg_scan_en               (pad_yy_icg_scan_en              ),
  .rtu_vidu_flush_wbt               (rtu_vidu_flush_wbt              ),
  .rtu_yy_xx_async_flush            (rtu_yy_xx_async_flush           ),
  .vidu_cp0_vid_fof_vld             (vidu_cp0_vid_fof_vld            ),
  .vidu_dtu_debug_info              (vidu_dtu_debug_info             ),
  .vidu_idu_fp_full                 (vidu_idu_fp_full                ),
  .vidu_idu_vec_full                (vidu_idu_vec_full               ),
  .vidu_rtu_no_op                   (vidu_rtu_no_op                  ),
  .vidu_vpu_vid_fp_inst_dp_vld      (vidu_vpu_vid_fp_inst_dp_vld     ),
  .vidu_vpu_vid_fp_inst_dst_reg     (vidu_vpu_vid_fp_inst_dst_reg    ),
  .vidu_vpu_vid_fp_inst_dst_vld     (vidu_vpu_vid_fp_inst_dst_vld    ),
  .vidu_vpu_vid_fp_inst_dste_vld    (vidu_vpu_vid_fp_inst_dste_vld   ),
  .vidu_vpu_vid_fp_inst_dstf_reg    (vidu_vpu_vid_fp_inst_dstf_reg   ),
  .vidu_vpu_vid_fp_inst_dstf_vld    (vidu_vpu_vid_fp_inst_dstf_vld   ),
  .vidu_vpu_vid_fp_inst_eu          (vidu_vpu_vid_fp_inst_eu         ),
  .vidu_vpu_vid_fp_inst_func        (vidu_vpu_vid_fp_inst_func       ),
  .vidu_vpu_vid_fp_inst_gateclk_vld (vidu_vpu_vid_fp_inst_gateclk_vld),
  .vidu_vpu_vid_fp_inst_src1_data   (vidu_vpu_vid_fp_inst_src1_data  ),
  .vidu_vpu_vid_fp_inst_srcf0_data  (vidu_vpu_vid_fp_inst_srcf0_data ),
  .vidu_vpu_vid_fp_inst_srcf1_data  (vidu_vpu_vid_fp_inst_srcf1_data ),
  .vidu_vpu_vid_fp_inst_srcf2_data  (vidu_vpu_vid_fp_inst_srcf2_data ),
  .vidu_vpu_vid_fp_inst_srcf2_rdy   (vidu_vpu_vid_fp_inst_srcf2_rdy  ),
  .vidu_vpu_vid_fp_inst_srcf2_vld   (vidu_vpu_vid_fp_inst_srcf2_vld  ),
  .vidu_vpu_vid_fp_inst_vld         (vidu_vpu_vid_fp_inst_vld        ),
  .vpu_rtu_ex1_cmplt                (vpu_rtu_ex1_cmplt               ),
  .vpu_rtu_ex1_cmplt_dp             (vpu_rtu_ex1_cmplt_dp            ),
  .vpu_rtu_ex1_fp_dirty             (vpu_rtu_ex1_fp_dirty            ),
  .vpu_rtu_ex1_vec_dirty            (vpu_rtu_ex1_vec_dirty           ),
  .vpu_vidu_fp_fwd_data             (vpu_vidu_fp_fwd_data            ),
  .vpu_vidu_fp_fwd_reg              (vpu_vidu_fp_fwd_reg             ),
  .vpu_vidu_fp_fwd_vld              (vpu_vidu_fp_fwd_vld             ),
  .vpu_vidu_fp_wb_data              (vpu_vidu_fp_wb_data             ),
  .vpu_vidu_fp_wb_reg               (vpu_vidu_fp_wb_reg              ),
  .vpu_vidu_fp_wb_vld               (vpu_vidu_fp_wb_vld              ),
  .vpu_vidu_vex1_fp_stall           (vpu_vidu_vex1_fp_stall          ),
  .vpu_vidu_wbt_fp_wb0_reg          (vpu_vidu_wbt_fp_wb0_reg         ),
  .vpu_vidu_wbt_fp_wb0_vld          (vpu_vidu_wbt_fp_wb0_vld         ),
  .vpu_vidu_wbt_fp_wb1_reg          (vpu_vidu_wbt_fp_wb1_reg         ),
  .vpu_vidu_wbt_fp_wb1_vld          (vpu_vidu_wbt_fp_wb1_vld         )
);

aq_iu_top  x_aq_iu_top (
  .cp0_iu_icg_en                (cp0_iu_icg_en               ),
  .cp0_xx_mrvbr                 (cp0_xx_mrvbr                ),
  .cp0_yy_clk_en                (cp0_yy_clk_en               ),
  .cpurst_b                     (cpurst_b                    ),
  .da_xx_fwd_data               (da_xx_fwd_data              ),
  .da_xx_fwd_dst_reg            (da_xx_fwd_dst_reg           ),
  .da_xx_fwd_vld                (da_xx_fwd_vld               ),
  .forever_cpuclk               (forever_cpuclk              ),
  .hpcp_iu_cnt_en               (hpcp_iu_cnt_en              ),
  .idu_alu_ex1_gateclk_sel      (idu_alu_ex1_gateclk_sel     ),
  .idu_bju_ex1_gateclk_sel      (idu_bju_ex1_gateclk_sel     ),
  .idu_div_ex1_gateclk_sel      (idu_div_ex1_gateclk_sel     ),
  .idu_iu_ex1_alu_dp_sel        (idu_iu_ex1_alu_dp_sel       ),
  .idu_iu_ex1_alu_sel           (idu_iu_ex1_alu_sel          ),
  .idu_iu_ex1_bht_pred          (idu_iu_ex1_bht_pred         ),
  .idu_iu_ex1_bju_br_sel        (idu_iu_ex1_bju_br_sel       ),
  .idu_iu_ex1_bju_dp_sel        (idu_iu_ex1_bju_dp_sel       ),
  .idu_iu_ex1_bju_sel           (idu_iu_ex1_bju_sel          ),
  .idu_iu_ex1_div_dp_sel        (idu_iu_ex1_div_dp_sel       ),
  .idu_iu_ex1_div_sel           (idu_iu_ex1_div_sel          ),
  .idu_iu_ex1_dst0_reg          (idu_iu_ex1_dst0_reg         ),
  .idu_iu_ex1_func              (idu_iu_ex1_func             ),
  .idu_iu_ex1_inst_vld          (idu_iu_ex1_inst_vld         ),
  .idu_iu_ex1_length            (idu_iu_ex1_length           ),
  .idu_iu_ex1_mult_dp_sel       (idu_iu_ex1_mult_dp_sel      ),
  .idu_iu_ex1_mult_sel          (idu_iu_ex1_mult_sel         ),
  .idu_iu_ex1_pipedown_vld      (idu_iu_ex1_pipedown_vld     ),
  .idu_iu_ex1_split             (idu_iu_ex1_split            ),
  .idu_iu_ex1_src0_data         (idu_iu_ex1_src0_data        ),
  .idu_iu_ex1_src0_ready        (idu_iu_ex1_src0_ready       ),
  .idu_iu_ex1_src0_reg          (idu_iu_ex1_src0_reg         ),
  .idu_iu_ex1_src1_data         (idu_iu_ex1_src1_data        ),
  .idu_iu_ex1_src1_ready        (idu_iu_ex1_src1_ready       ),
  .idu_iu_ex1_src1_reg          (idu_iu_ex1_src1_reg         ),
  .idu_iu_ex1_src2_data         (idu_iu_ex1_src2_data        ),
  .idu_mult_ex1_gateclk_sel     (idu_mult_ex1_gateclk_sel    ),
  .ifu_iu_chgflw_pc             (ifu_iu_chgflw_pc            ),
  .ifu_iu_chgflw_vld            (ifu_iu_chgflw_vld           ),
  .ifu_iu_ex1_pc_pred           (ifu_iu_ex1_pc_pred          ),
  .ifu_iu_reset_vld             (ifu_iu_reset_vld            ),
  .ifu_iu_warm_up               (ifu_iu_warm_up              ),
  .iu_cp0_ex1_cur_pc            (iu_cp0_ex1_cur_pc           ),
  .iu_dtu_debug_info            (iu_dtu_debug_info           ),
  .iu_hpcp_inst_bht_mispred     (iu_hpcp_inst_bht_mispred    ),
  .iu_hpcp_inst_condbr          (iu_hpcp_inst_condbr         ),
  .iu_hpcp_jump_8m              (iu_hpcp_jump_8m             ),
  .iu_idu_bju_full              (iu_idu_bju_full             ),
  .iu_idu_bju_global_full       (iu_idu_bju_global_full      ),
  .iu_idu_div_full              (iu_idu_div_full             ),
  .iu_idu_mult_full             (iu_idu_mult_full            ),
  .iu_idu_mult_issue_stall      (iu_idu_mult_issue_stall     ),
  .iu_ifu_bht_cur_pc            (iu_ifu_bht_cur_pc           ),
  .iu_ifu_bht_mispred           (iu_ifu_bht_mispred          ),
  .iu_ifu_bht_mispred_gate      (iu_ifu_bht_mispred_gate     ),
  .iu_ifu_bht_pred              (iu_ifu_bht_pred             ),
  .iu_ifu_bht_taken             (iu_ifu_bht_taken            ),
  .iu_ifu_br_vld                (iu_ifu_br_vld               ),
  .iu_ifu_br_vld_gate           (iu_ifu_br_vld_gate          ),
  .iu_ifu_link_vld              (iu_ifu_link_vld             ),
  .iu_ifu_link_vld_gate         (iu_ifu_link_vld_gate        ),
  .iu_ifu_pc_mispred            (iu_ifu_pc_mispred           ),
  .iu_ifu_pc_mispred_gate       (iu_ifu_pc_mispred_gate      ),
  .iu_ifu_ret_vld               (iu_ifu_ret_vld              ),
  .iu_ifu_ret_vld_gate          (iu_ifu_ret_vld_gate         ),
  .iu_ifu_tar_pc                (iu_ifu_tar_pc               ),
  .iu_ifu_tar_pc_vld            (iu_ifu_tar_pc_vld           ),
  .iu_ifu_tar_pc_vld_gate       (iu_ifu_tar_pc_vld_gate      ),
  .iu_lsu_ex1_cur_pc            (iu_lsu_ex1_cur_pc           ),
  .iu_rtu_depd_lsu_chgflow_vld  (iu_rtu_depd_lsu_chgflow_vld ),
  .iu_rtu_depd_lsu_next_pc      (iu_rtu_depd_lsu_next_pc     ),
  .iu_rtu_div_data              (iu_rtu_div_data             ),
  .iu_rtu_div_preg              (iu_rtu_div_preg             ),
  .iu_rtu_div_wb_dp             (iu_rtu_div_wb_dp            ),
  .iu_rtu_div_wb_vld            (iu_rtu_div_wb_vld           ),
  .iu_rtu_ex1_alu_cmplt         (iu_rtu_ex1_alu_cmplt        ),
  .iu_rtu_ex1_alu_cmplt_dp      (iu_rtu_ex1_alu_cmplt_dp     ),
  .iu_rtu_ex1_alu_data          (iu_rtu_ex1_alu_data         ),
  .iu_rtu_ex1_alu_inst_len      (iu_rtu_ex1_alu_inst_len     ),
  .iu_rtu_ex1_alu_inst_split    (iu_rtu_ex1_alu_inst_split   ),
  .iu_rtu_ex1_alu_preg          (iu_rtu_ex1_alu_preg         ),
  .iu_rtu_ex1_alu_wb_dp         (iu_rtu_ex1_alu_wb_dp        ),
  .iu_rtu_ex1_alu_wb_vld        (iu_rtu_ex1_alu_wb_vld       ),
  .iu_rtu_ex1_bju_cmplt         (iu_rtu_ex1_bju_cmplt        ),
  .iu_rtu_ex1_bju_cmplt_dp      (iu_rtu_ex1_bju_cmplt_dp     ),
  .iu_rtu_ex1_bju_data          (iu_rtu_ex1_bju_data         ),
  .iu_rtu_ex1_bju_inst_len      (iu_rtu_ex1_bju_inst_len     ),
  .iu_rtu_ex1_bju_preg          (iu_rtu_ex1_bju_preg         ),
  .iu_rtu_ex1_bju_wb_dp         (iu_rtu_ex1_bju_wb_dp        ),
  .iu_rtu_ex1_bju_wb_vld        (iu_rtu_ex1_bju_wb_vld       ),
  .iu_rtu_ex1_branch_inst       (iu_rtu_ex1_branch_inst      ),
  .iu_rtu_ex1_cur_pc            (iu_rtu_ex1_cur_pc           ),
  .iu_rtu_ex1_div_cmplt         (iu_rtu_ex1_div_cmplt        ),
  .iu_rtu_ex1_div_cmplt_dp      (iu_rtu_ex1_div_cmplt_dp     ),
  .iu_rtu_ex1_mul_cmplt         (iu_rtu_ex1_mul_cmplt        ),
  .iu_rtu_ex1_mul_cmplt_dp      (iu_rtu_ex1_mul_cmplt_dp     ),
  .iu_rtu_ex1_next_pc           (iu_rtu_ex1_next_pc          ),
  .iu_rtu_ex2_bju_ras_mispred   (iu_rtu_ex2_bju_ras_mispred  ),
  .iu_rtu_ex3_mul_data          (iu_rtu_ex3_mul_data         ),
  .iu_rtu_ex3_mul_preg          (iu_rtu_ex3_mul_preg         ),
  .iu_rtu_ex3_mul_wb_vld        (iu_rtu_ex3_mul_wb_vld       ),
  .iu_xx_no_op                  (iu_xx_no_op                 ),
  .iu_yy_xx_cancel              (iu_yy_xx_cancel             ),
  .lsu_iu_ex2_data              (lsu_iu_ex2_data             ),
  .lsu_iu_ex2_data_vld          (lsu_iu_ex2_data_vld         ),
  .lsu_iu_ex2_dest_reg          (lsu_iu_ex2_dest_reg         ),
  .mmu_xx_mmu_en                (mmu_xx_mmu_en               ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .rtu_iu_div_wb_grant          (rtu_iu_div_wb_grant         ),
  .rtu_iu_div_wb_grant_for_full (rtu_iu_div_wb_grant_for_full),
  .rtu_iu_ex1_cmplt             (rtu_iu_ex1_cmplt            ),
  .rtu_iu_ex1_cmplt_dp          (rtu_iu_ex1_cmplt_dp         ),
  .rtu_iu_ex1_inst_len          (rtu_iu_ex1_inst_len         ),
  .rtu_iu_ex1_inst_split        (rtu_iu_ex1_inst_split       ),
  .rtu_iu_ex2_cur_pc            (rtu_iu_ex2_cur_pc           ),
  .rtu_iu_ex2_next_pc           (rtu_iu_ex2_next_pc          ),
  .rtu_iu_mul_wb_grant          (rtu_iu_mul_wb_grant         ),
  .rtu_iu_mul_wb_grant_for_full (rtu_iu_mul_wb_grant_for_full),
  .rtu_yy_xx_flush_fe           (rtu_yy_xx_flush_fe          )
);

aq_vpu_top  x_aq_vpu_top (
  .cp0_vpu_icg_en                   (cp0_vpu_icg_en                  ),
  .cp0_vpu_xx_bf16                  (cp0_vpu_xx_bf16                 ),
  .cp0_vpu_xx_dqnan                 (cp0_vpu_xx_dqnan                ),
  .cp0_vpu_xx_rm                    (cp0_vpu_xx_rm                   ),
  .cp0_yy_clk_en                    (cp0_yy_clk_en                   ),
  .cpurst_b                         (cpurst_b                        ),
  .forever_cpuclk                   (forever_cpuclk                  ),
  .ifu_vpu_warm_up                  (ifu_vpu_warm_up                 ),
  .lsu_vlsu_bytes_vld               (lsu_vlsu_bytes_vld              ),
  .lsu_vlsu_data                    (lsu_vlsu_data                   ),
  .lsu_vlsu_data_grant              (lsu_vlsu_data_grant             ),
  .lsu_vlsu_data_vld                (lsu_vlsu_data_vld               ),
  .lsu_vlsu_dc_create_vld           (lsu_vlsu_dc_create_vld          ),
  .lsu_vlsu_dc_fld_req              (lsu_vlsu_dc_fld_req             ),
  .lsu_vlsu_dc_fof                  (lsu_vlsu_dc_fof                 ),
  .lsu_vlsu_dc_nf                   (lsu_vlsu_dc_nf                  ),
  .lsu_vlsu_dc_sew                  (lsu_vlsu_dc_sew                 ),
  .lsu_vlsu_dc_split_cnt            (lsu_vlsu_dc_split_cnt           ),
  .lsu_vlsu_dc_sseg_first           (lsu_vlsu_dc_sseg_first          ),
  .lsu_vlsu_dc_stall                (lsu_vlsu_dc_stall               ),
  .lsu_vlsu_dest_reg                (lsu_vlsu_dest_reg               ),
  .lsu_vlsu_expt_vld                (lsu_vlsu_expt_vld               ),
  .lsu_vlsu_func                    (lsu_vlsu_func                   ),
  .lsu_vlsu_sew                     (lsu_vlsu_sew                    ),
  .lsu_vlsu_split_last              (lsu_vlsu_split_last             ),
  .lsu_vlsu_st_expt                 (lsu_vlsu_st_expt                ),
  .lsu_vlsu_st_offset               (lsu_vlsu_st_offset              ),
  .lsu_vlsu_st_sew                  (lsu_vlsu_st_sew                 ),
  .lsu_vlsu_st_size                 (lsu_vlsu_st_size                ),
  .lsu_vlsu_vl_update               (lsu_vlsu_vl_update              ),
  .lsu_vlsu_vl_upval                (lsu_vlsu_vl_upval               ),
  .pad_yy_icg_scan_en               (pad_yy_icg_scan_en              ),
  .rtu_vpu_gpr_wb_grnt              (rtu_vpu_gpr_wb_grnt             ),
  .rtu_yy_xx_async_flush            (rtu_yy_xx_async_flush           ),
  .rtu_yy_xx_flush                  (rtu_yy_xx_flush                 ),
  .vidu_vpu_vid_fp_inst_dp_vld      (vidu_vpu_vid_fp_inst_dp_vld     ),
  .vidu_vpu_vid_fp_inst_dst_reg     (vidu_vpu_vid_fp_inst_dst_reg    ),
  .vidu_vpu_vid_fp_inst_dst_vld     (vidu_vpu_vid_fp_inst_dst_vld    ),
  .vidu_vpu_vid_fp_inst_dste_vld    (vidu_vpu_vid_fp_inst_dste_vld   ),
  .vidu_vpu_vid_fp_inst_dstf_reg    (vidu_vpu_vid_fp_inst_dstf_reg   ),
  .vidu_vpu_vid_fp_inst_dstf_vld    (vidu_vpu_vid_fp_inst_dstf_vld   ),
  .vidu_vpu_vid_fp_inst_eu          (vidu_vpu_vid_fp_inst_eu         ),
  .vidu_vpu_vid_fp_inst_func        (vidu_vpu_vid_fp_inst_func       ),
  .vidu_vpu_vid_fp_inst_gateclk_vld (vidu_vpu_vid_fp_inst_gateclk_vld),
  .vidu_vpu_vid_fp_inst_src1_data   (vidu_vpu_vid_fp_inst_src1_data  ),
  .vidu_vpu_vid_fp_inst_srcf0_data  (vidu_vpu_vid_fp_inst_srcf0_data ),
  .vidu_vpu_vid_fp_inst_srcf1_data  (vidu_vpu_vid_fp_inst_srcf1_data ),
  .vidu_vpu_vid_fp_inst_srcf2_data  (vidu_vpu_vid_fp_inst_srcf2_data ),
  .vidu_vpu_vid_fp_inst_srcf2_rdy   (vidu_vpu_vid_fp_inst_srcf2_rdy  ),
  .vidu_vpu_vid_fp_inst_srcf2_vld   (vidu_vpu_vid_fp_inst_srcf2_vld  ),
  .vidu_vpu_vid_fp_inst_vld         (vidu_vpu_vid_fp_inst_vld        ),
  .vlsu_buf_stall                   (vlsu_buf_stall                  ),
  .vlsu_dtu_data                    (vlsu_dtu_data                   ),
  .vlsu_dtu_data_vld                (vlsu_dtu_data_vld               ),
  .vlsu_dtu_data_vld_gate           (vlsu_dtu_data_vld_gate          ),
  .vlsu_lsu_data_shift              (vlsu_lsu_data_shift             ),
  .vlsu_lsu_data_vld                (vlsu_lsu_data_vld               ),
  .vlsu_lsu_fwd_data                (vlsu_lsu_fwd_data               ),
  .vlsu_lsu_fwd_dest_reg            (vlsu_lsu_fwd_dest_reg           ),
  .vlsu_lsu_fwd_vld                 (vlsu_lsu_fwd_vld                ),
  .vlsu_lsu_src2_depd               (vlsu_lsu_src2_depd              ),
  .vlsu_lsu_src2_reg                (vlsu_lsu_src2_reg               ),
  .vlsu_lsu_wdata                   (vlsu_lsu_wdata                  ),
  .vlsu_rtu_vl_updt_data            (vlsu_rtu_vl_updt_data           ),
  .vlsu_rtu_vl_updt_vld             (vlsu_rtu_vl_updt_vld            ),
  .vlsu_xx_no_op                    (vlsu_xx_no_op                   ),
  .vpu_dtu_dbg_info                 (vpu_dtu_dbg_info                ),
  .vpu_rtu_fflag                    (vpu_rtu_fflag                   ),
  .vpu_rtu_fflag_vld                (vpu_rtu_fflag_vld               ),
  .vpu_rtu_gpr_wb_data              (vpu_rtu_gpr_wb_data             ),
  .vpu_rtu_gpr_wb_index             (vpu_rtu_gpr_wb_index            ),
  .vpu_rtu_gpr_wb_req               (vpu_rtu_gpr_wb_req              ),
  .vpu_rtu_no_op                    (vpu_rtu_no_op                   ),
  .vpu_vidu_fp_fwd_data             (vpu_vidu_fp_fwd_data            ),
  .vpu_vidu_fp_fwd_reg              (vpu_vidu_fp_fwd_reg             ),
  .vpu_vidu_fp_fwd_vld              (vpu_vidu_fp_fwd_vld             ),
  .vpu_vidu_fp_wb_data              (vpu_vidu_fp_wb_data             ),
  .vpu_vidu_fp_wb_reg               (vpu_vidu_fp_wb_reg              ),
  .vpu_vidu_fp_wb_vld               (vpu_vidu_fp_wb_vld              ),
  .vpu_vidu_vex1_fp_stall           (vpu_vidu_vex1_fp_stall          ),
  .vpu_vidu_wbt_fp_wb0_reg          (vpu_vidu_wbt_fp_wb0_reg         ),
  .vpu_vidu_wbt_fp_wb0_vld          (vpu_vidu_wbt_fp_wb0_vld         ),
  .vpu_vidu_wbt_fp_wb1_reg          (vpu_vidu_wbt_fp_wb1_reg         ),
  .vpu_vidu_wbt_fp_wb1_vld          (vpu_vidu_wbt_fp_wb1_vld         )
);

aq_lsu_top  x_aq_lsu_top (
  .biu_lsu_arready              (biu_lsu_arready             ),
  .biu_lsu_no_op                (biu_lsu_no_op               ),
  .biu_lsu_rdata                (biu_lsu_rdata               ),
  .biu_lsu_rid                  (biu_lsu_rid                 ),
  .biu_lsu_rlast                (biu_lsu_rlast               ),
  .biu_lsu_rresp                (biu_lsu_rresp               ),
  .biu_lsu_rvalid               (biu_lsu_rvalid              ),
  .biu_lsu_stb_awready          (biu_lsu_stb_awready         ),
  .biu_lsu_stb_wready           (biu_lsu_stb_wready          ),
  .biu_lsu_vb_awready           (biu_lsu_vb_awready          ),
  .biu_lsu_vb_wready            (biu_lsu_vb_wready           ),
  .cp0_lsu_amr                  (cp0_lsu_amr                 ),
  .cp0_lsu_dcache_en            (cp0_lsu_dcache_en           ),
  .cp0_lsu_dcache_pref_dist     (cp0_lsu_dcache_pref_dist    ),
  .cp0_lsu_dcache_pref_en       (cp0_lsu_dcache_pref_en      ),
  .cp0_lsu_dcache_read_idx      (cp0_lsu_dcache_read_idx     ),
  .cp0_lsu_dcache_read_req      (cp0_lsu_dcache_read_req     ),
  .cp0_lsu_dcache_read_type     (cp0_lsu_dcache_read_type    ),
  .cp0_lsu_dcache_read_way      (cp0_lsu_dcache_read_way     ),
  .cp0_lsu_dcache_wa            (cp0_lsu_dcache_wa           ),
  .cp0_lsu_dcache_wb            (cp0_lsu_dcache_wb           ),
  .cp0_lsu_fence_req            (cp0_lsu_fence_req           ),
  .cp0_lsu_icc_addr             (cp0_lsu_icc_addr            ),
  .cp0_lsu_icc_op               (cp0_lsu_icc_op              ),
  .cp0_lsu_icc_req              (cp0_lsu_icc_req             ),
  .cp0_lsu_icc_type             (cp0_lsu_icc_type            ),
  .cp0_lsu_icg_en               (cp0_lsu_icg_en              ),
  .cp0_lsu_mm                   (cp0_lsu_mm                  ),
  .cp0_lsu_mpp                  (cp0_lsu_mpp                 ),
  .cp0_lsu_mprv                 (cp0_lsu_mprv                ),
  .cp0_lsu_sync_req             (cp0_lsu_sync_req            ),
  .cp0_lsu_we_en                (cp0_lsu_we_en               ),
  .cp0_yy_priv_mode             (cp0_yy_priv_mode            ),
  .cpurst_b                     (cpurst_b                    ),
  .da_xx_fwd_data               (da_xx_fwd_data              ),
  .da_xx_fwd_dst_reg            (da_xx_fwd_dst_reg           ),
  .da_xx_fwd_vld                (da_xx_fwd_vld               ),
  .dtu_lsu_addr_trig_en         (dtu_lsu_addr_trig_en        ),
  .dtu_lsu_data_trig_en         (dtu_lsu_data_trig_en        ),
  .dtu_lsu_halt_info            (dtu_lsu_halt_info           ),
  .dtu_lsu_halt_info_vld        (dtu_lsu_halt_info_vld       ),
  .forever_cpuclk               (forever_cpuclk              ),
  .hpcp_lsu_cnt_en              (hpcp_lsu_cnt_en             ),
  .idu_lsu_ex1_dp_sel           (idu_lsu_ex1_dp_sel          ),
  .idu_lsu_ex1_dst0_reg         (idu_lsu_ex1_dst0_reg        ),
  .idu_lsu_ex1_dst1_reg         (idu_lsu_ex1_dst1_reg        ),
  .idu_lsu_ex1_func             (idu_lsu_ex1_func            ),
  .idu_lsu_ex1_gateclk_sel      (idu_lsu_ex1_gateclk_sel     ),
  .idu_lsu_ex1_halt_info        (idu_lsu_ex1_halt_info       ),
  .idu_lsu_ex1_length           (idu_lsu_ex1_length          ),
  .idu_lsu_ex1_sel              (idu_lsu_ex1_sel             ),
  .idu_lsu_ex1_split            (idu_lsu_ex1_split           ),
  .idu_lsu_ex1_src0_data        (idu_lsu_ex1_src0_data       ),
  .idu_lsu_ex1_src1_data        (idu_lsu_ex1_src1_data       ),
  .idu_lsu_ex1_src2_data        (idu_lsu_ex1_src2_data       ),
  .idu_lsu_ex1_src2_ready       (idu_lsu_ex1_src2_ready      ),
  .idu_lsu_ex1_src2_reg         (idu_lsu_ex1_src2_reg        ),
  .idu_lsu_ex1_vlmul            (idu_lsu_ex1_vlmul           ),
  .idu_lsu_ex1_vsew             (idu_lsu_ex1_vsew            ),
  .ifu_lsu_warm_up              (ifu_lsu_warm_up             ),
  .iu_lsu_ex1_cur_pc            (iu_lsu_ex1_cur_pc           ),
  .lsu_biu_araddr               (lsu_biu_araddr              ),
  .lsu_biu_arburst              (lsu_biu_arburst             ),
  .lsu_biu_arcache              (lsu_biu_arcache             ),
  .lsu_biu_arid                 (lsu_biu_arid                ),
  .lsu_biu_arlen                (lsu_biu_arlen               ),
  .lsu_biu_arprot               (lsu_biu_arprot              ),
  .lsu_biu_arsize               (lsu_biu_arsize              ),
  .lsu_biu_aruser               (lsu_biu_aruser              ),
  .lsu_biu_arvalid              (lsu_biu_arvalid             ),
  .lsu_biu_stb_awaddr           (lsu_biu_stb_awaddr          ),
  .lsu_biu_stb_awburst          (lsu_biu_stb_awburst         ),
  .lsu_biu_stb_awcache          (lsu_biu_stb_awcache         ),
  .lsu_biu_stb_awid             (lsu_biu_stb_awid            ),
  .lsu_biu_stb_awlen            (lsu_biu_stb_awlen           ),
  .lsu_biu_stb_awprot           (lsu_biu_stb_awprot          ),
  .lsu_biu_stb_awsize           (lsu_biu_stb_awsize          ),
  .lsu_biu_stb_awuser           (lsu_biu_stb_awuser          ),
  .lsu_biu_stb_awvalid          (lsu_biu_stb_awvalid         ),
  .lsu_biu_stb_wdata            (lsu_biu_stb_wdata           ),
  .lsu_biu_stb_wlast            (lsu_biu_stb_wlast           ),
  .lsu_biu_stb_wstrb            (lsu_biu_stb_wstrb           ),
  .lsu_biu_stb_wvalid           (lsu_biu_stb_wvalid          ),
  .lsu_biu_vb_awaddr            (lsu_biu_vb_awaddr           ),
  .lsu_biu_vb_awburst           (lsu_biu_vb_awburst          ),
  .lsu_biu_vb_awcache           (lsu_biu_vb_awcache          ),
  .lsu_biu_vb_awid              (lsu_biu_vb_awid             ),
  .lsu_biu_vb_awlen             (lsu_biu_vb_awlen            ),
  .lsu_biu_vb_awprot            (lsu_biu_vb_awprot           ),
  .lsu_biu_vb_awsize            (lsu_biu_vb_awsize           ),
  .lsu_biu_vb_awvalid           (lsu_biu_vb_awvalid          ),
  .lsu_biu_vb_wdata             (lsu_biu_vb_wdata            ),
  .lsu_biu_vb_wlast             (lsu_biu_vb_wlast            ),
  .lsu_biu_vb_wstrb             (lsu_biu_vb_wstrb            ),
  .lsu_biu_vb_wvalid            (lsu_biu_vb_wvalid           ),
  .lsu_cp0_dcache_read_data     (lsu_cp0_dcache_read_data    ),
  .lsu_cp0_dcache_read_data_vld (lsu_cp0_dcache_read_data_vld),
  .lsu_cp0_fence_ack            (lsu_cp0_fence_ack           ),
  .lsu_cp0_icc_done             (lsu_cp0_icc_done            ),
  .lsu_cp0_sync_ack             (lsu_cp0_sync_ack            ),
  .lsu_dtu_debug_info           (lsu_dtu_debug_info          ),
  .lsu_dtu_halt_info            (lsu_dtu_halt_info           ),
  .lsu_dtu_last_check           (lsu_dtu_last_check          ),
  .lsu_dtu_ldst_addr            (lsu_dtu_ldst_addr           ),
  .lsu_dtu_ldst_addr_vld        (lsu_dtu_ldst_addr_vld       ),
  .lsu_dtu_ldst_bytes_vld       (lsu_dtu_ldst_bytes_vld      ),
  .lsu_dtu_ldst_data            (lsu_dtu_ldst_data           ),
  .lsu_dtu_ldst_data_vld        (lsu_dtu_ldst_data_vld       ),
  .lsu_dtu_ldst_type            (lsu_dtu_ldst_type           ),
  .lsu_dtu_mem_access_size      (lsu_dtu_mem_access_size     ),
  .lsu_hpcp_cache_read_access   (lsu_hpcp_cache_read_access  ),
  .lsu_hpcp_cache_read_miss     (lsu_hpcp_cache_read_miss    ),
  .lsu_hpcp_cache_write_access  (lsu_hpcp_cache_write_access ),
  .lsu_hpcp_cache_write_miss    (lsu_hpcp_cache_write_miss   ),
  .lsu_hpcp_inst_store          (lsu_hpcp_inst_store         ),
  .lsu_hpcp_unalign_inst        (lsu_hpcp_unalign_inst       ),
  .lsu_idu_full                 (lsu_idu_full                ),
  .lsu_idu_global_full          (lsu_idu_global_full         ),
  .lsu_iu_ex2_data              (lsu_iu_ex2_data             ),
  .lsu_iu_ex2_data_vld          (lsu_iu_ex2_data_vld         ),
  .lsu_iu_ex2_dest_reg          (lsu_iu_ex2_dest_reg         ),
  .lsu_mmu_abort                (lsu_mmu_abort               ),
  .lsu_mmu_bus_error            (lsu_mmu_bus_error           ),
  .lsu_mmu_data                 (lsu_mmu_data                ),
  .lsu_mmu_data_vld             (lsu_mmu_data_vld            ),
  .lsu_mmu_priv_mode            (lsu_mmu_priv_mode           ),
  .lsu_mmu_st_inst              (lsu_mmu_st_inst             ),
  .lsu_mmu_va                   (lsu_mmu_va                  ),
  .lsu_mmu_va_vld               (lsu_mmu_va_vld              ),
  .lsu_rtu_async_expt_vld       (lsu_rtu_async_expt_vld      ),
  .lsu_rtu_async_ld_inst        (lsu_rtu_async_ld_inst       ),
  .lsu_rtu_async_tval           (lsu_rtu_async_tval          ),
  .lsu_rtu_ex1_buffer_vld       (lsu_rtu_ex1_buffer_vld      ),
  .lsu_rtu_ex1_cmplt            (lsu_rtu_ex1_cmplt           ),
  .lsu_rtu_ex1_cmplt_dp         (lsu_rtu_ex1_cmplt_dp        ),
  .lsu_rtu_ex1_cmplt_for_pcgen  (lsu_rtu_ex1_cmplt_for_pcgen ),
  .lsu_rtu_ex1_data             (lsu_rtu_ex1_data            ),
  .lsu_rtu_ex1_dest_reg         (lsu_rtu_ex1_dest_reg        ),
  .lsu_rtu_ex1_expt_tval        (lsu_rtu_ex1_expt_tval       ),
  .lsu_rtu_ex1_expt_vec         (lsu_rtu_ex1_expt_vec        ),
  .lsu_rtu_ex1_expt_vld         (lsu_rtu_ex1_expt_vld        ),
  .lsu_rtu_ex1_fs_dirty         (lsu_rtu_ex1_fs_dirty        ),
  .lsu_rtu_ex1_halt_info        (lsu_rtu_ex1_halt_info       ),
  .lsu_rtu_ex1_inst_len         (lsu_rtu_ex1_inst_len        ),
  .lsu_rtu_ex1_inst_split       (lsu_rtu_ex1_inst_split      ),
  .lsu_rtu_ex1_tval2_vld        (lsu_rtu_ex1_tval2_vld       ),
  .lsu_rtu_ex1_vs_dirty         (lsu_rtu_ex1_vs_dirty        ),
  .lsu_rtu_ex1_vstart           (lsu_rtu_ex1_vstart          ),
  .lsu_rtu_ex1_vstart_vld       (lsu_rtu_ex1_vstart_vld      ),
  .lsu_rtu_ex1_wb_dp            (lsu_rtu_ex1_wb_dp           ),
  .lsu_rtu_ex1_wb_vld           (lsu_rtu_ex1_wb_vld          ),
  .lsu_rtu_ex2_data             (lsu_rtu_ex2_data            ),
  .lsu_rtu_ex2_data_vld         (lsu_rtu_ex2_data_vld        ),
  .lsu_rtu_ex2_dest_reg         (lsu_rtu_ex2_dest_reg        ),
  .lsu_rtu_ex2_tval2            (lsu_rtu_ex2_tval2           ),
  .lsu_rtu_no_op                (lsu_rtu_no_op               ),
  .lsu_rtu_wb_data              (lsu_rtu_wb_data             ),
  .lsu_rtu_wb_dest_reg          (lsu_rtu_wb_dest_reg         ),
  .lsu_rtu_wb_vld               (lsu_rtu_wb_vld              ),
  .lsu_vlsu_bytes_vld           (lsu_vlsu_bytes_vld          ),
  .lsu_vlsu_data                (lsu_vlsu_data               ),
  .lsu_vlsu_data_grant          (lsu_vlsu_data_grant         ),
  .lsu_vlsu_data_vld            (lsu_vlsu_data_vld           ),
  .lsu_vlsu_dc_create_vld       (lsu_vlsu_dc_create_vld      ),
  .lsu_vlsu_dc_fld_req          (lsu_vlsu_dc_fld_req         ),
  .lsu_vlsu_dc_fof              (lsu_vlsu_dc_fof             ),
  .lsu_vlsu_dc_nf               (lsu_vlsu_dc_nf              ),
  .lsu_vlsu_dc_sew              (lsu_vlsu_dc_sew             ),
  .lsu_vlsu_dc_split_cnt        (lsu_vlsu_dc_split_cnt       ),
  .lsu_vlsu_dc_sseg_first       (lsu_vlsu_dc_sseg_first      ),
  .lsu_vlsu_dc_stall            (lsu_vlsu_dc_stall           ),
  .lsu_vlsu_dest_reg            (lsu_vlsu_dest_reg           ),
  .lsu_vlsu_expt_vld            (lsu_vlsu_expt_vld           ),
  .lsu_vlsu_func                (lsu_vlsu_func               ),
  .lsu_vlsu_sew                 (lsu_vlsu_sew                ),
  .lsu_vlsu_split_last          (lsu_vlsu_split_last         ),
  .lsu_vlsu_st_expt             (lsu_vlsu_st_expt            ),
  .lsu_vlsu_st_offset           (lsu_vlsu_st_offset          ),
  .lsu_vlsu_st_sew              (lsu_vlsu_st_sew             ),
  .lsu_vlsu_st_size             (lsu_vlsu_st_size            ),
  .lsu_vlsu_vl_update           (lsu_vlsu_vl_update          ),
  .lsu_vlsu_vl_upval            (lsu_vlsu_vl_upval           ),
  .mmu_lsu_access_fault         (mmu_lsu_access_fault        ),
  .mmu_lsu_buf                  (mmu_lsu_buf                 ),
  .mmu_lsu_ca                   (mmu_lsu_ca                  ),
  .mmu_lsu_data_req             (mmu_lsu_data_req            ),
  .mmu_lsu_data_req_addr        (mmu_lsu_data_req_addr       ),
  .mmu_lsu_data_req_size        (mmu_lsu_data_req_size       ),
  .mmu_lsu_pa                   (mmu_lsu_pa                  ),
  .mmu_lsu_pa_vld               (mmu_lsu_pa_vld              ),
  .mmu_lsu_page_fault           (mmu_lsu_page_fault          ),
  .mmu_lsu_sec                  (mmu_lsu_sec                 ),
  .mmu_lsu_sh                   (mmu_lsu_sh                  ),
  .mmu_lsu_so                   (mmu_lsu_so                  ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .rtu_lsu_async_expt_ack       (rtu_lsu_async_expt_ack      ),
  .rtu_lsu_expt_ack             (rtu_lsu_expt_ack            ),
  .rtu_lsu_expt_exit            (rtu_lsu_expt_exit           ),
  .rtu_yy_xx_async_flush        (rtu_yy_xx_async_flush       ),
  .rtu_yy_xx_dbgon              (rtu_yy_xx_dbgon             ),
  .rtu_yy_xx_flush              (rtu_yy_xx_flush             ),
  .vlsu_buf_stall               (vlsu_buf_stall              ),
  .vlsu_dtu_data                (vlsu_dtu_data               ),
  .vlsu_dtu_data_vld            (vlsu_dtu_data_vld           ),
  .vlsu_dtu_data_vld_gate       (vlsu_dtu_data_vld_gate      ),
  .vlsu_lsu_data_shift          (vlsu_lsu_data_shift         ),
  .vlsu_lsu_data_vld            (vlsu_lsu_data_vld           ),
  .vlsu_lsu_fwd_data            (vlsu_lsu_fwd_data           ),
  .vlsu_lsu_fwd_dest_reg        (vlsu_lsu_fwd_dest_reg       ),
  .vlsu_lsu_fwd_vld             (vlsu_lsu_fwd_vld            ),
  .vlsu_lsu_src2_depd           (vlsu_lsu_src2_depd          ),
  .vlsu_lsu_src2_reg            (vlsu_lsu_src2_reg           ),
  .vlsu_lsu_wdata               (vlsu_lsu_wdata              ),
  .vlsu_xx_no_op                (vlsu_xx_no_op               )
);

aq_cp0_top  x_aq_cp0_top (
  .biu_cp0_coreid               (biu_cp0_coreid              ),
  .biu_cp0_me_int               (biu_cp0_me_int              ),
  .biu_cp0_ms_int               (biu_cp0_ms_int              ),
  .biu_cp0_mt_int               (biu_cp0_mt_int              ),
  .biu_cp0_rvba                 (biu_cp0_rvba                ),
  .biu_cp0_se_int               (biu_cp0_se_int              ),
  .biu_cp0_ss_int               (biu_cp0_ss_int              ),
  .biu_cp0_st_int               (biu_cp0_st_int              ),
  .cp0_biu_icg_en               (cp0_biu_icg_en              ),
  .cp0_biu_lpmd_b               (cp0_biu_lpmd_b              ),
  .cp0_dtu_addr                 (cp0_dtu_addr                ),
  .cp0_dtu_debug_info           (cp0_dtu_debug_info          ),
  .cp0_dtu_icg_en               (cp0_dtu_icg_en              ),
  .cp0_dtu_mexpt_vld            (cp0_dtu_mexpt_vld           ),
  .cp0_dtu_pcfifo_frz           (cp0_dtu_pcfifo_frz          ),
  .cp0_dtu_rreg                 (cp0_dtu_rreg                ),
  .cp0_dtu_satp                 (cp0_dtu_satp                ),
  .cp0_dtu_wdata                (cp0_dtu_wdata               ),
  .cp0_dtu_wreg                 (cp0_dtu_wreg                ),
  .cp0_hpcp_icg_en              (cp0_hpcp_icg_en             ),
  .cp0_hpcp_index               (cp0_hpcp_index              ),
  .cp0_hpcp_int_off_vld         (cp0_hpcp_int_off_vld        ),
  .cp0_hpcp_mcntwen             (cp0_hpcp_mcntwen            ),
  .cp0_hpcp_pmdm                (cp0_hpcp_pmdm               ),
  .cp0_hpcp_pmds                (cp0_hpcp_pmds               ),
  .cp0_hpcp_pmdu                (cp0_hpcp_pmdu               ),
  .cp0_hpcp_sync_stall_vld      (cp0_hpcp_sync_stall_vld     ),
  .cp0_hpcp_wdata               (cp0_hpcp_wdata              ),
  .cp0_hpcp_wreg                (cp0_hpcp_wreg               ),
  .cp0_idu_cskyee               (cp0_idu_cskyee              ),
  .cp0_idu_dis_fence_in_dbg     (cp0_idu_dis_fence_in_dbg    ),
  .cp0_idu_frm                  (cp0_idu_frm                 ),
  .cp0_idu_fs                   (cp0_idu_fs                  ),
  .cp0_idu_icg_en               (cp0_idu_icg_en              ),
  .cp0_idu_issue_stall          (cp0_idu_issue_stall         ),
  .cp0_idu_ucme                 (cp0_idu_ucme                ),
  .cp0_idu_vill                 (cp0_idu_vill                ),
  .cp0_idu_vl_zero              (cp0_idu_vl_zero             ),
  .cp0_idu_vlmul                (cp0_idu_vlmul               ),
  .cp0_idu_vs                   (cp0_idu_vs                  ),
  .cp0_idu_vsetvl_dis_stall     (cp0_idu_vsetvl_dis_stall    ),
  .cp0_idu_vsew                 (cp0_idu_vsew                ),
  .cp0_idu_vstart               (cp0_idu_vstart              ),
  .cp0_ifu_bht_en               (cp0_ifu_bht_en              ),
  .cp0_ifu_bht_inv              (cp0_ifu_bht_inv             ),
  .cp0_ifu_btb_clr              (cp0_ifu_btb_clr             ),
  .cp0_ifu_btb_en               (cp0_ifu_btb_en              ),
  .cp0_ifu_icache_en            (cp0_ifu_icache_en           ),
  .cp0_ifu_icache_inv_addr      (cp0_ifu_icache_inv_addr     ),
  .cp0_ifu_icache_inv_req       (cp0_ifu_icache_inv_req      ),
  .cp0_ifu_icache_inv_type      (cp0_ifu_icache_inv_type     ),
  .cp0_ifu_icache_pref_en       (cp0_ifu_icache_pref_en      ),
  .cp0_ifu_icache_read_index    (cp0_ifu_icache_read_index   ),
  .cp0_ifu_icache_read_req      (cp0_ifu_icache_read_req     ),
  .cp0_ifu_icache_read_tag      (cp0_ifu_icache_read_tag     ),
  .cp0_ifu_icache_read_way      (cp0_ifu_icache_read_way     ),
  .cp0_ifu_icg_en               (cp0_ifu_icg_en              ),
  .cp0_ifu_in_lpmd              (cp0_ifu_in_lpmd             ),
  .cp0_ifu_iwpe                 (cp0_ifu_iwpe                ),
  .cp0_ifu_lpmd_req             (cp0_ifu_lpmd_req            ),
  .cp0_ifu_ras_en               (cp0_ifu_ras_en              ),
  .cp0_ifu_rst_inv_done         (cp0_ifu_rst_inv_done        ),
  .cp0_iu_icg_en                (cp0_iu_icg_en               ),
  .cp0_lsu_amr                  (cp0_lsu_amr                 ),
  .cp0_lsu_dcache_en            (cp0_lsu_dcache_en           ),
  .cp0_lsu_dcache_pref_dist     (cp0_lsu_dcache_pref_dist    ),
  .cp0_lsu_dcache_pref_en       (cp0_lsu_dcache_pref_en      ),
  .cp0_lsu_dcache_read_idx      (cp0_lsu_dcache_read_idx     ),
  .cp0_lsu_dcache_read_req      (cp0_lsu_dcache_read_req     ),
  .cp0_lsu_dcache_read_type     (cp0_lsu_dcache_read_type    ),
  .cp0_lsu_dcache_read_way      (cp0_lsu_dcache_read_way     ),
  .cp0_lsu_dcache_wa            (cp0_lsu_dcache_wa           ),
  .cp0_lsu_dcache_wb            (cp0_lsu_dcache_wb           ),
  .cp0_lsu_fence_req            (cp0_lsu_fence_req           ),
  .cp0_lsu_icc_addr             (cp0_lsu_icc_addr            ),
  .cp0_lsu_icc_op               (cp0_lsu_icc_op              ),
  .cp0_lsu_icc_req              (cp0_lsu_icc_req             ),
  .cp0_lsu_icc_type             (cp0_lsu_icc_type            ),
  .cp0_lsu_icg_en               (cp0_lsu_icg_en              ),
  .cp0_lsu_mm                   (cp0_lsu_mm                  ),
  .cp0_lsu_mpp                  (cp0_lsu_mpp                 ),
  .cp0_lsu_mprv                 (cp0_lsu_mprv                ),
  .cp0_lsu_sync_req             (cp0_lsu_sync_req            ),
  .cp0_lsu_we_en                (cp0_lsu_we_en               ),
  .cp0_mmu_addr                 (cp0_mmu_addr                ),
  .cp0_mmu_icg_en               (cp0_mmu_icg_en              ),
  .cp0_mmu_lpmd_req             (cp0_mmu_lpmd_req            ),
  .cp0_mmu_maee                 (cp0_mmu_maee                ),
  .cp0_mmu_mxr                  (cp0_mmu_mxr                 ),
  .cp0_mmu_ptw_en               (cp0_mmu_ptw_en              ),
  .cp0_mmu_satp_data            (cp0_mmu_satp_data           ),
  .cp0_mmu_satp_wen             (cp0_mmu_satp_wen            ),
  .cp0_mmu_sum                  (cp0_mmu_sum                 ),
  .cp0_mmu_tlb_all_inv          (cp0_mmu_tlb_all_inv         ),
  .cp0_mmu_tlb_asid             (cp0_mmu_tlb_asid            ),
  .cp0_mmu_tlb_asid_all_inv     (cp0_mmu_tlb_asid_all_inv    ),
  .cp0_mmu_tlb_va               (cp0_mmu_tlb_va              ),
  .cp0_mmu_tlb_va_all_inv       (cp0_mmu_tlb_va_all_inv      ),
  .cp0_mmu_tlb_va_asid_inv      (cp0_mmu_tlb_va_asid_inv     ),
  .cp0_mmu_wdata                (cp0_mmu_wdata               ),
  .cp0_mmu_wreg                 (cp0_mmu_wreg                ),
  .cp0_pmp_addr                 (cp0_pmp_addr                ),
  .cp0_pmp_icg_en               (cp0_pmp_icg_en              ),
  .cp0_pmp_wdata                (cp0_pmp_wdata               ),
  .cp0_pmp_wreg                 (cp0_pmp_wreg                ),
  .cp0_rtu_ex1_chgflw           (cp0_rtu_ex1_chgflw          ),
  .cp0_rtu_ex1_chgflw_pc        (cp0_rtu_ex1_chgflw_pc       ),
  .cp0_rtu_ex1_cmplt            (cp0_rtu_ex1_cmplt           ),
  .cp0_rtu_ex1_cmplt_dp         (cp0_rtu_ex1_cmplt_dp        ),
  .cp0_rtu_ex1_expt_tval        (cp0_rtu_ex1_expt_tval       ),
  .cp0_rtu_ex1_expt_vec         (cp0_rtu_ex1_expt_vec        ),
  .cp0_rtu_ex1_expt_vld         (cp0_rtu_ex1_expt_vld        ),
  .cp0_rtu_ex1_flush            (cp0_rtu_ex1_flush           ),
  .cp0_rtu_ex1_halt_info        (cp0_rtu_ex1_halt_info       ),
  .cp0_rtu_ex1_inst_dret        (cp0_rtu_ex1_inst_dret       ),
  .cp0_rtu_ex1_inst_ebreak      (cp0_rtu_ex1_inst_ebreak     ),
  .cp0_rtu_ex1_inst_len         (cp0_rtu_ex1_inst_len        ),
  .cp0_rtu_ex1_inst_mret        (cp0_rtu_ex1_inst_mret       ),
  .cp0_rtu_ex1_inst_split       (cp0_rtu_ex1_inst_split      ),
  .cp0_rtu_ex1_inst_sret        (cp0_rtu_ex1_inst_sret       ),
  .cp0_rtu_ex1_vs_dirty         (cp0_rtu_ex1_vs_dirty        ),
  .cp0_rtu_ex1_vs_dirty_dp      (cp0_rtu_ex1_vs_dirty_dp     ),
  .cp0_rtu_ex1_wb_data          (cp0_rtu_ex1_wb_data         ),
  .cp0_rtu_ex1_wb_dp            (cp0_rtu_ex1_wb_dp           ),
  .cp0_rtu_ex1_wb_preg          (cp0_rtu_ex1_wb_preg         ),
  .cp0_rtu_ex1_wb_vld           (cp0_rtu_ex1_wb_vld          ),
  .cp0_rtu_fence_idle           (cp0_rtu_fence_idle          ),
  .cp0_rtu_icg_en               (cp0_rtu_icg_en              ),
  .cp0_rtu_in_lpmd              (cp0_rtu_in_lpmd             ),
  .cp0_rtu_int_vld              (cp0_rtu_int_vld             ),
  .cp0_rtu_trap_pc              (cp0_rtu_trap_pc             ),
  .cp0_rtu_vstart_eq_0          (cp0_rtu_vstart_eq_0         ),
  .cp0_vpu_icg_en               (cp0_vpu_icg_en              ),
  .cp0_vpu_xx_bf16              (cp0_vpu_xx_bf16             ),
  .cp0_vpu_xx_dqnan             (cp0_vpu_xx_dqnan            ),
  .cp0_vpu_xx_rm                (cp0_vpu_xx_rm               ),
  .cp0_xx_mrvbr                 (cp0_xx_mrvbr                ),
  .cp0_yy_clk_en                (cp0_yy_clk_en               ),
  .cp0_yy_priv_mode             (cp0_yy_priv_mode            ),
  .cpurst_b                     (cpurst_b                    ),
  .dtu_cp0_dcsr_mprven          (dtu_cp0_dcsr_mprven         ),
  .dtu_cp0_dcsr_prv             (dtu_cp0_dcsr_prv            ),
  .dtu_cp0_rdata                (dtu_cp0_rdata               ),
  .dtu_cp0_wake_up              (dtu_cp0_wake_up             ),
  .forever_cpuclk               (forever_cpuclk              ),
  .hpcp_cp0_data                (hpcp_cp0_data               ),
  .hpcp_cp0_int_vld             (hpcp_cp0_int_vld            ),
  .hpcp_cp0_sce                 (hpcp_cp0_sce                ),
  .idu_cp0_ex1_dp_sel           (idu_cp0_ex1_dp_sel          ),
  .idu_cp0_ex1_dst0_reg         (idu_cp0_ex1_dst0_reg        ),
  .idu_cp0_ex1_expt_acc_error   (idu_cp0_ex1_expt_acc_error  ),
  .idu_cp0_ex1_expt_high        (idu_cp0_ex1_expt_high       ),
  .idu_cp0_ex1_expt_illegal     (idu_cp0_ex1_expt_illegal    ),
  .idu_cp0_ex1_expt_page_fault  (idu_cp0_ex1_expt_page_fault ),
  .idu_cp0_ex1_func             (idu_cp0_ex1_func            ),
  .idu_cp0_ex1_gateclk_sel      (idu_cp0_ex1_gateclk_sel     ),
  .idu_cp0_ex1_halt_info        (idu_cp0_ex1_halt_info       ),
  .idu_cp0_ex1_length           (idu_cp0_ex1_length          ),
  .idu_cp0_ex1_opcode           (idu_cp0_ex1_opcode          ),
  .idu_cp0_ex1_sel              (idu_cp0_ex1_sel             ),
  .idu_cp0_ex1_split            (idu_cp0_ex1_split           ),
  .idu_cp0_ex1_src0_data        (idu_cp0_ex1_src0_data       ),
  .idu_cp0_ex1_src1_data        (idu_cp0_ex1_src1_data       ),
  .ifu_cp0_bht_inv_done         (ifu_cp0_bht_inv_done        ),
  .ifu_cp0_icache_inv_done      (ifu_cp0_icache_inv_done     ),
  .ifu_cp0_icache_read_data     (ifu_cp0_icache_read_data    ),
  .ifu_cp0_icache_read_data_vld (ifu_cp0_icache_read_data_vld),
  .ifu_cp0_rst_inv_req          (ifu_cp0_rst_inv_req         ),
  .ifu_cp0_warm_up              (ifu_cp0_warm_up             ),
  .ifu_yy_xx_no_op              (ifu_yy_xx_no_op             ),
  .iu_cp0_ex1_cur_pc            (iu_cp0_ex1_cur_pc           ),
  .lsu_cp0_dcache_read_data     (lsu_cp0_dcache_read_data    ),
  .lsu_cp0_dcache_read_data_vld (lsu_cp0_dcache_read_data_vld),
  .lsu_cp0_fence_ack            (lsu_cp0_fence_ack           ),
  .lsu_cp0_icc_done             (lsu_cp0_icc_done            ),
  .lsu_cp0_sync_ack             (lsu_cp0_sync_ack            ),
  .mmu_cp0_cmplt                (mmu_cp0_cmplt               ),
  .mmu_cp0_data                 (mmu_cp0_data                ),
  .mmu_cp0_tlb_inv_done         (mmu_cp0_tlb_inv_done        ),
  .mmu_yy_xx_no_op              (mmu_yy_xx_no_op             ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .pmp_cp0_data                 (pmp_cp0_data                ),
  .rtu_cp0_epc                  (rtu_cp0_epc                 ),
  .rtu_cp0_exit_debug           (rtu_cp0_exit_debug          ),
  .rtu_cp0_fflags               (rtu_cp0_fflags              ),
  .rtu_cp0_fflags_updt          (rtu_cp0_fflags_updt         ),
  .rtu_cp0_fs_dirty_updt        (rtu_cp0_fs_dirty_updt       ),
  .rtu_cp0_fs_dirty_updt_dp     (rtu_cp0_fs_dirty_updt_dp    ),
  .rtu_cp0_tval                 (rtu_cp0_tval                ),
  .rtu_cp0_vl                   (rtu_cp0_vl                  ),
  .rtu_cp0_vl_vld               (rtu_cp0_vl_vld              ),
  .rtu_cp0_vs_dirty_updt        (rtu_cp0_vs_dirty_updt       ),
  .rtu_cp0_vs_dirty_updt_dp     (rtu_cp0_vs_dirty_updt_dp    ),
  .rtu_cp0_vstart               (rtu_cp0_vstart              ),
  .rtu_cp0_vstart_vld           (rtu_cp0_vstart_vld          ),
  .rtu_cp0_vxsat                (rtu_cp0_vxsat               ),
  .rtu_cp0_vxsat_vld            (rtu_cp0_vxsat_vld           ),
  .rtu_yy_xx_dbgon              (rtu_yy_xx_dbgon             ),
  .rtu_yy_xx_expt_int           (rtu_yy_xx_expt_int          ),
  .rtu_yy_xx_expt_vec           (rtu_yy_xx_expt_vec          ),
  .rtu_yy_xx_expt_vld           (rtu_yy_xx_expt_vld          ),
  .rtu_yy_xx_flush              (rtu_yy_xx_flush             ),
  .sysio_cp0_apb_base           (sysio_cp0_apb_base          ),
  .vidu_cp0_vid_fof_vld         (vidu_cp0_vid_fof_vld        )
);

aq_rtu_top  x_aq_rtu_top (
  .cp0_rtu_ex1_chgflw            (cp0_rtu_ex1_chgflw           ),
  .cp0_rtu_ex1_chgflw_pc         (cp0_rtu_ex1_chgflw_pc        ),
  .cp0_rtu_ex1_cmplt             (cp0_rtu_ex1_cmplt            ),
  .cp0_rtu_ex1_cmplt_dp          (cp0_rtu_ex1_cmplt_dp         ),
  .cp0_rtu_ex1_expt_tval         (cp0_rtu_ex1_expt_tval        ),
  .cp0_rtu_ex1_expt_vec          (cp0_rtu_ex1_expt_vec         ),
  .cp0_rtu_ex1_expt_vld          (cp0_rtu_ex1_expt_vld         ),
  .cp0_rtu_ex1_flush             (cp0_rtu_ex1_flush            ),
  .cp0_rtu_ex1_halt_info         (cp0_rtu_ex1_halt_info        ),
  .cp0_rtu_ex1_inst_dret         (cp0_rtu_ex1_inst_dret        ),
  .cp0_rtu_ex1_inst_ebreak       (cp0_rtu_ex1_inst_ebreak      ),
  .cp0_rtu_ex1_inst_len          (cp0_rtu_ex1_inst_len         ),
  .cp0_rtu_ex1_inst_mret         (cp0_rtu_ex1_inst_mret        ),
  .cp0_rtu_ex1_inst_split        (cp0_rtu_ex1_inst_split       ),
  .cp0_rtu_ex1_inst_sret         (cp0_rtu_ex1_inst_sret        ),
  .cp0_rtu_ex1_vs_dirty          (cp0_rtu_ex1_vs_dirty         ),
  .cp0_rtu_ex1_vs_dirty_dp       (cp0_rtu_ex1_vs_dirty_dp      ),
  .cp0_rtu_ex1_wb_data           (cp0_rtu_ex1_wb_data          ),
  .cp0_rtu_ex1_wb_dp             (cp0_rtu_ex1_wb_dp            ),
  .cp0_rtu_ex1_wb_preg           (cp0_rtu_ex1_wb_preg          ),
  .cp0_rtu_ex1_wb_vld            (cp0_rtu_ex1_wb_vld           ),
  .cp0_rtu_fence_idle            (cp0_rtu_fence_idle           ),
  .cp0_rtu_icg_en                (cp0_rtu_icg_en               ),
  .cp0_rtu_in_lpmd               (cp0_rtu_in_lpmd              ),
  .cp0_rtu_int_vld               (cp0_rtu_int_vld              ),
  .cp0_rtu_trap_pc               (cp0_rtu_trap_pc              ),
  .cp0_rtu_vstart_eq_0           (cp0_rtu_vstart_eq_0          ),
  .cp0_yy_clk_en                 (cp0_yy_clk_en                ),
  .cpurst_b                      (cpurst_b                     ),
  .dtu_rtu_async_halt_req        (dtu_rtu_async_halt_req       ),
  .dtu_rtu_dpc                   (dtu_rtu_dpc                  ),
  .dtu_rtu_ebreak_action         (dtu_rtu_ebreak_action        ),
  .dtu_rtu_int_mask              (dtu_rtu_int_mask             ),
  .dtu_rtu_pending_tval          (dtu_rtu_pending_tval         ),
  .dtu_rtu_resume_req            (dtu_rtu_resume_req           ),
  .dtu_rtu_step_en               (dtu_rtu_step_en              ),
  .dtu_rtu_sync_flush            (dtu_rtu_sync_flush           ),
  .dtu_rtu_sync_halt_req         (dtu_rtu_sync_halt_req        ),
  .forever_cpuclk                (forever_cpuclk               ),
  .hpcp_rtu_cnt_en               (hpcp_rtu_cnt_en              ),
  .ifu_rtu_reset_halt_req        (ifu_rtu_reset_halt_req       ),
  .ifu_rtu_warm_up               (ifu_rtu_warm_up              ),
  .iu_rtu_depd_lsu_chgflow_vld   (iu_rtu_depd_lsu_chgflow_vld  ),
  .iu_rtu_depd_lsu_next_pc       (iu_rtu_depd_lsu_next_pc      ),
  .iu_rtu_div_data               (iu_rtu_div_data              ),
  .iu_rtu_div_preg               (iu_rtu_div_preg              ),
  .iu_rtu_div_wb_dp              (iu_rtu_div_wb_dp             ),
  .iu_rtu_div_wb_vld             (iu_rtu_div_wb_vld            ),
  .iu_rtu_ex1_alu_cmplt          (iu_rtu_ex1_alu_cmplt         ),
  .iu_rtu_ex1_alu_cmplt_dp       (iu_rtu_ex1_alu_cmplt_dp      ),
  .iu_rtu_ex1_alu_data           (iu_rtu_ex1_alu_data          ),
  .iu_rtu_ex1_alu_inst_len       (iu_rtu_ex1_alu_inst_len      ),
  .iu_rtu_ex1_alu_inst_split     (iu_rtu_ex1_alu_inst_split    ),
  .iu_rtu_ex1_alu_preg           (iu_rtu_ex1_alu_preg          ),
  .iu_rtu_ex1_alu_wb_dp          (iu_rtu_ex1_alu_wb_dp         ),
  .iu_rtu_ex1_alu_wb_vld         (iu_rtu_ex1_alu_wb_vld        ),
  .iu_rtu_ex1_bju_cmplt          (iu_rtu_ex1_bju_cmplt         ),
  .iu_rtu_ex1_bju_cmplt_dp       (iu_rtu_ex1_bju_cmplt_dp      ),
  .iu_rtu_ex1_bju_data           (iu_rtu_ex1_bju_data          ),
  .iu_rtu_ex1_bju_inst_len       (iu_rtu_ex1_bju_inst_len      ),
  .iu_rtu_ex1_bju_preg           (iu_rtu_ex1_bju_preg          ),
  .iu_rtu_ex1_bju_wb_dp          (iu_rtu_ex1_bju_wb_dp         ),
  .iu_rtu_ex1_bju_wb_vld         (iu_rtu_ex1_bju_wb_vld        ),
  .iu_rtu_ex1_branch_inst        (iu_rtu_ex1_branch_inst       ),
  .iu_rtu_ex1_cur_pc             (iu_rtu_ex1_cur_pc            ),
  .iu_rtu_ex1_div_cmplt          (iu_rtu_ex1_div_cmplt         ),
  .iu_rtu_ex1_div_cmplt_dp       (iu_rtu_ex1_div_cmplt_dp      ),
  .iu_rtu_ex1_mul_cmplt          (iu_rtu_ex1_mul_cmplt         ),
  .iu_rtu_ex1_mul_cmplt_dp       (iu_rtu_ex1_mul_cmplt_dp      ),
  .iu_rtu_ex1_next_pc            (iu_rtu_ex1_next_pc           ),
  .iu_rtu_ex2_bju_ras_mispred    (iu_rtu_ex2_bju_ras_mispred   ),
  .iu_rtu_ex3_mul_data           (iu_rtu_ex3_mul_data          ),
  .iu_rtu_ex3_mul_preg           (iu_rtu_ex3_mul_preg          ),
  .iu_rtu_ex3_mul_wb_vld         (iu_rtu_ex3_mul_wb_vld        ),
  .iu_xx_no_op                   (iu_xx_no_op                  ),
  .lsu_rtu_async_expt_vld        (lsu_rtu_async_expt_vld       ),
  .lsu_rtu_async_ld_inst         (lsu_rtu_async_ld_inst        ),
  .lsu_rtu_async_tval            (lsu_rtu_async_tval           ),
  .lsu_rtu_ex1_buffer_vld        (lsu_rtu_ex1_buffer_vld       ),
  .lsu_rtu_ex1_cmplt             (lsu_rtu_ex1_cmplt            ),
  .lsu_rtu_ex1_cmplt_dp          (lsu_rtu_ex1_cmplt_dp         ),
  .lsu_rtu_ex1_cmplt_for_pcgen   (lsu_rtu_ex1_cmplt_for_pcgen  ),
  .lsu_rtu_ex1_data              (lsu_rtu_ex1_data             ),
  .lsu_rtu_ex1_dest_reg          (lsu_rtu_ex1_dest_reg         ),
  .lsu_rtu_ex1_expt_tval         (lsu_rtu_ex1_expt_tval        ),
  .lsu_rtu_ex1_expt_vec          (lsu_rtu_ex1_expt_vec         ),
  .lsu_rtu_ex1_expt_vld          (lsu_rtu_ex1_expt_vld         ),
  .lsu_rtu_ex1_fs_dirty          (lsu_rtu_ex1_fs_dirty         ),
  .lsu_rtu_ex1_halt_info         (lsu_rtu_ex1_halt_info        ),
  .lsu_rtu_ex1_inst_len          (lsu_rtu_ex1_inst_len         ),
  .lsu_rtu_ex1_inst_split        (lsu_rtu_ex1_inst_split       ),
  .lsu_rtu_ex1_tval2_vld         (lsu_rtu_ex1_tval2_vld        ),
  .lsu_rtu_ex1_vs_dirty          (lsu_rtu_ex1_vs_dirty         ),
  .lsu_rtu_ex1_vstart            (lsu_rtu_ex1_vstart           ),
  .lsu_rtu_ex1_vstart_vld        (lsu_rtu_ex1_vstart_vld       ),
  .lsu_rtu_ex1_wb_dp             (lsu_rtu_ex1_wb_dp            ),
  .lsu_rtu_ex1_wb_vld            (lsu_rtu_ex1_wb_vld           ),
  .lsu_rtu_ex2_data              (lsu_rtu_ex2_data             ),
  .lsu_rtu_ex2_data_vld          (lsu_rtu_ex2_data_vld         ),
  .lsu_rtu_ex2_dest_reg          (lsu_rtu_ex2_dest_reg         ),
  .lsu_rtu_ex2_tval2             (lsu_rtu_ex2_tval2            ),
  .lsu_rtu_no_op                 (lsu_rtu_no_op                ),
  .lsu_rtu_wb_data               (lsu_rtu_wb_data              ),
  .lsu_rtu_wb_dest_reg           (lsu_rtu_wb_dest_reg          ),
  .lsu_rtu_wb_vld                (lsu_rtu_wb_vld               ),
  .mmu_xx_mmu_en                 (mmu_xx_mmu_en                ),
  .pad_yy_icg_scan_en            (pad_yy_icg_scan_en           ),
  .rtu_cp0_epc                   (rtu_cp0_epc                  ),
  .rtu_cp0_exit_debug            (rtu_cp0_exit_debug           ),
  .rtu_cp0_fflags                (rtu_cp0_fflags               ),
  .rtu_cp0_fflags_updt           (rtu_cp0_fflags_updt          ),
  .rtu_cp0_fs_dirty_updt         (rtu_cp0_fs_dirty_updt        ),
  .rtu_cp0_fs_dirty_updt_dp      (rtu_cp0_fs_dirty_updt_dp     ),
  .rtu_cp0_tval                  (rtu_cp0_tval                 ),
  .rtu_cp0_vl                    (rtu_cp0_vl                   ),
  .rtu_cp0_vl_vld                (rtu_cp0_vl_vld               ),
  .rtu_cp0_vs_dirty_updt         (rtu_cp0_vs_dirty_updt        ),
  .rtu_cp0_vs_dirty_updt_dp      (rtu_cp0_vs_dirty_updt_dp     ),
  .rtu_cp0_vstart                (rtu_cp0_vstart               ),
  .rtu_cp0_vstart_vld            (rtu_cp0_vstart_vld           ),
  .rtu_cp0_vxsat                 (rtu_cp0_vxsat                ),
  .rtu_cp0_vxsat_vld             (rtu_cp0_vxsat_vld            ),
  .rtu_cpu_no_retire             (rtu_cpu_no_retire            ),
  .rtu_dtu_debug_info            (rtu_dtu_debug_info           ),
  .rtu_dtu_dpc                   (rtu_dtu_dpc                  ),
  .rtu_dtu_halt_ack              (rtu_dtu_halt_ack             ),
  .rtu_dtu_pending_ack           (rtu_dtu_pending_ack          ),
  .rtu_dtu_retire_chgflw         (rtu_dtu_retire_chgflw        ),
  .rtu_dtu_retire_debug_expt_vld (rtu_dtu_retire_debug_expt_vld),
  .rtu_dtu_retire_halt_info      (rtu_dtu_retire_halt_info     ),
  .rtu_dtu_retire_mret           (rtu_dtu_retire_mret          ),
  .rtu_dtu_retire_next_pc        (rtu_dtu_retire_next_pc       ),
  .rtu_dtu_retire_sret           (rtu_dtu_retire_sret          ),
  .rtu_dtu_retire_vld            (rtu_dtu_retire_vld           ),
  .rtu_dtu_tval                  (rtu_dtu_tval                 ),
  .rtu_hpcp_int_vld              (rtu_hpcp_int_vld             ),
  .rtu_hpcp_retire_inst_vld      (rtu_hpcp_retire_inst_vld     ),
  .rtu_hpcp_retire_pc            (rtu_hpcp_retire_pc           ),
  .rtu_idu_commit                (rtu_idu_commit               ),
  .rtu_idu_commit_for_bju        (rtu_idu_commit_for_bju       ),
  .rtu_idu_flush_fe              (rtu_idu_flush_fe             ),
  .rtu_idu_flush_stall           (rtu_idu_flush_stall          ),
  .rtu_idu_flush_wbt             (rtu_idu_flush_wbt            ),
  .rtu_idu_fwd0_data             (rtu_idu_fwd0_data            ),
  .rtu_idu_fwd0_reg              (rtu_idu_fwd0_reg             ),
  .rtu_idu_fwd0_vld              (rtu_idu_fwd0_vld             ),
  .rtu_idu_fwd1_data             (rtu_idu_fwd1_data            ),
  .rtu_idu_fwd1_reg              (rtu_idu_fwd1_reg             ),
  .rtu_idu_fwd1_vld              (rtu_idu_fwd1_vld             ),
  .rtu_idu_fwd2_data             (rtu_idu_fwd2_data            ),
  .rtu_idu_fwd2_reg              (rtu_idu_fwd2_reg             ),
  .rtu_idu_fwd2_vld              (rtu_idu_fwd2_vld             ),
  .rtu_idu_pipeline_empty        (rtu_idu_pipeline_empty       ),
  .rtu_idu_wb0_data              (rtu_idu_wb0_data             ),
  .rtu_idu_wb0_reg               (rtu_idu_wb0_reg              ),
  .rtu_idu_wb0_vld               (rtu_idu_wb0_vld              ),
  .rtu_idu_wb1_data              (rtu_idu_wb1_data             ),
  .rtu_idu_wb1_reg               (rtu_idu_wb1_reg              ),
  .rtu_idu_wb1_vld               (rtu_idu_wb1_vld              ),
  .rtu_ifu_chgflw_pc             (rtu_ifu_chgflw_pc            ),
  .rtu_ifu_chgflw_vld            (rtu_ifu_chgflw_vld           ),
  .rtu_ifu_dbg_mask              (rtu_ifu_dbg_mask             ),
  .rtu_ifu_flush_fe              (rtu_ifu_flush_fe             ),
  .rtu_iu_div_wb_grant           (rtu_iu_div_wb_grant          ),
  .rtu_iu_div_wb_grant_for_full  (rtu_iu_div_wb_grant_for_full ),
  .rtu_iu_ex1_cmplt              (rtu_iu_ex1_cmplt             ),
  .rtu_iu_ex1_cmplt_dp           (rtu_iu_ex1_cmplt_dp          ),
  .rtu_iu_ex1_inst_len           (rtu_iu_ex1_inst_len          ),
  .rtu_iu_ex1_inst_split         (rtu_iu_ex1_inst_split        ),
  .rtu_iu_ex2_cur_pc             (rtu_iu_ex2_cur_pc            ),
  .rtu_iu_ex2_next_pc            (rtu_iu_ex2_next_pc           ),
  .rtu_iu_mul_wb_grant           (rtu_iu_mul_wb_grant          ),
  .rtu_iu_mul_wb_grant_for_full  (rtu_iu_mul_wb_grant_for_full ),
  .rtu_lsu_async_expt_ack        (rtu_lsu_async_expt_ack       ),
  .rtu_lsu_expt_ack              (rtu_lsu_expt_ack             ),
  .rtu_lsu_expt_exit             (rtu_lsu_expt_exit            ),
  .rtu_mmu_bad_vpn               (rtu_mmu_bad_vpn              ),
  .rtu_mmu_expt_vld              (rtu_mmu_expt_vld             ),
  .rtu_pad_halted                (rtu_pad_halted               ),
  .rtu_pad_retire                (rtu_pad_retire               ),
  .rtu_pad_retire_pc             (rtu_pad_retire_pc            ),
  .rtu_vidu_flush_wbt            (rtu_vidu_flush_wbt           ),
  .rtu_vpu_gpr_wb_grnt           (rtu_vpu_gpr_wb_grnt          ),
  .rtu_yy_xx_async_flush         (rtu_yy_xx_async_flush        ),
  .rtu_yy_xx_dbgon               (rtu_yy_xx_dbgon              ),
  .rtu_yy_xx_expt_int            (rtu_yy_xx_expt_int           ),
  .rtu_yy_xx_expt_vec            (rtu_yy_xx_expt_vec           ),
  .rtu_yy_xx_expt_vld            (rtu_yy_xx_expt_vld           ),
  .rtu_yy_xx_flush               (rtu_yy_xx_flush              ),
  .rtu_yy_xx_flush_fe            (rtu_yy_xx_flush_fe           ),
  .vidu_rtu_no_op                (vidu_rtu_no_op               ),
  .vlsu_rtu_vl_updt_data         (vlsu_rtu_vl_updt_data        ),
  .vlsu_rtu_vl_updt_vld          (vlsu_rtu_vl_updt_vld         ),
  .vpu_rtu_ex1_cmplt             (vpu_rtu_ex1_cmplt            ),
  .vpu_rtu_ex1_cmplt_dp          (vpu_rtu_ex1_cmplt_dp         ),
  .vpu_rtu_ex1_fp_dirty          (vpu_rtu_ex1_fp_dirty         ),
  .vpu_rtu_ex1_vec_dirty         (vpu_rtu_ex1_vec_dirty        ),
  .vpu_rtu_fflag                 (vpu_rtu_fflag                ),
  .vpu_rtu_fflag_vld             (vpu_rtu_fflag_vld            ),
  .vpu_rtu_gpr_wb_data           (vpu_rtu_gpr_wb_data          ),
  .vpu_rtu_gpr_wb_index          (vpu_rtu_gpr_wb_index         ),
  .vpu_rtu_gpr_wb_req            (vpu_rtu_gpr_wb_req           ),
  .vpu_rtu_no_op                 (vpu_rtu_no_op                )
);

endmodule
