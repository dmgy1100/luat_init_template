module(..., package.seeall)

--初始化gpio为输出模式
gpio_ctrl_out = pins.setup(gpio, 0)                                 --初始化话gpio,默认拉低，gpio 如 spio.P0_4
gpio_ctrl_out1 = pins.setup(gpio, 1)                                --初始化话gpio,默认拉高

gpio_ctrl_out(1)                                                    --控制拉高
gpio_ctrl_out(0)                                                    --控制拉低

--初始化gpio为输入模式
gpio_ctrl_in = pins.setup(gpio)                                     --初始化gpio为输入模式                                  
pio.pin.setpull(pio.PULLUP, gpio)                                   --设置gpio默认为拉高
pio.pin.setpull(pio.PULLDOWN, gpio)                                 --设置gpio默认为拉低
--初始化gpio为中断模式
gpio_ctrl_irq = pins.setup(gpio, btn_cb, pio.PULLUP)                --初始化按键gpio,默认拉高
gpio_ctrl_irq = pins.setup(gpio, btn_cb, pio.PULLDOWN)              --初始化按键gpio,默认拉低
--按键中断回调函数
function btn_cb(msg)
    if msg == cpu.INT_GPIO_POSEDGE then
        --上升沿
    elseif msg == cpu.INT_GPIO_NEGEDGE then
        --下降沿
    end
end
--TDOD:某些gpio需要打开电压域
pmd.ldoset(x,pmd.LDO_VSIM1)                                         -- GPIO 29、30、31
pmd.ldoset(x,pmd.LDO_VLCD)                                          -- GPIO 0、1、2、3、4
--注意：
--Air724 A11以及之前的开发板丝印有误:
--丝印中的IO_0、IO_1、IO_2、IO_3、IO_4并不对应GPIO0、1、2、3、4
--丝印中的LCD_DIO、LCD_RS、LCD_CLK、LCD_CS对应GPIO0、1、2、3；模块的LCD_SEL引脚对应GPIO4
pmd.ldoset(x,pmd.LDO_VMMC)                                          -- GPIO 24、25、26、27、28
--[[
x=0时：关闭LDO
x=1时：LDO输出1.716V
x=2时：LDO输出1.828V
x=3时：LDO输出1.939V
x=4时：LDO输出2.051V
x=5时：LDO输出2.162V
x=6时：LDO输出2.271V
x=7时：LDO输出2.375V
x=8时：LDO输出2.493V
x=9时：LDO输出2.607V
x=10时：LDO输出2.719V
x=11时：LDO输出2.831V
x=12时：LDO输出2.942V
x=13时：LDO输出3.054V
x=14时：LDO输出3.165V
x=15时：LDO输出3.177V
]]
