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

//команды для перемещения робота
localparam [2:0]    STAY1           =   3'b000,
                    STAY2           =   3'b100,
                    MOVE_FORWARD    =   3'b111,
                    TURN_LEFT1      =   3'b101,
                    TURN_LEFT2      =   3'b010,
                    TURN_RIGHT1     =   3'b110,
                    TURN_RIGHT2     =   3'b010,
                    MOVE_BACKWARD   =   3'b011;

//поле 7х7 
reg [2:0] x_axis = 4'd5;
reg [2:0] y_axis = 4'd1;

reg [1:0] move_side = 2'b01;
//00 -- запад
//01 -- север
//10 -- восток
//11 -- юг

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
    x_axis          =   4'd5;
    y_axis          =   4'd1;
    repeat (5) @ (posedge clk);
    rstn = 1'b0;
    repeat (2) @ (posedge clk);
    rstn = 1'b1;
    repeat (4) @ (posedge clk);
    $display("Turn on motor");
    motor_on = 1'b1;
    repeat (3) @ (posedge clk);
    check_motor_status(motor_status); // [5:1]
    $display("Start coordinates: Axis X: %d, Axis Y: %d", x_axis, y_axis);
    move_forward(); // [5:2]
    move_forward(); // [5:3]
    turn_left();    // [5:3]
    move_forward(); // [4:3]
    turn_right();
    move_forward();
    move_forward();
    turn_right();
    turn_right();
    move_backward();
    move_backward();
    turn_left();
    move_forward();
    move_forward();
    move_forward();
    move_forward();
    turn_right();
    move_forward();
    move_forward();
    move_forward();
    move_forward();
    move_forward();
    move_forward();
    move_forward();
    turn_left();
    move_backward();
    move_backward();
    move_backward();
    move_backward();
    move_backward();
    move_backward();
    $display("Turn off motor");
    motor_on = 1'b0;
    repeat (3) @ (posedge clk);
    $display("Finish coordinates: Axis X: %d, Axis Y: %d", x_axis, y_axis);
    check_motor_status(motor_status);
    $stop;
end

task move_forward();
    begin
        move_data = MOVE_FORWARD;
        $display("Move forward");
        repeat(1) @ (posedge clk);
        move_data = STAY1;
        repeat(1) @ (posedge clk);
    end
endtask

task move_backward();
    begin
        move_data = MOVE_BACKWARD;
        repeat(1) @ (posedge clk);
        move_data = STAY1;
        repeat(1) @ (posedge clk);
    end
endtask

task turn_left();
    begin
        move_data = TURN_LEFT1;
        repeat(1) @ (posedge clk);
        move_data = STAY1;
        repeat(1) @ (posedge clk);
    end
endtask

task turn_right();
    begin
        move_data = TURN_RIGHT1;
        repeat(1) @ (posedge clk);
        move_data = STAY1;
        repeat(1) @ (posedge clk);
    end
endtask

task check_motor_status(input motor_status);
    begin
        if(motor_status)
            $display("Motor status is ON");
        else
            $display("Motor status is OFF");
    end
endtask


always @ * begin
    case({left_motor, right_motor})
        4'b0000: $display("Stay on position: Axis X: %d, Axis Y: %d, Side: %b", x_axis, y_axis, move_side);
        4'b0101: begin
                $display("Robot moved to 1 square forward");
                case(move_side)
                    2'b00: x_axis = x_axis - 1'b1; //запад
                    2'b01: y_axis = y_axis + 1'b1; //север
                    2'b10: x_axis = x_axis + 1'b1; //восток
                    2'b11: y_axis = y_axis - 1'b1; //юг
                endcase
            end
        4'b1010: begin
            $display("Robot moved to 1 square backward");
            case(move_side)
                2'b00: x_axis = x_axis + 1'b1; //восток
                2'b01: y_axis = y_axis - 1'b1; //юг
                2'b10: x_axis = x_axis - 1'b1; //запад
                2'b11: y_axis = y_axis + 1'b1; //север
            endcase
        end
        4'b0110: begin
            $display("Robot turns right");
            move_side = move_side + 1'b1;
        end
        4'b1001: begin
            $display("Robot turns left");
            move_side = move_side - 1'b1;
        end
        default: begin
            $warning("Unexpected state!");
        end
    endcase  
end         

always @ * begin
    if((move_side == 2'b00) && (x_axis == 4'd1))
        tracker_fwrd = 1'b1;
    else if((move_side == 2'b01) && (y_axis == 4'd7))
        tracker_fwrd = 1'b1;
    else if((move_side == 2'b10) && (x_axis == 4'd7))
        tracker_fwrd = 1'b1;
    else if((move_side == 2'b11) && (y_axis == 4'd1))
        tracker_fwrd = 1'b1;
    else
        tracker_fwrd = 1'b0;
end

always @ * begin 
    if(tracker_status) begin
        if((left_motor == 2'b00) && (right_motor == 2'b00)) begin
            $display("Obstacle is founded! Robot is stopped");
            $display("Stay on position: Axis X: %d, Axis Y: %d, Side: %b", x_axis, y_axis, move_side);
        end
        else
            $error("Obstacle is founded, but  Robot moved");
    end
end

endmodule

