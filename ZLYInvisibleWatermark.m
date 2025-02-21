//
//  ZLYInvisibleWatermark.m
//  Pods-ZLYInvisibleWatermark_Example
//
//  Created by 周凌宇 on 2019/2/21.
//

#import "ZLYInvisibleWatermark.h"
#import <CoreGraphics/CoreGraphics.h>

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@implementation ZLYInvisibleWatermark

#pragma mark - 可视水印处理
/// 将隐写水印转换为可视水印
/// @param image 包含隐写水印的原始图片
/// @return 带有可视水印的图片
+ (UIImage *)visibleWatermark:(UIImage *)image {
    // 1. 准备图像参数
    CGImageRef inputCGImage = [image CGImage];
//    物理像素宽度
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    
    // 2. 创建颜色空间和绘图上下文
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    // 3. 分配内存存储像素数据
    UInt32 *inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    // 4. 创建位图上下文
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 8, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 5. 绘制原始图像到上下文
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);

    // 6. 像素级处理（提取水印信息）
    for (int j = 0; j < inputHeight; j++) {
        for (int i = 0; i < inputWidth; i++) {
            @autoreleasepool {
                //当前像素
                //j 代表行
                //i 代表列
                //inputPixels 是像素数组,地址为整个图片像素的起始地址,通过计算指针偏移量,获取当前像素的地址
                //inputPixels + (j * inputWidth) + i 是当前像素的地址
                UInt32 *currentPixel = inputPixels + (j * inputWidth) + i;
                UInt32 color = *currentPixel;
                // 7. 分解颜色通道
                UInt32 thisR = R(color);
                UInt32 thisG = G(color);
                UInt32 thisB = B(color);
                UInt32 thisA = A(color);
                // 8. 应用颜色混合算法提取水印
                //为什么 thisA 不参与混合计算?
                //因为 thisA 此时通过之前添加水印,原始图片和水印图片混合成新的图片,混合后,值为固定255,所以 thisA 不参与混合计算
                UInt32 newR = [self mixedCalculation:thisR];
                UInt32 newG = [self mixedCalculation:thisG];
                UInt32 newB = [self mixedCalculation:thisB];
                
                
                // 9. 重组像素数据
                *currentPixel = RGBAMake(newR, newG, newB, thisA);
            }
        }
    }
    // 10. 生成处理后的图像
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *processedImage = [UIImage imageWithCGImage:newCGImage];
    // 11. 释放资源
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);

    return processedImage;
}

#pragma mark - 水印处理核心算法
/// 颜色混合计算（核心水印算法）
/// @param originValue 原始颜色通道值（0-255）
/// @return 处理后的颜色通道值
+ (int)mixedCalculation:(int)originValue {
    // 显示水印时的算法：
    // 接近白色的区域保持不变（背景）
    // 其他区域（水印文字）显示为黑色
    if (originValue >= 253) {  // 接近白色的阈值
        return originValue;    // 白色背景保持不变
    }
    return 127;                  // 水印文字显示为黑色
}


#pragma mark - 添加文字水印
/// 添加全屏重复文字水印（同步方法）
/// @param image 原始图片
/// @param text 水印文字
/// @return 添加水印后的图片
+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text {
    // 添加图片尺寸限制
    CGFloat maxSize = 4096.0f; // 设置最大尺寸
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    if (width > maxSize || height > maxSize) {
        CGFloat scale = MIN(maxSize/width, maxSize/height);
        width *= scale;
        height *= scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, width, height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // 创建单个绘图上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // 配置水印文字样式 - 使用非常低的透明度使水印隐形
    UIFont *font = [UIFont systemFontOfSize:32];
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor colorWithRed:127 green:127 blue:127 alpha:0.01]
    };
    
    // 计算平铺参数
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGFloat horizontalStep = textSize.width * 2;
    CGFloat verticalStep = textSize.height * 2;
    
    // 在同一个上下文中绘制所有水印
    for (CGFloat y = 0; y < image.size.height; y += verticalStep) {
        for (CGFloat x = 0; x < image.size.width; x += horizontalStep) {
            CGRect textRect = CGRectMake(x, y, textSize.width, textSize.height);
            [text drawInRect:textRect withAttributes:attributes];
        }
    }
    
    // 生成最终图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/// 添加文字水印（异步方法）
/// @param image 原始图片
/// @param text 水印文字
/// @param completion 完成回调
+ (void)addWatermark:(UIImage *)image
               text:(NSString *)text
         completion:(void (^ __nullable)(UIImage *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *result = [self addWatermark:image text:text];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result);
            });
    });
}

@end
