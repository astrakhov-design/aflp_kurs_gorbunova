`timescale 1ns/1ns

module robot_tb;

reg clk = 1'b0;
reg rstn = 1'b1;

//Управляющий сигнал питания роботом
reg motor_on;
//Шина управления движением робота
reg [2:0] move_data;
//Сигнал датчика препятствий
reg tracker_fwrd;

//Выходная шина статуса питания двигателей робота
wire motor_status;
//Выходная шина статуса датчика препятствий
wire tracker_status;

//Выходные шины управления моторами робота
wire [1:0]  left_motor;
wire [1:0]  right_motor;

always #5 clk = ~clk;

robot DUT(
    .clk_i(clk),
    .rstn_i(rstn),
    .motor_on_i(motor_on),
    .motor_status_o(motor_status),
    .left_motor_o(left_motor),
    .right_motor_o(right_motor),
    .move_i(move_data),
    .tracker_fwrd_i(tracker_fwrd),
    .tracker_status_o(tracker_status)
);

initial begin
    motor_on        =   1'b0;
    move_data       =   3'b000;
    tracker_fwrd    =   1'b0;
    repeat (5) @ (posedge clk);
    rstn = 1'b0;
    repeat (2) @ (posedge clk);
    rstn = 1'b1;
    repeat (25) @ (posedge clk);
    $stop;
end


endmodule

