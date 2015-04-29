`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: None
// Engineer: Dai Tianyu (dtysky)
// 
// Create Date: 2015/03/30 15:35:57
// Design Name: Window
// Module Name: Window_TB
// Project Name: Image processing project
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CLOCK (
	output bit clk
	);
	
	always #(100ps) begin
		clk = ~clk;
	end

endmodule

module Window_TB();

	//For Rows8x512
	parameter im_width = 320;
	parameter rows_width = 5;
	//For Window
	parameter window_size = 5;
	//Can't be changed in this IP.
	parameter color_width = 8;

	bit clk,rst_n;
	bit in_enable;
	bit[color_width - 1 : 0] in_color;
	bit row_enable;
	bit[color_width * rows_width - 1 : 0] out_color;

	bit[color_width * window_size * window_size - 1 : 0] win_data;
	bit win_enable;

	CLOCK CLOCK1(clk);
	Rows8x512 #(im_width,rows_width) Rows1 (clk, rst_n, in_enable, in_color, row_enable, out_color);
	Window #(color_width,window_size) Window1(clk, rst_n, row_enable, out_color, win_enable, win_data);

	integer fi,fo;
	string fname[$];
	string ftmp,imsize;
	int fsize;

	bit now_start = 0;

	initial begin
		fi = $fopen("imgindex.dat","r");
		while (!$feof(fi)) begin
			$fscanf(fi,"%s",ftmp);
			fname.push_front(ftmp);
		end
		$fclose(fi);
		fsize = fname.size();
		rst_n = 0;
		in_enable = 0;
		now_start = 0;
		repeat(1100) @(posedge clk);
		rst_n = 1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		for (int i = 0; i < fsize; i++) begin;
			ftmp = fname.pop_back();
			fi = $fopen({ftmp,".dat"},"r");
			fo = $fopen({ftmp,".res"},"w");
			//Keep xsize and ysize
			$fscanf(fi,"%s",imsize);
			$fwrite(fo,"%s\n",imsize);
			$fscanf(fi,"%s",imsize);
			$fwrite(fo,"%s\n",imsize);
			while (!$feof(fi)) begin 
				@(posedge clk);
				in_enable = 1;
				$fscanf(fi,"%b",in_color);
				if(win_enable) begin
					if(~now_start)
						$display("%m: at time %t ps , start%d !", $time, i);
					now_start = 1;
					$fwrite(fo,"%b\n",win_data);
				end
			end
			$fclose(fi);
			$fclose(fo);
		end
		$finish;
	end

endmodule