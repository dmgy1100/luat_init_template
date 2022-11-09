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


btn_name = pins.setup(gpio, btn_cb, pio.PULLUP)            --初始化按键gpio,初始化为拉高
--按键中断回调函数
function btn_cb(msg)
    if msg == cpu.INT_GPIO_POSEDGE then
        --上升沿
    elseif msg == cpu.INT_GPIO_NEGEDGE then
        --下降沿
    end
end
--长按判断定时器
function key_loop_timer(key)
    key_power_times = key_power_times + 1
    if key_power_times >= 3 then                     --长按开关机
        if key_timer ~= nil then
            sys.timerStop(key_timer)
            key_timer = nil
        end
        key_event(key, 3)
    end
    log.info("button","定时器检测",key_power_times)
end
--单击判断定时器
function key_one_timer(key)
    if key_power_count == 2 then                    --电源键双击
        key_event(key, 2)
        key_power_count = 0
    elseif key_power_count == 1 then
        key_event(key, 1)
        key_power_count = 0
    else
        key_power_count = 0
    end 
end
--按键status,1：单击；2 ：双击；3；长按
--处理按键事件
function key_event(key, status)
    if key == key_name then
        if status == 1 then                     
            --单击操作
        elseif status == 2 then
            --双击操作
        elseif status == 3 then
            --长按操作
        end
    end
end
--生成按键事件
function create_key_event(key, status)
    --log.info("button","生成按键事件")
    if status == 0 then
        if key_timer ~= nil then
            sys.timerStop(key_timer)
            key_timer = nil
        end
        if key_down_times < 2 then
            if key_power_count == 0 then
                sys.timerStart(key_one_timer, 1000, key)
            end
            key_power_count = key_power_count + 1
        else
            key_down_times = 0
        end
    elseif status == 1 then
        if key_timer == nil then
            key_timer = sys.timerLoopStart(key_loop_timer, 1000, key)
        end
    end
end