module program_counter_Bbehavioral
  (input  clk,
   input  rst,
   input  halt,
   input  jump,
   input  branch,
   input  branch_cond,
   input  [7:0] flag_rf,
   input  [7:0] jump_addr,
   output [7:0] pc_out);
  reg [7:0] pc_reg;
  wire rf_is_zero;
  wire branch_taken;
  wire n487;
  wire n488;
  wire n490;
  wire n491;
  wire n492;
  wire n493;
  wire n494;
  wire n495;
  wire [7:0] n500;
  wire [7:0] n501;
  wire [7:0] n502;
  wire [7:0] n503;
  reg [7:0] n508;
  assign pc_out = pc_reg; //(module output)
  /* ../program_counter.vhd:23:12  */
  always @*
    pc_reg = n508; // (isignal)
  initial
    pc_reg = 8'b00000000;
  /* ../program_counter.vhd:24:12  */
  assign rf_is_zero = n488; // (signal)
  /* ../program_counter.vhd:25:12  */
  assign branch_taken = n495; // (signal)
  /* ../program_counter.vhd:29:36  */
  assign n487 = flag_rf == 8'b00000000;
  /* ../program_counter.vhd:29:23  */
  assign n488 = n487 ? 1'b1 : 1'b0;
  /* ../program_counter.vhd:34:34  */
  assign n490 = ~branch_cond;
  /* ../program_counter.vhd:34:50  */
  assign n491 = n490 & rf_is_zero;
  /* ../program_counter.vhd:35:50  */
  assign n492 = ~rf_is_zero;
  /* ../program_counter.vhd:35:46  */
  assign n493 = branch_cond & n492;
  /* ../program_counter.vhd:34:66  */
  assign n494 = n491 | n493;
  /* ../program_counter.vhd:34:28  */
  assign n495 = branch & n494;
  /* ../program_counter.vhd:54:34  */
  assign n500 = pc_reg + 8'b00000001;
  /* ../program_counter.vhd:49:13  */
  assign n501 = branch_taken ? jump_addr : n500;
  /* ../program_counter.vhd:46:13  */
  assign n502 = jump ? jump_addr : n501;
  /* ../program_counter.vhd:43:13  */
  assign n503 = halt ? pc_reg : n502;
  /* ../program_counter.vhd:42:9  */
  always @(posedge clk or posedge rst)
    if (rst)
      n508 <= 8'b00000000;
    else
      n508 <= n503;
endmodule

module register_file_Bbehavioral
  (input  clk,
   input  rst,
   input  we,
   input  [1:0] sel_rs1,
   input  [1:0] sel_rs2,
   input  [1:0] sel_rd,
   input  [7:0] data_in,
   output [7:0] rs1_out,
   output [7:0] rs2_out,
   output [7:0] ro_out,
   output [7:0] rf_out);
  reg [31:0] registers;
  wire [1:0] n442;
  wire [31:0] n447;
  wire [1:0] n452;
  wire [1:0] n457;
  wire [7:0] n460;
  wire [7:0] n461;
  wire [31:0] n462;
  reg [31:0] n463;
  wire n464;
  wire n465;
  wire n466;
  wire n467;
  wire n468;
  wire n469;
  wire n470;
  wire n471;
  wire [7:0] n472;
  wire [7:0] n473;
  wire [7:0] n474;
  wire [7:0] n475;
  wire [7:0] n476;
  wire [7:0] n477;
  wire [7:0] n478;
  wire [7:0] n479;
  wire [31:0] n480;
  wire [7:0] n481;
  wire [7:0] n482;
  assign rs1_out = n481; //(module output)
  assign rs2_out = n482; //(module output)
  assign ro_out = n460; //(module output)
  assign rf_out = n461; //(module output)
  /* ../register_file.vhd:27:12  */
  always @*
    registers = n463; // (isignal)
  initial
    registers = 32'b00000000000000000000000000000000;
  /* ../register_file.vhd:40:27  */
  assign n442 = 2'b11 - sel_rd;
  /* ../register_file.vhd:33:9  */
  assign n447 = {8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};
  /* ../register_file.vhd:46:26  */
  assign n452 = 2'b11 - sel_rs1;
  /* ../register_file.vhd:47:26  */
  assign n457 = 2'b11 - sel_rs2;
  /* ../register_file.vhd:50:24  */
  assign n460 = registers[15:8]; // extract
  /* ../register_file.vhd:53:24  */
  assign n461 = registers[7:0]; // extract
  /* ../register_file.vhd:38:9  */
  assign n462 = we ? n480 : registers;
  /* ../register_file.vhd:38:9  */
  always @(posedge clk or posedge rst)
    if (rst)
      n463 <= n447;
    else
      n463 <= n462;
  /* ../register_file.vhd:40:17  */
  assign n464 = n442[1]; // extract
  /* ../register_file.vhd:40:17  */
  assign n465 = ~n464;
  /* ../register_file.vhd:40:17  */
  assign n466 = n442[0]; // extract
  /* ../register_file.vhd:40:17  */
  assign n467 = ~n466;
  /* ../register_file.vhd:40:17  */
  assign n468 = n465 & n467;
  /* ../register_file.vhd:40:17  */
  assign n469 = n465 & n466;
  /* ../register_file.vhd:40:17  */
  assign n470 = n464 & n467;
  /* ../register_file.vhd:40:17  */
  assign n471 = n464 & n466;
  /* ../register_file.vhd:40:17  */
  assign n472 = registers[7:0]; // extract
  /* ../register_file.vhd:40:17  */
  assign n473 = n468 ? data_in : n472;
  /* ../register_file.vhd:40:17  */
  assign n474 = registers[15:8]; // extract
  /* ../register_file.vhd:40:17  */
  assign n475 = n469 ? data_in : n474;
  /* ../register_file.vhd:40:17  */
  assign n476 = registers[23:16]; // extract
  /* ../register_file.vhd:40:17  */
  assign n477 = n470 ? data_in : n476;
  /* ../register_file.vhd:40:17  */
  assign n478 = registers[31:24]; // extract
  /* ../register_file.vhd:40:17  */
  assign n479 = n471 ? data_in : n478;
  /* ../register_file.vhd:40:17  */
  assign n480 = {n479, n477, n475, n473};
  /* ../register_file.vhd:46:26  */
  assign n481 = registers[n452 * 8 +: 8]; //(Bmux)
  /* ../register_file.vhd:47:26  */
  assign n482 = registers[n457 * 8 +: 8]; //(Bmux)
