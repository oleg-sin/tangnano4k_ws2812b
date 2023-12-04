module HSL_to_RGB (
  input wire [7:0] H,
  input wire [7:0] S,
  input wire [7:0] L,
  output wire [7:0] R,
  output wire [7:0] G,
  output wire [7:0] B
);
  
  // Конвертирование значений H, S, L в диапазоны 0-360, 0-100, 0-100 соответственно
  reg [10:0] H_scaled = $rtoi($ceil(H * 576));
  reg [9:0] S_scaled = $rtoi($ceil(S * 256 / 100));
  reg [9:0] L_scaled = $rtoi($ceil(L * 256 / 100));
  
  // Переменные для хранения значений R, G, B
  reg [7:0] R_value;
  reg [7:0] G_value;
  reg [7:0] B_value;
  
  always @(*) begin
    if (L_scaled == 0) begin
      R_value = 0;
      G_value = 0;
      B_value = 0;
    end else if (S_scaled == 0) begin
      R_value = L_scaled;
      G_value = L_scaled;
      B_value = L_scaled;
    end else begin
      reg [11:0] temp_1;
      reg [11:0] temp_2;
  
      if (L_scaled < 128) begin
        temp_1 = $rtoi($ceil(L_scaled + L_scaled * S_scaled / 256));
      end else begin
        temp_1 = $rtoi($ceil(L_scaled + ((255 - L_scaled) * S_scaled) / 256));
      end
  
      temp_2 = $rtoi($ceil((2 * L_scaled) - temp_1));
  
      // Вычисление значения канала R
      reg [11:0] H_0_to_120 = H_scaled;
      reg [11:0] H_240_to_360 = $rtoi($ceil(H_scaled - 3840));
  
      if (H_scaled < 1280) begin
        R_value = $rtoi($ceil(temp_2 + (temp_1 - temp_2) * H_0_to_120 / 256));
      end else if (H_scaled < 2560) begin
        R_value = temp_1;
      end else begin
        R_value = $rtoi($ceil(temp_2 + (temp_1 - temp_2) * H_240_to_360 / 256));
      end
  
      // Вычисление значения канала G
      reg [11:0] H_120_to_240 = H_scaled - 1280;
  
      if (H_scaled < 1280) begin
        G_value = temp_2;
      end else if (H_scaled < 2560) begin
        G_value = $rtoi($ceil(temp_2 + (temp_1 - temp_2) * H_120_to_240 / 256));
      end else begin
        G_value = temp_1;
      end
  
      // Вычисление значения канала B
      reg [11:0] H_0_to_240 = H_scaled - 2560;
  
      if (H_scaled < 1280) begin
        B_value = temp_1;
      end else if (H_scaled < 2560) begin
        B_value = temp_2 + (temp_1 - temp_2) * H_0_to_240 / 256;
      end else begin
        B_value = temp_2;
      end
    end
  end
  
  assign R = R_value;
  assign G = G_value;
  assign B = B_value;
  
endmodule
