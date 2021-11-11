import numpy as np 
from PIL import Image
import cairo as cr
import ffmpeg

dump_path = './simulation/modelsim/dump.txt' # modelsim仿真输出文件路径
video_path = 'video.mp4' # 输出渲染视频路径
frame_size = (32, 32) # led点阵大小（个数）

size = (720, 720) # 图像大小
display_size = (160, 160) # led点阵渲染大小
surface = cr.ImageSurface(cr.FORMAT_ARGB32, *size)
ctx = cr.Context(surface)
led_radius = 0.2 # led半径
led_color = (1, 0.1, 0.1) # led颜色
led_color1 = (*led_color, 0.8) # led外发光渐变颜色1
led_color2 = (*led_color, 0) # led外发光渐变颜色2

fps = 30 # 视频帧数
sync_speed = 10 # led点阵同步ram速率

def get_data_from_dump():
    '''
    从仿真文件中获得虚拟显示屏上的帧数据
    '''
    frames = []
    with open(dump_path) as f:
        buf = f.read()
    lines = buf.splitlines()
    frame = None
    row = 0
    col = 0
    for line in lines:
        if not line: continue
        if line[0] == 'f': # frame 是帧开始标志
            if frame is not None:
                frames.append(frame)
            frame = []
            row = 0
            col = 0
        else:
            d = int(line.strip()) # 每行是一个字节数据
            for i in range(8):
                if (d >> i) & 1:
                    frame.append((row, col + 7 - i)) # 如果这个led亮了，那么记录这个led坐标
            row += 1
            if row == frame_size[0]:
                row = 0
                col += 8
    return frames

def draw(frame):
    ctx.set_source_rgb(0, 0, 0)
    ctx.rectangle(0, 0, *size)
    ctx.fill() # 填充背景
    ctx.save()
    w1, h1 = size
    w2, h2 = display_size
    ctx.translate((w1 - w2) / 2, (h1 - h2) / 2) # 画布居中平移
    ctx.set_source_rgb(*led_color)
    ctx.rectangle(0, 0, *display_size)
    ctx.set_line_width(4)
    ctx.stroke() # 绘制显示区域边框
    scale = w2 / 32
    ctx.scale(scale, scale) # 缩放画布，使得 0 -> 32 的范围缩放至 0 -> w2
    for row, col in frame:
        x = col
        y = row
        gr = led_radius * 4
        g = cr.RadialGradient(x, y, 0, x, y, gr)
        g.add_color_stop_rgba(0, *led_color1)
        g.add_color_stop_rgba(0.8, *led_color2)
        ctx.set_source(g)
        ctx.arc(x, y, gr, 0, np.pi * 2)
        ctx.fill()
        ctx.set_source_rgb(*led_color)
        ctx.arc(x, y, led_radius, 0, np.pi * 2)
        ctx.fill()
    ctx.restore()
    arr = np.ndarray((size[1], size[0]), np.uint32, surface.get_data())
    def op(bits):
        '''
        分离rgb通道数据
        '''
        b = np.bitwise_and(arr, 0xff << bits)
        b = np.right_shift(b, bits)
        b = np.expand_dims(b, -1)
        return b.astype(np.uint8)
    r = op(16)
    g = op(8)
    b = op(0)
    return (r, g, b)

def show(r, g, b):
    '''
    预览帧输出
    '''
    rgb = np.concatenate((r, g, b), 2).astype(np.uint8)
    img = Image.fromarray(rgb)
    img.show()

def main():
    frames = get_data_from_dump()
    # r, g, b = draw(frames[0])
    # show(r,g,b)
    frame_size = min(32 * (6 * 2 - 1), len(frames))
    dt = 1 / fps
    t = 0
    frame_index = 0
    
    # 使用ffmpeg子进程输出视频，我们从process的stdin输入数据给ffmpeg进程
    # 随后ffmpeg会输出一个视频文件
    process = (
        ffmpeg
        .input('pipe:', format='rawvideo', pix_fmt='rgb24', s='{}x{}'.format(*size))
        .output(video_path, pix_fmt='yuv420p', r=fps)
        .overwrite_output()
        .run_async(pipe_stdin=True)
    )
    while frame_index < frame_size:
        frame = frames[frame_index]
        r, g, b = draw(frame)
        rgb = np.concatenate((r, g, b), 2) # 合并rgb数据
        process.stdin.write(rgb.tobytes()) # 输出rgb序列字节给ffmpeg
        t += dt
        frame_index = int(t * sync_speed)
    
if __name__ == '__main__':
    main()