endmodule

module alu_Bbehavioral
  (input  [7:0] a,
   input  [7:0] b,
   input  [3:0] alu_op,
   output [7:0] result,
   output flag_eq,
   output flag_lt);
  reg [2:0] shift_amount;
  wire [2:0] n368;
  wire [7:0] n374;
  wire n376;
  wire [7:0] n377;
  wire n379;
  wire [7:0] n380;
  wire n382;
  wire [7:0] n383;
  wire n385;
  wire [7:0] n386;
  wire n388;
  wire [30:0] n389;
  wire [7:0] n390;
  wire n392;
  wire [30:0] n393;
  wire [7:0] n394;
  wire n396;
  wire n398;
  wire n399;
  wire [7:0] n402;
  wire n405;
  wire n407;
  wire n408;
  wire [7:0] n411;
  wire n414;
  wire n416;
  wire [9:0] n417;
  reg [7:0] n419;
  reg n422;
  reg n425;
  assign result = n419; //(module output)
  assign flag_eq = n422; //(module output)
  assign flag_lt = n425; //(module output)
  /* ../alu.vhd:20:12  */
  always @*
    shift_amount = n368; // (isignal)
  initial
    shift_amount = 3'b000;
  /* ../alu.vhd:23:42  */
  assign n368 = b[2:0]; // extract
  /* ../alu.vhd:39:55  */
  assign n374 = a + b;
  /* ../alu.vhd:38:13  */
  assign n376 = alu_op == 4'b0000;
  /* ../alu.vhd:42:55  */
  assign n377 = a - b;
  /* ../alu.vhd:41:13  */
  assign n379 = alu_op == 4'b0001;
  /* ../alu.vhd:45:29  */
  assign n380 = a & b;
  /* ../alu.vhd:44:13  */
  assign n382 = alu_op == 4'b0010;
  /* ../alu.vhd:48:29  */
  assign n383 = a | b;
  /* ../alu.vhd:47:13  */
  assign n385 = alu_op == 4'b0011;
  /* ../alu.vhd:51:29  */
  assign n386 = a ^ b;
  /* ../alu.vhd:50:13  */
  assign n388 = alu_op == 4'b0100;
  /* ../alu.vhd:54:67  */
  assign n389 = {28'b0, shift_amount};  //  uext
  /* ../alu.vhd:54:44  */
  assign n390 = a << n389;
  /* ../alu.vhd:53:13  */
  assign n392 = alu_op == 4'b0101;
  /* ../alu.vhd:57:68  */
  assign n393 = {28'b0, shift_amount};  //  uext
  /* ../alu.vhd:57:44  */
  assign n394 = a >> n393;
  /* ../alu.vhd:56:13  */
  assign n396 = alu_op == 4'b0110;
  /* ../alu.vhd:59:13  */
  assign n398 = alu_op == 4'b0111;
  /* ../alu.vhd:63:31  */
  assign n399 = $unsigned(a) < $unsigned(b);
  /* ../alu.vhd:63:17  */
  assign n402 = n399 ? 8'b00000001 : 8'b00000000;
  /* ../alu.vhd:63:17  */
  assign n405 = n399 ? 1'b1 : 1'b0;
  /* ../alu.vhd:62:13  */
  assign n407 = alu_op == 4'b1000;
  /* ../alu.vhd:72:31  */
  assign n408 = a == b;
  /* ../alu.vhd:72:17  */
  assign n411 = n408 ? 8'b00000001 : 8'b00000000;
  /* ../alu.vhd:72:17  */
  assign n414 = n408 ? 1'b1 : 1'b0;
  /* ../alu.vhd:71:13  */
  assign n416 = alu_op == 4'b1001;
  /* ../alu.vhd:37:9  */
  assign n417 = {n416, n407, n398, n396, n392, n388, n385, n382, n379, n376};
  /* ../alu.vhd:37:9  */
  always @*
    case (n417)
      10'b1000000000: n419 = n411;
      10'b0100000000: n419 = n402;
      10'b0010000000: n419 = a;
      10'b0001000000: n419 = n394;
      10'b0000100000: n419 = n390;
      10'b0000010000: n419 = n386;
      10'b0000001000: n419 = n383;
      10'b0000000100: n419 = n380;
      10'b0000000010: n419 = n377;
      10'b0000000001: n419 = n374;
      default: n419 = 8'b00000000;
    endcase
  /* ../alu.vhd:37:9  */
  always @*
    case (n417)
      10'b1000000000: n422 = n414;
      10'b0100000000: n422 = 1'b0;
      10'b0010000000: n422 = 1'b0;
      10'b0001000000: n422 = 1'b0;
      10'b0000100000: n422 = 1'b0;
      10'b0000010000: n422 = 1'b0;
      10'b0000001000: n422 = 1'b0;
      10'b0000000100: n422 = 1'b0;
      10'b0000000010: n422 = 1'b0;
      10'b0000000001: n422 = 1'b0;
      default: n422 = 1'b0;
    endcase
  /* ../alu.vhd:37:9  */
  always @*
    case (n417)
      10'b1000000000: n425 = 1'b0;
      10'b0100000000: n425 = n405;
      10'b0010000000: n425 = 1'b0;
      10'b0001000000: n425 = 1'b0;
      10'b0000100000: n425 = 1'b0;
      10'b0000010000: n425 = 1'b0;
      10'b0000001000: n425 = 1'b0;
      10'b0000000100: n425 = 1'b0;
      10'b0000000010: n425 = 1'b0;
      10'b0000000001: n425 = 1'b0;
      default: n425 = 1'b0;
    endcase
endmodule

module control_unit_Bbehavioral
  (input  [3:0] opcode,
   output reg_write,
   output [3:0] alu_op,
   output imm_sel,
   output jump,
   output branch,
   output branch_cond,
   output halt,
   output flag_write);
  wire n276;
  wire n278;
  wire n280;
  wire n282;
  wire n284;
  wire n286;
  wire n288;
  wire n290;
  wire n292;
  wire n294;
  wire n296;
  wire n298;
  wire n300;
  wire n302;
  wire n304;
  wire n306;
  wire [15:0] n307;
  reg n320;
  reg [3:0] n334;
  reg n338;
  reg n342;
  reg n347;
  reg n352;
  reg n356;
  reg n361;
  assign reg_write = n320; //(module output)
  assign alu_op = n334; //(module output)
  assign imm_sel = n338; //(module output)
  assign jump = n342; //(module output)
  assign branch = n347; //(module output)
  assign branch_cond = n352; //(module output)
  assign halt = n356; //(module output)
  assign flag_write = n361; //(module output)
  /* ../control_unit.vhd:37:13  */
  assign n276 = opcode == 4'b0000;
  /* ../control_unit.vhd:41:13  */
  assign n278 = opcode == 4'b0001;
  /* ../control_unit.vhd:45:13  */
  assign n280 = opcode == 4'b0010;
  /* ../control_unit.vhd:49:13  */
  assign n282 = opcode == 4'b0011;
  /* ../control_unit.vhd:53:13  */
  assign n284 = opcode == 4'b0100;
  /* ../control_unit.vhd:57:13  */
  assign n286 = opcode == 4'b0101;
  /* ../control_unit.vhd:61:13  */
  assign n288 = opcode == 4'b0110;
  /* ../control_unit.vhd:65:13  */
  assign n290 = opcode == 4'b0111;
  /* ../control_unit.vhd:70:13  */
  assign n292 = opcode == 4'b1000;
  /* ../control_unit.vhd:75:13  */
  assign n294 = opcode == 4'b1001;
  /* ../control_unit.vhd:81:13  */
  assign n296 = opcode == 4'b1010;
  /* ../control_unit.vhd:87:13  */
  assign n298 = opcode == 4'b1011;
  /* ../control_unit.vhd:90:13  */
  assign n300 = opcode == 4'b1100;
  /* ../control_unit.vhd:94:13  */
  assign n302 = opcode == 4'b1101;
  /* ../control_unit.vhd:99:13  */
  assign n304 = opcode == 4'b1110;
  /* ../control_unit.vhd:103:13  */
  assign n306 = opcode == 4'b1111;
  /* ../control_unit.vhd:35:9  */
  assign n307 = {n306, n304, n302, n300, n298, n296, n294, n292, n290, n288, n286, n284, n282, n280, n278, n276};
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n320 = 1'b0;
      16'b0100000000000000: n320 = 1'b0;
      16'b0010000000000000: n320 = 1'b0;
      16'b0001000000000000: n320 = 1'b0;
      16'b0000100000000000: n320 = 1'b0;
      16'b0000010000000000: n320 = 1'b1;
      16'b0000001000000000: n320 = 1'b1;
      16'b0000000100000000: n320 = 1'b1;
      16'b0000000010000000: n320 = 1'b1;
      16'b0000000001000000: n320 = 1'b1;
      16'b0000000000100000: n320 = 1'b1;
      16'b0000000000010000: n320 = 1'b1;
      16'b0000000000001000: n320 = 1'b1;
      16'b0000000000000100: n320 = 1'b1;
      16'b0000000000000010: n320 = 1'b1;
      16'b0000000000000001: n320 = 1'b1;
      default: n320 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n334 = 4'b0000;
      16'b0100000000000000: n334 = 4'b0000;
      16'b0010000000000000: n334 = 4'b0000;
      16'b0001000000000000: n334 = 4'b0000;
      16'b0000100000000000: n334 = 4'b0000;
      16'b0000010000000000: n334 = 4'b0111;
      16'b0000001000000000: n334 = 4'b1001;
      16'b0000000100000000: n334 = 4'b1000;
      16'b0000000010000000: n334 = 4'b0111;
      16'b0000000001000000: n334 = 4'b0110;
      16'b0000000000100000: n334 = 4'b0101;
      16'b0000000000010000: n334 = 4'b0100;
      16'b0000000000001000: n334 = 4'b0011;
      16'b0000000000000100: n334 = 4'b0010;
      16'b0000000000000010: n334 = 4'b0001;
      16'b0000000000000001: n334 = 4'b0000;
      default: n334 = 4'b0000;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n338 = 1'b0;
      16'b0100000000000000: n338 = 1'b0;
      16'b0010000000000000: n338 = 1'b0;
      16'b0001000000000000: n338 = 1'b0;
      16'b0000100000000000: n338 = 1'b0;
      16'b0000010000000000: n338 = 1'b1;
      16'b0000001000000000: n338 = 1'b0;
      16'b0000000100000000: n338 = 1'b0;
      16'b0000000010000000: n338 = 1'b0;
      16'b0000000001000000: n338 = 1'b0;
      16'b0000000000100000: n338 = 1'b0;
      16'b0000000000010000: n338 = 1'b0;
      16'b0000000000001000: n338 = 1'b0;
      16'b0000000000000100: n338 = 1'b0;
      16'b0000000000000010: n338 = 1'b0;
      16'b0000000000000001: n338 = 1'b0;
      default: n338 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n342 = 1'b0;
      16'b0100000000000000: n342 = 1'b0;
      16'b0010000000000000: n342 = 1'b0;
      16'b0001000000000000: n342 = 1'b0;
      16'b0000100000000000: n342 = 1'b1;
      16'b0000010000000000: n342 = 1'b0;
      16'b0000001000000000: n342 = 1'b0;
      16'b0000000100000000: n342 = 1'b0;
      16'b0000000010000000: n342 = 1'b0;
      16'b0000000001000000: n342 = 1'b0;
      16'b0000000000100000: n342 = 1'b0;
      16'b0000000000010000: n342 = 1'b0;
      16'b0000000000001000: n342 = 1'b0;
      16'b0000000000000100: n342 = 1'b0;
      16'b0000000000000010: n342 = 1'b0;
      16'b0000000000000001: n342 = 1'b0;
      default: n342 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n347 = 1'b0;
      16'b0100000000000000: n347 = 1'b0;
      16'b0010000000000000: n347 = 1'b1;
      16'b0001000000000000: n347 = 1'b1;
      16'b0000100000000000: n347 = 1'b0;
      16'b0000010000000000: n347 = 1'b0;
      16'b0000001000000000: n347 = 1'b0;
      16'b0000000100000000: n347 = 1'b0;
      16'b0000000010000000: n347 = 1'b0;
      16'b0000000001000000: n347 = 1'b0;
      16'b0000000000100000: n347 = 1'b0;
      16'b0000000000010000: n347 = 1'b0;
      16'b0000000000001000: n347 = 1'b0;
      16'b0000000000000100: n347 = 1'b0;
      16'b0000000000000010: n347 = 1'b0;
      16'b0000000000000001: n347 = 1'b0;
      default: n347 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n352 = 1'b0;
      16'b0100000000000000: n352 = 1'b0;
      16'b0010000000000000: n352 = 1'b1;
      16'b0001000000000000: n352 = 1'b0;
      16'b0000100000000000: n352 = 1'b0;
      16'b0000010000000000: n352 = 1'b0;
      16'b0000001000000000: n352 = 1'b0;
      16'b0000000100000000: n352 = 1'b0;
      16'b0000000010000000: n352 = 1'b0;
      16'b0000000001000000: n352 = 1'b0;
      16'b0000000000100000: n352 = 1'b0;
      16'b0000000000010000: n352 = 1'b0;
      16'b0000000000001000: n352 = 1'b0;
      16'b0000000000000100: n352 = 1'b0;
      16'b0000000000000010: n352 = 1'b0;
      16'b0000000000000001: n352 = 1'b0;
      default: n352 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n356 = 1'b1;
      16'b0100000000000000: n356 = 1'b0;
      16'b0010000000000000: n356 = 1'b0;
      16'b0001000000000000: n356 = 1'b0;
      16'b0000100000000000: n356 = 1'b0;
      16'b0000010000000000: n356 = 1'b0;
      16'b0000001000000000: n356 = 1'b0;
      16'b0000000100000000: n356 = 1'b0;
      16'b0000000010000000: n356 = 1'b0;
      16'b0000000001000000: n356 = 1'b0;
      16'b0000000000100000: n356 = 1'b0;
      16'b0000000000010000: n356 = 1'b0;
      16'b0000000000001000: n356 = 1'b0;
      16'b0000000000000100: n356 = 1'b0;
      16'b0000000000000010: n356 = 1'b0;
      16'b0000000000000001: n356 = 1'b0;
      default: n356 = 1'b0;
    endcase
  /* ../control_unit.vhd:35:9  */
  always @*
    case (n307)
      16'b1000000000000000: n361 = 1'b0;
      16'b0100000000000000: n361 = 1'b0;
      16'b0010000000000000: n361 = 1'b0;
      16'b0001000000000000: n361 = 1'b0;
      16'b0000100000000000: n361 = 1'b0;
      16'b0000010000000000: n361 = 1'b0;
      16'b0000001000000000: n361 = 1'b1;
      16'b0000000100000000: n361 = 1'b1;
      16'b0000000010000000: n361 = 1'b0;
      16'b0000000001000000: n361 = 1'b0;
      16'b0000000000100000: n361 = 1'b0;
      16'b0000000000010000: n361 = 1'b0;
      16'b0000000000001000: n361 = 1'b0;
      16'b0000000000000100: n361 = 1'b0;
      16'b0000000000000010: n361 = 1'b0;
      16'b0000000000000001: n361 = 1'b0;
      default: n361 = 1'b0;
    endcase
endmodule

module instruction_decoder_Bbehavioral
  (input  [15:0] instruction,
   output [3:0] opcode,
   output [1:0] rs1,
   output [1:0] rs2,
   output [1:0] rd,
   output [7:0] immediate);
  wire [3:0] n260;
  wire [1:0] n261;
  wire [1:0] n262;
  wire [1:0] n263;
  wire [7:0] n264;
  assign opcode = n260; //(module output)
  assign rs1 = n261; //(module output)
  assign rs2 = n262; //(module output)
  assign rd = n263; //(module output)
  assign immediate = n264; //(module output)
  /* ../instruction_decoder.vhd:21:29  */
  assign n260 = instruction[15:12]; // extract
  /* ../instruction_decoder.vhd:22:29  */
  assign n261 = instruction[11:10]; // extract
  /* ../instruction_decoder.vhd:23:29  */
  assign n262 = instruction[9:8]; // extract
  /* ../instruction_decoder.vhd:24:29  */
  assign n263 = instruction[7:6]; // extract
  /* ../instruction_decoder.vhd:25:29  */
  assign n264 = instruction[7:0]; // extract
endmodule

module hex_to_7seg_Bbehavioral
  (input  [3:0] hex_val,
   output [6:0] segments);
  wire n204;
  wire n206;
  wire n208;
  wire n210;
  wire n212;
  wire n214;
  wire n216;
  wire n218;
  wire n220;
  wire n222;
  wire n224;
  wire n226;
  wire n228;
  wire n230;
  wire n232;
  wire n234;
  wire [15:0] n235;
  reg [6:0] n253;
  assign segments = n253; //(module output)
  /* hex_to_7seg.vhd:22:13  */
  assign n204 = hex_val == 4'b0000;
  /* hex_to_7seg.vhd:23:13  */
  assign n206 = hex_val == 4'b0001;
  /* hex_to_7seg.vhd:24:13  */
  assign n208 = hex_val == 4'b0010;
  /* hex_to_7seg.vhd:25:13  */
  assign n210 = hex_val == 4'b0011;
  /* hex_to_7seg.vhd:26:13  */
  assign n212 = hex_val == 4'b0100;
  /* hex_to_7seg.vhd:27:13  */
  assign n214 = hex_val == 4'b0101;
  /* hex_to_7seg.vhd:28:13  */
  assign n216 = hex_val == 4'b0110;
  /* hex_to_7seg.vhd:29:13  */
  assign n218 = hex_val == 4'b0111;
  /* hex_to_7seg.vhd:30:13  */
  assign n220 = hex_val == 4'b1000;
  /* hex_to_7seg.vhd:31:13  */
  assign n222 = hex_val == 4'b1001;
  /* hex_to_7seg.vhd:32:13  */
  assign n224 = hex_val == 4'b1010;
  /* hex_to_7seg.vhd:33:13  */
  assign n226 = hex_val == 4'b1011;
  /* hex_to_7seg.vhd:34:13  */
  assign n228 = hex_val == 4'b1100;
  /* hex_to_7seg.vhd:35:13  */
  assign n230 = hex_val == 4'b1101;
  /* hex_to_7seg.vhd:36:13  */
  assign n232 = hex_val == 4'b1110;
  /* hex_to_7seg.vhd:37:13  */
  assign n234 = hex_val == 4'b1111;
  /* hex_to_7seg.vhd:20:9  */
  assign n235 = {n234, n232, n230, n228, n226, n224, n222, n220, n218, n216, n214, n212, n210, n208, n206, n204};
  /* hex_to_7seg.vhd:20:9  */
  always @*
    case (n235)
      16'b1000000000000000: n253 = 7'b1000111;
      16'b0100000000000000: n253 = 7'b1001111;
      16'b0010000000000000: n253 = 7'b0111101;
      16'b0001000000000000: n253 = 7'b1001110;
      16'b0000100000000000: n253 = 7'b0011111;
      16'b0000010000000000: n253 = 7'b1110111;
      16'b0000001000000000: n253 = 7'b1111011;
      16'b0000000100000000: n253 = 7'b1111111;
      16'b0000000010000000: n253 = 7'b1110000;
      16'b0000000001000000: n253 = 7'b1011111;
      16'b0000000000100000: n253 = 7'b1011011;
      16'b0000000000010000: n253 = 7'b0110011;
      16'b0000000000001000: n253 = 7'b1111001;
      16'b0000000000000100: n253 = 7'b1101101;
      16'b0000000000000010: n253 = 7'b0110000;
      16'b0000000000000001: n253 = 7'b1111110;
      default: n253 = 7'b0000000;
    endcase
endmodule

module ee8_cpu_Bstructural
  (input  clk,
   input  rst,
   input  [15:0] rom_data,
   output [7:0] rom_addr,
   output [7:0] seven_seg);
  wire [3:0] opcode;
  wire [1:0] rs1_sel;
  wire [1:0] rs2_sel;
  wire [1:0] rd_sel;
  wire [7:0] immediate;
  wire reg_write;
  wire [3:0] alu_op;
  wire imm_sel;
  wire jump;
  wire branch;
  wire branch_cond;
  wire halt;
  wire flag_write;
  wire [7:0] rs1_data;
  wire [7:0] rs2_data;
  wire [7:0] rf_data;
  wire [7:0] alu_a;
  wire [7:0] alu_result;
  wire [7:0] reg_data_in;
  wire [1:0] reg_rd_sel;
  wire [7:0] pc_value;
  wire [3:0] inst_decoder_n133;
  wire [1:0] inst_decoder_n134;
  wire [1:0] inst_decoder_n135;
  wire [1:0] inst_decoder_n136;
  wire [7:0] inst_decoder_n137;
  wire ctrl_unit_n148;
  wire [3:0] ctrl_unit_n149;
  wire ctrl_unit_n150;
  wire ctrl_unit_n151;
  wire ctrl_unit_n152;
  wire ctrl_unit_n153;
  wire ctrl_unit_n154;
  wire ctrl_unit_n155;
  wire [7:0] n172;
  wire [7:0] alu_inst_n173;
  wire \alu_inst.flag_eq ;
  wire \alu_inst.flag_lt ;
  wire [1:0] n183;
  wire [1:0] n184;
  wire [7:0] reg_file_n185;
  wire [7:0] reg_file_n186;
  wire [7:0] reg_file_n187;
  wire [7:0] reg_file_n188;
  wire [7:0] pc_inst_n197;
  assign rom_addr = pc_value; //(module output)
  assign seven_seg = reg_file_n187; //(module output)
  /* ../ee8_cpu.vhd:87:12  */
  assign opcode = inst_decoder_n133; // (signal)
  /* ../ee8_cpu.vhd:88:12  */
  assign rs1_sel = inst_decoder_n134; // (signal)
  /* ../ee8_cpu.vhd:89:12  */
  assign rs2_sel = inst_decoder_n135; // (signal)
  /* ../ee8_cpu.vhd:90:12  */
  assign rd_sel = inst_decoder_n136; // (signal)
  /* ../ee8_cpu.vhd:91:12  */
  assign immediate = inst_decoder_n137; // (signal)
  /* ../ee8_cpu.vhd:94:12  */
  assign reg_write = ctrl_unit_n148; // (signal)
  /* ../ee8_cpu.vhd:95:12  */
  assign alu_op = ctrl_unit_n149; // (signal)
  /* ../ee8_cpu.vhd:96:12  */
  assign imm_sel = ctrl_unit_n150; // (signal)
  /* ../ee8_cpu.vhd:97:12  */
  assign jump = ctrl_unit_n151; // (signal)
  /* ../ee8_cpu.vhd:98:12  */
  assign branch = ctrl_unit_n152; // (signal)
  /* ../ee8_cpu.vhd:99:12  */
  assign branch_cond = ctrl_unit_n153; // (signal)
  /* ../ee8_cpu.vhd:100:12  */
  assign halt = ctrl_unit_n154; // (signal)
  /* ../ee8_cpu.vhd:101:12  */
  assign flag_write = ctrl_unit_n155; // (signal)
  /* ../ee8_cpu.vhd:104:12  */
  assign rs1_data = reg_file_n185; // (signal)
  /* ../ee8_cpu.vhd:105:12  */
  assign rs2_data = reg_file_n186; // (signal)
  /* ../ee8_cpu.vhd:106:12  */
  assign rf_data = reg_file_n188; // (signal)
  /* ../ee8_cpu.vhd:109:12  */
  assign alu_a = n172; // (signal)
  /* ../ee8_cpu.vhd:110:12  */
  assign alu_result = alu_inst_n173; // (signal)
  /* ../ee8_cpu.vhd:115:12  */
  assign reg_data_in = alu_result; // (signal)
  /* ../ee8_cpu.vhd:116:12  */
  assign reg_rd_sel = n183; // (signal)
  /* ../ee8_cpu.vhd:119:12  */
  assign pc_value = pc_inst_n197; // (signal)
  /* ../ee8_cpu.vhd:124:5  */
  instruction_decoder_Bbehavioral inst_decoder (
    .instruction(rom_data),
    .opcode(inst_decoder_n133),
    .rs1(inst_decoder_n134),
    .rs2(inst_decoder_n135),
    .rd(inst_decoder_n136),
    .immediate(inst_decoder_n137));
  /* ../ee8_cpu.vhd:135:5  */
  control_unit_Bbehavioral ctrl_unit (
    .opcode(opcode),
    .reg_write(ctrl_unit_n148),
    .alu_op(ctrl_unit_n149),
    .imm_sel(ctrl_unit_n150),
    .jump(ctrl_unit_n151),
    .branch(ctrl_unit_n152),
    .branch_cond(ctrl_unit_n153),
    .halt(ctrl_unit_n154),
    .flag_write(ctrl_unit_n155));
  /* ../ee8_cpu.vhd:150:24  */
  assign n172 = imm_sel ? immediate : rs1_data;
  /* ../ee8_cpu.vhd:153:5  */
  alu_Bbehavioral alu_inst (
    .a(alu_a),
    .b(rs2_data),
    .alu_op(alu_op),
    .result(alu_inst_n173),
    .flag_eq(),
    .flag_lt());
  /* ../ee8_cpu.vhd:167:24  */
  assign n183 = flag_write ? 2'b11 : n184;
  /* ../ee8_cpu.vhd:167:46  */
  assign n184 = imm_sel ? rs1_sel : rd_sel;
  /* ../ee8_cpu.vhd:175:5  */
  register_file_Bbehavioral reg_file (
    .clk(clk),
    .rst(rst),
    .we(reg_write),
    .sel_rs1(rs1_sel),
    .sel_rs2(rs2_sel),
    .sel_rd(reg_rd_sel),
    .data_in(reg_data_in),
    .rs1_out(reg_file_n185),
    .rs2_out(reg_file_n186),
    .ro_out(reg_file_n187),
    .rf_out(reg_file_n188));
  /* ../ee8_cpu.vhd:191:5  */
  program_counter_Bbehavioral pc_inst (
    .clk(clk),
    .rst(rst),
    .halt(halt),
    .jump(jump),
    .branch(branch),
    .branch_cond(branch_cond),
    .flag_rf(rf_data),
    .jump_addr(immediate),
    .pc_out(pc_inst_n197));
endmodule

module rom_count5_Bbehavioral
  (input  [3:0] addr,
   output [15:0] data);
  wire [15:0] n130; // mem_rd
  assign data = n130; //(module output)
  /* ../rom_count5.vhd:33:22  */
  reg [15:0] n128[15:0] ; // memory
  initial begin
    n128[15] = 16'b1111000000000000;
    n128[14] = 16'b1111000000000000;
    n128[13] = 16'b1111000000000000;
    n128[12] = 16'b1111000000000000;
    n128[11] = 16'b1111000000000000;
    n128[10] = 16'b1111000000000000;
    n128[9] = 16'b1111000000000000;
    n128[8] = 16'b1111000000000000;
    n128[7] = 16'b1111000000000000;
    n128[6] = 16'b1011000000000011;
    n128[5] = 16'b0000011010000000;
    n128[4] = 16'b1100110000000010;
    n128[3] = 16'b1000100000000000;
    n128[2] = 16'b1010100000000000;
    n128[1] = 16'b1010010000000001;
    n128[0] = 16'b1010000000000101;
    end
  assign n130 = n128[addr];
  /* ../rom_count5.vhd:33:22  */
endmodule

module rom_Bbehavioral
  (input  [3:0] addr,
   output [15:0] data);
  wire [15:0] n120; // mem_rd
  assign data = n120; //(module output)
  /* ../rom.vhd:76:22  */
  reg [15:0] n118[15:0] ; // memory
  initial begin
    n118[15] = 16'b1111000000000000;
    n118[14] = 16'b1111000000000000;
    n118[13] = 16'b1011000000001000;
    n118[12] = 16'b0110000100000000;
    n118[11] = 16'b1101000000000010;
    n118[10] = 16'b1001001100000000;
    n118[9] = 16'b1010110000000001;
    n118[8] = 16'b0111000010000000;
    n118[7] = 16'b1011000000000010;
    n118[6] = 16'b0101000100000000;
    n118[5] = 16'b1101000000001000;
    n118[4] = 16'b1001001100000000;
    n118[3] = 16'b1010110010000000;
    n118[2] = 16'b0111000010000000;
    n118[1] = 16'b1010010000000001;
    n118[0] = 16'b1010000000000001;
    end
  assign n120 = n118[addr];
  /* ../rom.vhd:76:22  */
endmodule

module go_board_top
  (input  i_Clk,
   input  i_Switch_1,
   input  i_Switch_2,
   input  i_Switch_3,
   input  i_Switch_4,
   output o_LED_1,
   output o_LED_2,
   output o_LED_3,
   output o_LED_4,
   output o_Segment1_A,
   output o_Segment1_B,
   output o_Segment1_C,
   output o_Segment1_D,
   output o_Segment1_E,
   output o_Segment1_F,
   output o_Segment1_G,
   output o_Segment2_A,
   output o_Segment2_B,
   output o_Segment2_C,
   output o_Segment2_D,
   output o_Segment2_E,
   output o_Segment2_F,
   output o_Segment2_G);
  reg [1:0] sw1_sync;
  reg [1:0] sw2_sync;
  reg [1:0] sw3_sync;
  reg [1:0] sw4_sync;
  wire pause;
  wire reset;
  wire rom_sel;
  wire disp_sel;
  reg [21:0] clk_counter;
  wire slow_clk;
  wire [7:0] rom_addr;
  wire [15:0] rom_data;
  wire [15:0] rom1_data;
  wire [15:0] rom2_data;
  wire [7:0] ro_data;
  wire [7:0] display_data;
  wire [6:0] seg1_active;
  wire [6:0] seg2_active;
  wire n26;
  wire [1:0] n27;
  wire n28;
  wire [1:0] n29;
  wire n30;
  wire [1:0] n31;
  wire n32;
  wire [1:0] n33;
  wire n39;
  wire n40;
  wire n41;
  wire n42;
  wire n46;
  wire [21:0] n48;
  wire n52;
  wire [3:0] n53;
  wire [15:0] rom_default_n54;
  wire [3:0] n57;
  wire [15:0] rom_count_n58;
  wire [15:0] n61;
  wire [7:0] cpu_inst_n62;
  wire [7:0] cpu_inst_n63;
  wire [7:0] n68;
  wire [3:0] n69;
  wire [6:0] seg_high_n70;
  wire [3:0] n73;
  wire [6:0] seg_low_n74;
  wire n77;
  wire n78;
  wire n79;
  wire n80;
  wire n81;
  wire n82;
  wire n83;
  wire n84;
  wire n85;
  wire n86;
  wire n87;
  wire n88;
  wire n89;
  wire n90;
  wire n91;
  wire n92;
  wire n93;
  wire n94;
  wire n95;
  wire n96;
  wire n97;
  wire n98;
  wire n99;
  wire n100;
  wire n101;
  wire n102;
  wire n103;
  wire n104;
  reg [1:0] n105;
  reg [1:0] n106;
  reg [1:0] n107;
  reg [1:0] n108;
  wire [21:0] n109;
  reg [21:0] n110;
  assign o_LED_1 = slow_clk; //(module output)
  assign o_LED_2 = pause; //(module output)
  assign o_LED_3 = rom_sel; //(module output)
  assign o_LED_4 = disp_sel; //(module output)
  assign o_Segment1_A = n78; //(module output)
  assign o_Segment1_B = n80; //(module output)
  assign o_Segment1_C = n82; //(module output)
  assign o_Segment1_D = n84; //(module output)
  assign o_Segment1_E = n86; //(module output)
  assign o_Segment1_F = n88; //(module output)
  assign o_Segment1_G = n90; //(module output)
  assign o_Segment2_A = n92; //(module output)
  assign o_Segment2_B = n94; //(module output)
  assign o_Segment2_C = n96; //(module output)
  assign o_Segment2_D = n98; //(module output)
  assign o_Segment2_E = n100; //(module output)
  assign o_Segment2_F = n102; //(module output)
  assign o_Segment2_G = n104; //(module output)
  /* go_board_top.vhd:78:12  */
  always @*
    sw1_sync = n105; // (isignal)
  initial
    sw1_sync = 2'b00;
  /* go_board_top.vhd:79:12  */
  always @*
    sw2_sync = n106; // (isignal)
  initial
    sw2_sync = 2'b00;
  /* go_board_top.vhd:80:12  */
  always @*
    sw3_sync = n107; // (isignal)
  initial
    sw3_sync = 2'b00;
  /* go_board_top.vhd:81:12  */
  always @*
    sw4_sync = n108; // (isignal)
  initial
    sw4_sync = 2'b00;
  /* go_board_top.vhd:82:12  */
  assign pause = n39; // (signal)
  /* go_board_top.vhd:83:12  */
  assign reset = n40; // (signal)
  /* go_board_top.vhd:84:12  */
  assign rom_sel = n41; // (signal)
  /* go_board_top.vhd:85:12  */
  assign disp_sel = n42; // (signal)
  /* go_board_top.vhd:88:12  */
  always @*
    clk_counter = n110; // (isignal)
  initial
    clk_counter = 22'b0000000000000000000000;
  /* go_board_top.vhd:89:12  */
  assign slow_clk = n52; // (signal)
  /* go_board_top.vhd:92:12  */
  assign rom_addr = cpu_inst_n62; // (signal)
  /* go_board_top.vhd:93:12  */
  assign rom_data = n61; // (signal)
  /* go_board_top.vhd:94:12  */
  assign rom1_data = rom_default_n54; // (signal)
  /* go_board_top.vhd:95:12  */
  assign rom2_data = rom_count_n58; // (signal)
  /* go_board_top.vhd:98:12  */
  assign ro_data = cpu_inst_n63; // (signal)
  /* go_board_top.vhd:101:12  */
  assign display_data = n68; // (signal)
  /* go_board_top.vhd:104:12  */
  assign seg1_active = seg_high_n70; // (signal)
  /* go_board_top.vhd:105:12  */
  assign seg2_active = seg_low_n74; // (signal)
  /* go_board_top.vhd:115:33  */
  assign n26 = sw1_sync[0]; // extract
  /* go_board_top.vhd:115:37  */
  assign n27 = {n26, i_Switch_1};
  /* go_board_top.vhd:116:33  */
  assign n28 = sw2_sync[0]; // extract
  /* go_board_top.vhd:116:37  */
  assign n29 = {n28, i_Switch_2};
  /* go_board_top.vhd:117:33  */
  assign n30 = sw3_sync[0]; // extract
  /* go_board_top.vhd:117:37  */
  assign n31 = {n30, i_Switch_3};
  /* go_board_top.vhd:118:33  */
  assign n32 = sw4_sync[0]; // extract
  /* go_board_top.vhd:118:37  */
  assign n33 = {n32, i_Switch_4};
  /* go_board_top.vhd:122:25  */
  assign n39 = sw1_sync[1]; // extract
  /* go_board_top.vhd:123:25  */
  assign n40 = sw2_sync[1]; // extract
  /* go_board_top.vhd:124:25  */
  assign n41 = sw3_sync[1]; // extract
  /* go_board_top.vhd:125:25  */
  assign n42 = sw4_sync[1]; // extract
  /* go_board_top.vhd:133:22  */
  assign n46 = ~pause;
  /* go_board_top.vhd:134:44  */
  assign n48 = clk_counter + 22'b0000000000000000000001;
  /* go_board_top.vhd:139:38  */
  assign n52 = clk_counter[21]; // extract
  /* go_board_top.vhd:146:29  */
  assign n53 = rom_addr[3:0]; // extract
  /* go_board_top.vhd:144:5  */
  rom_Bbehavioral rom_default (
    .addr(n53),
    .data(rom_default_n54));
  /* go_board_top.vhd:152:29  */
  assign n57 = rom_addr[3:0]; // extract
  /* go_board_top.vhd:150:5  */
  rom_count5_Bbehavioral rom_count (
    .addr(n57),
    .data(rom_count_n58));
  /* go_board_top.vhd:156:27  */
  assign n61 = rom_sel ? rom2_data : rom1_data;
  /* go_board_top.vhd:161:5  */
  ee8_cpu_Bstructural cpu_inst (
    .clk(slow_clk),
    .rst(reset),
    .rom_data(rom_data),
    .rom_addr(cpu_inst_n62),
    .seven_seg(cpu_inst_n63));
  /* go_board_top.vhd:173:30  */
  assign n68 = disp_sel ? rom_addr : ro_data;
  /* go_board_top.vhd:180:37  */
  assign n69 = display_data[7:4]; // extract
  /* go_board_top.vhd:178:5  */
  hex_to_7seg_Bbehavioral seg_high (
    .hex_val(n69),
    .segments(seg_high_n70));
  /* go_board_top.vhd:186:37  */
  assign n73 = display_data[3:0]; // extract
  /* go_board_top.vhd:184:5  */
  hex_to_7seg_Bbehavioral seg_low (
    .hex_val(n73),
    .segments(seg_low_n74));
  /* go_board_top.vhd:191:36  */
  assign n77 = seg1_active[6]; // extract
  /* go_board_top.vhd:191:21  */
  assign n78 = ~n77;
  /* go_board_top.vhd:192:36  */
  assign n79 = seg1_active[5]; // extract
  /* go_board_top.vhd:192:21  */
  assign n80 = ~n79;
  /* go_board_top.vhd:193:36  */
  assign n81 = seg1_active[4]; // extract
  /* go_board_top.vhd:193:21  */
  assign n82 = ~n81;
  /* go_board_top.vhd:194:36  */
  assign n83 = seg1_active[3]; // extract
  /* go_board_top.vhd:194:21  */
  assign n84 = ~n83;
  /* go_board_top.vhd:195:36  */
  assign n85 = seg1_active[2]; // extract
  /* go_board_top.vhd:195:21  */
  assign n86 = ~n85;
  /* go_board_top.vhd:196:36  */
  assign n87 = seg1_active[1]; // extract
  /* go_board_top.vhd:196:21  */
  assign n88 = ~n87;
  /* go_board_top.vhd:197:36  */
  assign n89 = seg1_active[0]; // extract
  /* go_board_top.vhd:197:21  */
  assign n90 = ~n89;
  /* go_board_top.vhd:199:36  */
  assign n91 = seg2_active[6]; // extract
  /* go_board_top.vhd:199:21  */
  assign n92 = ~n91;
  /* go_board_top.vhd:200:36  */
  assign n93 = seg2_active[5]; // extract
  /* go_board_top.vhd:200:21  */
  assign n94 = ~n93;
  /* go_board_top.vhd:201:36  */
  assign n95 = seg2_active[4]; // extract
  /* go_board_top.vhd:201:21  */
  assign n96 = ~n95;
  /* go_board_top.vhd:202:36  */
  assign n97 = seg2_active[3]; // extract
  /* go_board_top.vhd:202:21  */
  assign n98 = ~n97;
  /* go_board_top.vhd:203:36  */
  assign n99 = seg2_active[2]; // extract
  /* go_board_top.vhd:203:21  */
  assign n100 = ~n99;
  /* go_board_top.vhd:204:36  */
  assign n101 = seg2_active[1]; // extract
  /* go_board_top.vhd:204:21  */
  assign n102 = ~n101;
  /* go_board_top.vhd:205:36  */
  assign n103 = seg2_active[0]; // extract
  /* go_board_top.vhd:205:21  */
  assign n104 = ~n103;
  /* go_board_top.vhd:114:9  */
  always @(posedge i_Clk)
    n105 <= n27;
  initial
    n105 = 2'b00;
  /* go_board_top.vhd:114:9  */
  always @(posedge i_Clk)
    n106 <= n29;
  initial
    n106 = 2'b00;
  /* go_board_top.vhd:114:9  */
  always @(posedge i_Clk)
    n107 <= n31;
  initial
    n107 = 2'b00;
  /* go_board_top.vhd:114:9  */
  always @(posedge i_Clk)
    n108 <= n33;
  initial
    n108 = 2'b00;
  /* go_board_top.vhd:132:9  */
  assign n109 = n46 ? n48 : clk_counter;
  /* go_board_top.vhd:132:9  */
  always @(posedge i_Clk)
    n110 <= n109;
  initial
    n110 = 22'b0000000000000000000000;
endmodule

