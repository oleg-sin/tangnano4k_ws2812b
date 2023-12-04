module top (
    input clk, 
    input  sys_rst,
    output ws_data
);

    localparam NUM_LEDS = 50;
    localparam SATURATION = 8'hFF;
    localparam VALUE = 8'd10;

    reg reset = 1;
    always @(posedge clk)
        reset <= 0;

    reg [15:0] count = 0;
    reg [7:0] color_ind = 0;

    always @(posedge clk) begin
        if (!sys_rst) begin
            H <= 0;
            S <= 0;
            V <= 0;
            count <= 0;
            ad_i <= 0;
        end
        count <= count + 1;
        if (&count) begin
            if (led_num == NUM_LEDS) begin
                led_num <= 0;
            end else begin 
                led_num <= led_num + 1;
            end
//            color_ind <= color_ind + $rtoi($ceil(256 / NUM_LEDS));
//            H <= color_ind;
            ad_i <= ad_i + 8;
            H <= random;
            S <= SATURATION;
            V <= VALUE;
        end
    end

    wire [23:0] led_rgb_data;
    reg [7:0] led_num = 0;
    wire led_write = &count;

    ws2812b #(.NUM_LEDS(NUM_LEDS)) ws2812b_inst (
        .data(ws_data),
        .clk(clk),
        .reset(reset),
        .rgb_data(led_rgb_data),
        .led_num(led_num),
        .write(led_write)
    );

    reg [7:0] H = 0;
    reg [7:0] S = 0;
    reg [7:0] V = 0;

    hsv_to_rgb hsv_to_rgb_inst (
        .H(H), .S(S), .V(V),
        .clk(clk),
        .rgb(led_rgb_data)
    );

    wire [7:0] random;
    reg [10:0] ad_i = 0;
    reg ce_i = 1'b1;
    Gowin_pROM Gowin_pROM_inst(
        .dout(random), 
        .clk(clk), 
        .ce(ce_i), 
        .reset(~sys_rst), 
        .ad(ad_i)
    );

endmodule