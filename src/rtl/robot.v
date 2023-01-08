module robot(
    input clk_i,   //тактовый синхросигнал
    input rstn_i,   //асинхронный сброс системы

    //Секция включения / выключения двигателей робота
    input   motor_on_i, // управляющий сигнал моторами робота
    output  motor_status_o, //сигнал индикации статуса двигателей робота

    //Выходные управляющие сигналы двигателями робота
    //сигнал управления левым/правым двигателем робота (0b00 -- гусеница не двигается,
    //                                                  0b01 -- движение гусеницы вперед,
    //                                                  0b10 -- движение гусеницы назад
    output [1:0] left_motor_o, 
    output [1:0] right_motor_o,

    //Секция управления двигателями с пульта ДУ ()
    input [2:0] move_i, //входной сигнал команды движения с пульта ДУ   // 2 -- направление моторов
                        /* Назначение:  0b000 -- стоять на месте        // 1 -- управление левым мотором
                                        0b111 -- движение вперед        // 0 -- управление правым мотором
                                        0b101 -- поворот влево
                                        0b110 -- поворот вправо
                                        0b011 -- движение назад
                        */ 

    //Секция датчика препятствий:
    input tracker_fwrd_i, //передний датчик препятствий. Если равен 1, то впереди препятствие
    output tracker_status_o //статус датчика препятствий, передаваемый на пульт ДУ
);

localparam [3:0]    PWR_OFF         =   4'd0,       //двигатель выключен
                    ENGINE_START    =   4'd1,       //прогрев двигателя
                    ENGINE_END      =   4'd2,
                    PWR_ON_IDLE     =   4'd3,       //двигатель включен, ожидание команды от пульта ДУ
                    MOVE_FWRD       =   4'd4,       //движение вперед
                    TURN_LEFT       =   4'd5,       //поворот влево
                    TURN_RIGHT      =   4'd6,       //поворот вправо
                    MOVE_BACK       =   4'd7,       //движение назад
                    TRACKER_ERROR   =   4'd8;       //впереди препятствие

reg [2:0]   STATUS_CURRENT, STATUS_NEXT;
reg         motor_status_current_reg, motor_status_next_reg;
reg         tracker_current_reg, tracker_next_reg;
reg [1:0]   left_motor_current_reg, left_motor_next_reg; 
reg [1:0]   right_motor_current_reg, right_motor_next_reg;

always @ (posedge clk_i, negedge rstn_i) begin
    if(!rstn_i) begin
        STATUS_CURRENT              <=  PWR_OFF;
        motor_status_current_reg    <=  1'b0;
        left_motor_current_reg      <=  2'b00;
        right_motor_current_reg     <=  2'b00;
        tracker_current_reg         <=  1'b0;
    end
    else begin
        STATUS_CURRENT              <=  STATUS_NEXT;
        motor_status_current_reg    <=  motor_status_next_reg;
        left_motor_current_reg      <=  left_motor_next_reg;
        right_motor_current_reg     <=  right_motor_next_reg;
        tracker_current_reg         <=  tracker_next_reg;
    end 
end

always @ * begin
    left_motor_next_reg     =   2'b00;
    right_motor_next_reg    =   2'b00;
    tracker_next_reg        =   1'b0;
    motor_status_next_reg   =   1'b0;
    case(STATUS_CURRENT)
        PWR_OFF: begin
            if(motor_on_i)
                STATUS_NEXT =   ENGINE_START;
        end
        ENGINE_START: begin
            STATUS_NEXT = PWR_ON_IDLE;
        end
        ENGINE_END: begin
            STATUS_NEXT = PWR_OFF;
        end
        PWR_ON_IDLE: begin
            motor_status_next_reg = 1'b1;
            if(!motor_on_i)
                STATUS_NEXT = ENGINE_END;
            else begin
                case(move_i)
                    3'b111: STATUS_NEXT = MOVE_FWRD;
                    3'b101, 3'b010: STATUS_NEXT = TURN_LEFT;
                    3'b110, 3'b001: STATUS_NEXT = TURN_RIGHT;
                    3'b011: STATUS_NEXT = MOVE_BACK;
                    default: STATUS_NEXT = PWR_ON_IDLE;
                endcase
            end
        end
        MOVE_FWRD: begin
            motor_status_next_reg = 1'b1;
            if(tracker_fwrd_i) begin
                //не двигаемся вперед, переходим в состояние ошибки
                STATUS_NEXT = TRACKER_ERROR;
                tracker_next_reg = 1'b1;
            end
            else begin
                left_motor_next_reg     = 2'b01;
                right_motor_next_reg    = 2'b01;
                STATUS_NEXT             = PWR_ON_IDLE; 
            end
        end
        TURN_LEFT: begin
            motor_status_next_reg   = 1'b1;
            left_motor_next_reg     = 2'b10; //левая гусеница назад
            right_motor_next_reg    = 2'b01; //правая гусеница вперед
            STATUS_NEXT             = PWR_ON_IDLE;
        end
        TURN_RIGHT: begin
            motor_status_next_reg   = 1'b1;
            left_motor_next_reg     = 2'b01; //левая гусеница вперед
            right_motor_next_reg    = 2'b10; //правая гусеница назад
            STATUS_NEXT             = PWR_ON_IDLE;
        end
        MOVE_BACK: begin
            motor_status_next_reg   = 1'b1;
            left_motor_next_reg     = 2'b10;
            right_motor_next_reg    = 2'b10;
            STATUS_NEXT             = PWR_ON_IDLE;
        end
        TRACKER_ERROR:  begin
            motor_status_next_reg   = 1'b1;
            tracker_next_reg        = 1'b1;
            STATUS_NEXT             = PWR_ON_IDLE;
        end
        default:
            STATUS_NEXT             = PWR_OFF;
    endcase   
end 

assign left_motor_o     =   left_motor_current_reg;
assign right_motor_o    =   right_motor_current_reg;
assign motor_status_o   =   motor_status_current_reg;
assign tracker_status_o =   tracker_current_reg;

endmodule