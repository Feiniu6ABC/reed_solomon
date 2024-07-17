module syndrome_slice(
    input rst_n,
    input clk,
    input [127:0] data_in,
    input valid_in,
    input i;

    output valid_out,
    output busy
);

reg [7:0] data [255 : 0];
reg [7:0] syndrome;
reg [7:0] cnt;

wire [7:0]  alpha_power;

gf256_power_lut power_lut(
    .addr   (i*cnt),
    .data   (alpha_power)
);

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        syndrome <= 8'b0;
    end else begin
        if (cnt < 8'd255)begin
            syndrome <= syndrome ^ alpha_power
        end else begin
            syndrome <= 8'b0;
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        cnt <= 8'b0;
    end else begin
        if (valid_in || cnt > 0 )begin
            cnt <= cnt + 1;
        end 
    end
end

assign valid_out = (cnt == 255) ? 1 : 0;
assign busy = (cnt) ? 1 : 0;

endmodule
