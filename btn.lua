module(..., package.seeall)                                         --将次文件定义为模块，可以通过require导入

local key_down_times = 1
local key_timer = nil
local key_down_count = 0
local keypad_status = {["keyname"] = false}
local key_off_flag = false
--软件关机
local tKeypad = {["255255"] = "开关机"}
local function keyLongPressTimerCb(keyName)
    --powerkey长按触发
end
--矩阵键盘长按判断定时器
function key_off_timer(keyName)
    keypad_status[keyName] = true
end
local function keyMsg(msg)
    local keyName = tKeypad[msg.key_matrix_row..msg.key_matrix_col]
    if msg.pressed then
        sys.timerLoopStart(key_off_timer,2000, keyName)
        sys.timerStart(keyLongPressTimerCb, 2500, keyName)
    else
        keypad_status[keyName] = false
    end
end
rtos.on(rtos.MSG_KEYPAD, keyMsg)                                        --初始化矩阵键盘
rtos.init_module(rtos.MOD_KEYPAD,0,0x3c,0x0F)                           --设置矩阵键盘模式
--按键检测
local CLICK = 1
local DOUBLE_CLICK = 2
local LONG_PRESS = 3
--定义按键结构体
local button = {
    button_init_callback = nil,
    button_event_callback = nil
}
--长按判断定时器
function key_loop_timer(button)
    key_power_times = key_power_times + 1
    if key_power_times >= 3 then                     --长按开关机
        if key_timer ~= nil then
            sys.timerStop(key_timer)
            key_timer = nil
        end
        button.button_event_callback(LONG_PRESS)
    end
end
--单双击判断定时器
function key_one_timer(button)
    if key_power_count == 2 then                    --双击
        button.button_event_callback(DOUBLE_CLICK)
        key_power_count = 0
    elseif key_power_count == 1 then
        button.button_event_callback(CLICK)
        key_power_count = 0
    else
        key_power_count = 0
    end 
end
--生成按键事件
function create_key_event(button, status)
    if status == 0 then
        if key_timer ~= nil then
            sys.timerStop(key_timer)
            key_timer = nil
        end
        if key_down_times < 2 then
            if key_power_count == 0 then
                sys.timerStart(key_one_timer, 1000, button)
            end
            key_power_count = key_power_count + 1
        else
            key_down_times = 0
        end
    elseif status == 1 then
        if key_timer == nil then
            key_timer = sys.timerLoopStart(key_loop_timer, 1000, button_name)
        end
    end
end
--使用例子
--按键中断回调函数
function btn_cb(msg)
    if msg == cpu.INT_GPIO_POSEDGE then
        --上升沿
        create_key_event(button, 1)
    elseif msg == cpu.INT_GPIO_NEGEDGE then
        --下降沿
        create_key_event(button, 0)
    end
end
function test_button_callback(status)
    --处理按键事件
    if status == CLICK then                         --按键单击事件
        
    elseif status == DOUBLE_CLICK then              --按键双击事件

    elseif status == LONG_PRESS then                --按键长按

    end
end
local button = {}                                   --定义按键
button.button_init_callback = btn_cb                
button.button_event_callback = test_button_callback
--按键初始化
function button_init(button)
    if button.button_init_callback ~= nil and button.button_event_callback ~= nil then
        btn_name = pins.setup(gpio, button.button_init_callback, pio.PULLUP)            --初始化按键gpio,初始化为拉高
    end
end