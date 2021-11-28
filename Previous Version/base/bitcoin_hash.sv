`include "simplified_sha256.sv"

module bitcoin_hash (input logic        clk, reset_n, start,
                     input logic [15:0] message_addr, output_addr,
                    output logic        done, mem_clk, mem_we,
                    output logic [15:0] mem_addr,
                    output logic [31:0] mem_write_data,
                     input logic [31:0] mem_read_data);

parameter num_nonces = 16;

enum logic [ 3:0] {IDLE, REST, READ, START1, BUFFER1, PHASE2, START2, BUFFER2, PHASE3, START3, BUFFER3, WRITE}state;
logic [31:0] w0[16], w1[16], w2[16],w3[16],w4[16],w5[16],w6[16],w7[16],w8[16],w9[16],w10[16],w11[16],w12[16],w13[16],w14[16], w15[16];
logic [31:0] message[32];
logic [31:0] a, b, c, d, e, f, g, hash;
logic [31:0] h[8], ho[8], ho20[8], ho21[8], ho22[8], ho23[8], ho24[8], ho25[8], ho26[8], ho27[8], ho28[8], ho29[8], ho210[8], ho211[8], ho212[8], ho213[8], ho214[8], ho215[8];
logic [31:0] ho30[8], ho31[8], ho32[8], ho33[8], ho34[8], ho35[8], ho36[8], ho37[8], ho38[8], ho39[8], ho310[8], ho311[8], ho312[8], ho313[8], ho314[8], ho315[8];
logic [ 6:0] num;
logic [ 4:0] offset; 
logic        cur_we;
logic [15:0] cur_addr;
logic [31:0] cur_write_data;
logic start_1, done_1, start_2, done_20,done_21, done_22, done_23, done_24, done_25, done_26, done_27, done_28, done_29, done_210, done_211, done_212, done_213, done_214, done_215;
logic start_3, done_30,done_31, done_32, done_33, done_34, done_35, done_36, done_37, done_38, done_39, done_310, done_311, done_312, done_313, done_314, done_315;

assign mem_clk = clk;
assign mem_addr = cur_addr + offset;
assign mem_we = cur_we;
assign mem_write_data = cur_write_data;

 
always_ff @(posedge clk, negedge reset_n)
begin
  if (!reset_n) begin
    cur_we <= 1'b0;
    state <= IDLE;
  end 
  else case (state)
   IDLE: begin 
       if(start) begin
			h[0] <= 32'h6a09e667;
			h[1] <= 32'hbb67ae85;
			h[2] <= 32'h3c6ef372;
			h[3] <= 32'ha54ff53a;
			h[4] <= 32'h510e527f;
			h[5] <= 32'h9b05688c;
			h[6] <= 32'h1f83d9ab;
			h[7] <= 32'h5be0cd19; 	
			
			a <= h[0];
			b <= h[1];
			c <= h[2];
			d <= h[3];
			e <= h[4];
			f <= h[5];
			g <= h[6];
			hash <= h[7];
			cur_addr <= message_addr;
			cur_we <= 1'b0;
			offset <= 5'b0;
			num <= 7'b0;
			
			start_1 <= 0;	
			start_2 <= 0;	
			
			state <= REST;
       end
    end

	 REST:begin
		state <= READ;
    end 
	 
	  READ: begin
			if(offset < 19) 
				begin
					message[offset] <= mem_read_data;
					offset <= offset + 1;
					state <= REST;
				end
			else begin
				for(int n=0; n<16; n++) w0[n] <= message[n];
				message[20] <= 32'h80000000;
				message[31] <= 32'd640;
				for(int n = 21; n<31; n++) message[n] <= 32'h0;
				offset <= 0;
				state <=START1;	
			end
		end			
		
		
    START1: begin
				start_1 <= 1;
				num <= num + 1;
				state <= BUFFER1;
    end

	 BUFFER1: begin
		if(num < 3) begin
			num <= num + 1;
			state <= BUFFER1;
		end
		else begin
		start_1 <= 0;
		if(done_1) begin
			num <= 0;
			state <= PHASE2;
		end
		else begin
			state <= BUFFER1;
		end
		end
	end
	
	PHASE2: begin
		for(int n=0;n<3;n++) w0[n] <= message[n+16];
		for(int n=0;n<3;n++) w1[n] <= message[n+16];
		for(int n=0;n<3;n++) w2[n] <= message[n+16];
		for(int n=0;n<3;n++) w3[n] <= message[n+16];
		for(int n=0;n<3;n++) w4[n] <= message[n+16];
		for(int n=0;n<3;n++) w5[n] <= message[n+16];
		for(int n=0;n<3;n++) w6[n] <= message[n+16];
		for(int n=0;n<3;n++) w7[n] <= message[n+16];
		for(int n=0;n<3;n++) w8[n] <= message[n+16];
		for(int n=0;n<3;n++) w9[n] <= message[n+16];
		for(int n=0;n<3;n++) w10[n] <= message[n+16];
		for(int n=0;n<3;n++) w11[n] <= message[n+16];
		for(int n=0;n<3;n++) w12[n] <= message[n+16];
		for(int n=0;n<3;n++) w13[n] <= message[n+16];
		for(int n=0;n<3;n++) w14[n] <= message[n+16];
		for(int n=0;n<3;n++) w15[n] <= message[n+16];
		w0[3] <= 32'd0;
		w1[3] <= 32'd1;
		w2[3] <= 32'd2;
		w3[3] <= 32'd3;
		w4[3] <= 32'd4;
		w5[3] <= 32'd5;
		w6[3] <= 32'd6;
		w7[3] <= 32'd7;
		w8[3] <= 32'd8;
		w9[3] <= 32'd9;
		w10[3] <= 32'd10;
		w11[3] <= 32'd11;
		w12[3] <= 32'd12;
		w13[3] <= 32'd13;
		w14[3] <= 32'd14;
		w15[3] <= 32'd15;
		for(int n=4;n<16;n++) w0[n] <= message[n+16];
		for(int n=4;n<16;n++) w1[n] <= message[n+16];
		for(int n=4;n<16;n++) w2[n] <= message[n+16];
		for(int n=4;n<16;n++) w3[n] <= message[n+16];
		for(int n=4;n<16;n++) w4[n] <= message[n+16];
		for(int n=4;n<16;n++) w5[n] <= message[n+16];
		for(int n=4;n<16;n++) w6[n] <= message[n+16];
		for(int n=4;n<16;n++) w7[n] <= message[n+16];
		for(int n=4;n<16;n++) w8[n] <= message[n+16];
		for(int n=4;n<16;n++) w9[n] <= message[n+16];
		for(int n=4;n<16;n++) w10[n] <= message[n+16];
		for(int n=4;n<16;n++) w11[n] <= message[n+16];
		for(int n=4;n<16;n++) w12[n] <= message[n+16];
		for(int n=4;n<16;n++) w13[n] <= message[n+16];
		for(int n=4;n<16;n++) w14[n] <= message[n+16];
		for(int n=4;n<16;n++) w15[n] <= message[n+16];
		state <= START2;
	end
	
	START2: begin
			start_2 <= 1;
			num <= num + 1;
			state <= BUFFER2;
    end

	 BUFFER2: begin
		if(num < 3) begin
			num <= num + 1;
			state <= BUFFER2;
		end
		else begin
		start_2 <= 0;
		if(done_20) begin
			num <= 0;
			state <= PHASE3;
		end
		else begin
			state <= BUFFER2;
		end
		end
	end
	
	PHASE3: begin
		for(int n=0;n<8;n++) w0[n] <= ho20[n];
		for(int n=0;n<8;n++) w1[n] <= ho21[n];
		for(int n=0;n<8;n++) w2[n] <= ho22[n];
		for(int n=0;n<8;n++) w3[n] <= ho23[n];
		for(int n=0;n<8;n++) w4[n] <= ho24[n];
		for(int n=0;n<8;n++) w5[n] <= ho25[n];
		for(int n=0;n<8;n++) w6[n] <= ho26[n];
		for(int n=0;n<8;n++) w7[n] <= ho27[n];
		for(int n=0;n<8;n++) w8[n] <= ho28[n];
		for(int n=0;n<8;n++) w9[n] <= ho29[n];
		for(int n=0;n<8;n++) w10[n] <= ho210[n];
		for(int n=0;n<8;n++) w11[n] <= ho211[n];
		for(int n=0;n<8;n++) w12[n] <= ho212[n];
		for(int n=0;n<8;n++) w13[n] <= ho213[n];
		for(int n=0;n<8;n++) w14[n] <= ho214[n];
		for(int n=0;n<8;n++) w15[n] <= ho215[n];
		w0[8] <= 32'h80000000;
		w1[8] <= 32'h80000000;
		w2[8] <= 32'h80000000;
		w3[8] <= 32'h80000000;
		w4[8] <= 32'h80000000;
		w5[8] <= 32'h80000000;
		w6[8] <= 32'h80000000;
		w7[8] <= 32'h80000000;
		w8[8] <= 32'h80000000;
		w9[8] <= 32'h80000000;
		w10[8] <= 32'h80000000;
		w11[8] <= 32'h80000000;
		w12[8] <= 32'h80000000;
		w13[8] <= 32'h80000000;
		w14[8] <= 32'h80000000;
		w15[8] <= 32'h80000000;
		for(int n=9; n<15; n++) begin
			w0[n] <= 32'h0;
			w1[n] <= 32'h0;
			w2[n] <= 32'h0;
			w3[n] <= 32'h0;
			w4[n] <= 32'h0;
			w5[n] <= 32'h0;
			w6[n] <= 32'h0;
			w7[n] <= 32'h0;
			w8[n] <= 32'h0;
			w9[n] <= 32'h0;
			w10[n] <= 32'h0;
			w11[n] <= 32'h0;
			w12[n] <= 32'h0;
			w13[n] <= 32'h0;
			w14[n] <= 32'h0;
			w15[n] <= 32'h0;
		end
		w0[15] <= 32'd256;
		w1[15] <= 32'd256;
		w2[15] <= 32'd256;
		w3[15] <= 32'd256;
		w4[15] <= 32'd256;
		w5[15] <= 32'd256;
		w6[15] <= 32'd256;
		w7[15] <= 32'd256;
		w8[15] <= 32'd256;
		w9[15] <= 32'd256;
		w10[15] <= 32'd256;
		w11[15] <= 32'd256;
		w12[15] <= 32'd256;
		w13[15] <= 32'd256;
		w14[15] <= 32'd256;
		w15[15] <= 32'd256;
		state <= START3;
		end
		
		START3: begin
			start_3 <= 1;
			num <= num + 1;
			state <= BUFFER3;
		end
		
		BUFFER3: begin
			if(num <3) begin
				num <= num + 1;
				state <= BUFFER3;
			end
			else begin
				start_3 <= 0;
				if(done_30) begin
					num <= 0;
					cur_addr <= output_addr;
					cur_we <= 1'b1;
					cur_write_data <= ho30[0];
					state <= WRITE;
				end
				else begin
					state <= BUFFER3;
				end
			end
		end
					
		
	 WRITE: begin
		if(offset < 16)begin
			case(offset)
			    0: cur_write_data <= ho31[0];
			    1: cur_write_data <= ho32[0];
			    2: cur_write_data <= ho33[0];
			    3: cur_write_data <= ho34[0];
			    4: cur_write_data <= ho35[0];
			    5: cur_write_data <= ho36[0];
			    6: cur_write_data <= ho37[0];
			    7: cur_write_data <= ho38[0];
				 8: cur_write_data <= ho39[0];
			    9: cur_write_data <= ho310[0];
			    10: cur_write_data <= ho311[0];
			    11: cur_write_data <= ho312[0];
			    12: cur_write_data <= ho313[0];
			    13: cur_write_data <= ho314[0];
			    14: cur_write_data <= ho315[0];
			    15: cur_write_data <= ho315[0];
			    default: cur_write_data <= ho31[0];
		    endcase
			offset <= offset + 1;
			state <= WRITE;
		end
		else begin
		state <= IDLE;
		end
    end
   endcase
  end
	
assign done = (state == IDLE);	

simplified_sha256 sha1 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_1),
	.message(w0),
	.in(h),
	.done(done_1),
	.sha256(ho)
	);

	simplified_sha256 sha20 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w0),
	.in(ho),
	.done(done_20),
	.sha256(ho20)
	);
	
	simplified_sha256 sha21 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w1),
	.in(ho),
	.done(done_21),
	.sha256(ho21)
	);
	
	simplified_sha256 sha22 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w2),
	.in(ho),
	.done(done_22),
	.sha256(ho22)
	);
	
	simplified_sha256 sha23 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w3),
	.in(ho),
	.done(done_23),
	.sha256(ho23)
	);
	
	simplified_sha256 sha24 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w4),
	.in(ho),
	.done(done_24),
	.sha256(ho24)
	);
	
	simplified_sha256 sha25 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w5),
	.in(ho),
	.done(done_25),
	.sha256(ho25)
	);
	
	simplified_sha256 sha26 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w6),
	.in(ho),
	.done(done_26),
	.sha256(ho26)
	);
	
	simplified_sha256 sha27 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w7),
	.in(ho),
	.done(done_27),
	.sha256(ho27)
	);
	
	simplified_sha256 sha28 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w8),
	.in(ho),
	.done(done_28),
	.sha256(ho28)
	);
	
	simplified_sha256 sha29 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w9),
	.in(ho),
	.done(done_29),
	.sha256(ho29)
	);
   
	simplified_sha256 sha210 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w10),
	.in(ho),
	.done(done_210),
	.sha256(ho210)
	);
	
	simplified_sha256 sha211 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w11),
	.in(ho),
	.done(done_211),
	.sha256(ho211)
	);
	
	simplified_sha256 sha212 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w12),
	.in(ho),
	.done(done_212),
	.sha256(ho212)
	);
	
	simplified_sha256 sha213 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w13),
	.in(ho),
	.done(done_213),
	.sha256(ho213)
	);
	
	simplified_sha256 sha214 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w14),
	.in(ho),
	.done(done_214),
	.sha256(ho214)
	);
	
	simplified_sha256 sha215 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_2),
	.message(w15),
	.in(ho),
	.done(done_215),
	.sha256(ho215)
	);
	
	simplified_sha256 sha30 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w0),
	.in(h),
	.done(done_30),
	.sha256(ho30)
	);
	
	simplified_sha256 sha31 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w1),
	.in(h),
	.done(done_31),
	.sha256(ho31)
	);
	
	simplified_sha256 sha32 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w2),
	.in(h),
	.done(done_32),
	.sha256(ho32)
	);
	
	simplified_sha256 sha33 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w3),
	.in(h),
	.done(done_33),
	.sha256(ho33)
	);
	
	simplified_sha256 sha34 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w4),
	.in(h),
	.done(done_34),
	.sha256(ho34)
	);
	
	simplified_sha256 sha35 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w5),
	.in(h),
	.done(done_35),
	.sha256(ho35)
	);
	
	simplified_sha256 sha36 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w6),
	.in(h),
	.done(done_36),
	.sha256(ho36)
	);
	
	simplified_sha256 sha37 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w7),
	.in(h),
	.done(done_37),
	.sha256(ho37)
	);
	
	simplified_sha256 sha38 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w8),
	.in(h),
	.done(done_38),
	.sha256(ho38)
	);
	
	simplified_sha256 sha39 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w9),
	.in(h),
	.done(done_39),
	.sha256(ho39)
	);
   
	simplified_sha256 sha310 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w10),
	.in(h),
	.done(done_310),
	.sha256(ho310)
	);
	
	simplified_sha256 sha311 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w11),
	.in(h),
	.done(done_311),
	.sha256(ho311)
	);
	
	simplified_sha256 sha312 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w12),
	.in(h),
	.done(done_312),
	.sha256(ho312)
	);
	
	simplified_sha256 sha313 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w13),
	.in(h),
	.done(done_313),
	.sha256(ho313)
	);
	
	simplified_sha256 sha314 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w14),
	.in(h),
	.done(done_314),
	.sha256(ho314)
	);
	
	simplified_sha256 sha315 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_3),
	.message(w15),
	.in(h),
	.done(done_315),
	.sha256(ho315)
	);
	
endmodule
