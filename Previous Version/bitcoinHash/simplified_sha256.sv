module simplified_sha256(
 input logic  clk, reset_n, start,
 input logic [31:0] message[16], 
 input logic [31:0] in[8],
 output logic done,
 output logic [31:0] sha256[8]);

enum logic [2:0] {IDLE, BLOCK, PIPE1, PIPE2, COMPUTE, WRITE, DONE} state;
logic [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
logic [31:0] a, b, c, d, e, f, g, hash, P;
logic [ 6:0] num;
logic [31:0] w[16];


// SHA256 K constants
parameter int k[0:63] = '{
   32'h428a2f98,32'h71374491,32'hb5c0fbcf,32'he9b5dba5,32'h3956c25b,32'h59f111f1,32'h923f82a4,32'hab1c5ed5,
   32'hd807aa98,32'h12835b01,32'h243185be,32'h550c7dc3,32'h72be5d74,32'h80deb1fe,32'h9bdc06a7,32'hc19bf174,
   32'he49b69c1,32'hefbe4786,32'h0fc19dc6,32'h240ca1cc,32'h2de92c6f,32'h4a7484aa,32'h5cb0a9dc,32'h76f988da,
   32'h983e5152,32'ha831c66d,32'hb00327c8,32'hbf597fc7,32'hc6e00bf3,32'hd5a79147,32'h06ca6351,32'h14292967,
   32'h27b70a85,32'h2e1b2138,32'h4d2c6dfc,32'h53380d13,32'h650a7354,32'h766a0abb,32'h81c2c92e,32'h92722c85,
   32'ha2bfe8a1,32'ha81a664b,32'hc24b8b70,32'hc76c51a3,32'hd192e819,32'hd6990624,32'hf40e3585,32'h106aa070,
   32'h19a4c116,32'h1e376c08,32'h2748774c,32'h34b0bcb5,32'h391c0cb3,32'h4ed8aa4a,32'h5b9cca4f,32'h682e6ff3,
   32'h748f82ee,32'h78a5636f,32'h84c87814,32'h8cc70208,32'h90befffa,32'ha4506ceb,32'hbef9a3f7,32'hc67178f2
};


// SHA256 hash round
function logic [255:0] sha256_op(input logic [31:0] a, b, c, d, e, f, g, P);
    logic [31:0] S1, S0, ch, maj, t1, t2; 
	begin
		S1 = rightrotate(e, 6) ^ rightrotate(e, 11) ^ rightrotate(e, 25);
		ch = (e & f) ^ ((~e) & g);
		t1 = S1 + ch + P;
		S0 = rightrotate(a, 2) ^ rightrotate(a, 13) ^ rightrotate(a, 22);
		maj = (a & b) ^ (a & c) ^ (b & c);
		t2 = S0 + maj;
		sha256_op = {t1 + t2, a, b, c, d + t1, e, f, g};
	end
endfunction

function logic [31:0] wi;
	logic [31:0] S1, S0;
	begin
		S0 = rightrotate(w[1], 7) ^ rightrotate(w[1], 18) ^ (w[1] >> 3);
		S1 = rightrotate(w[14], 17) ^ rightrotate(w[14], 19) ^ (w[14] >> 10);
		wi = w[0] + S0 + w[9] + S1;
	end
endfunction	

function logic [31:0] rightrotate(input logic [31:0] x,
                                  input logic [ 7:0] r);
begin
	rightrotate = (x >> r) | (x << (32-r));
end
endfunction

always_ff @(posedge clk, negedge reset_n)
begin
  if (!reset_n) begin
    state <= IDLE;
  end 
  else case (state)
    IDLE: begin 
       if(start) begin
			h0 <= in[0];
			h1 <= in[1];
			h2 <= in[2];
			h3 <= in[3];
			h4 <= in[4];
			h5 <= in[5];
			h6 <= in[6];
			h7 <= in[7]; 	
			
			a <= in[0];
			b <= in[1];
			c <= in[2];
			d <= in[3];
			e <= in[4];
			f <= in[5];
			g <= in[6];
			hash <= in[7]; 
			
			num <= 7'b0;
			state <= BLOCK;
       end
    end
		
    BLOCK: begin
		for(int n=0; n<16; n++) w[n] <= message[n];
		state <= PIPE1;
    end

	 PIPE1: begin
			P <= w[0] + k[0] + hash;
			for(int n=0; n<15; n++) w[n] <= w[n + 1];
			w[15] <= wi;
			state <= PIPE2;
	 end

	 PIPE2: begin
		{a, b, c, d, e, f, g, hash} <= sha256_op(a, b, c, d, e, f, g, P);
		P <= w[0] + k[1] + g;
		for(int n=0; n<15; n++) w[n] <= w[n + 1];
		w[15] <= wi;
		num <= num+1;
		state <= COMPUTE;
	 end
	 
	 
    COMPUTE: begin
		if(num < 64) begin
			P <= w[0] + k[num+1] + g;
			{a, b, c, d, e, f, g, hash} <= sha256_op(a,b,c,d,e,f,g,P);
			for(int j=0;j<15;j++) w[j] <= w[j+1];
			w[15] <= wi;
			num <= num + 1;
			state <= COMPUTE;
		end
	   else begin
		 h0 <= a + h0;
		 h1 <= b + h1;
		 h2 <= c + h2;
		 h3 <= d + h3;
		 h4 <= e + h4;
		 h5 <= f + h5;
		 h6 <= g + h6;
		 h7 <= hash + h7;
		 num <= 0;
		 state <= WRITE;
     end
	 end
	 
    WRITE: begin
		sha256[0] <= h0;
		sha256[1] <= h1;
		sha256[2] <= h2;
		sha256[3] <= h3;
		sha256[4] <= h4;
		sha256[5] <= h5;
		sha256[6] <= h6;
		sha256[7] <= h7;
		state <= DONE;
		end
    
	 DONE: begin
		state <= IDLE;
	end
   endcase
  end

// Generate done when SHA256 hash computation has finished and moved to IDLE state
assign done = (state == DONE);

endmodule
