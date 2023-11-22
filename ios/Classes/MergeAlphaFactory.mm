//
//
//  Created by fgsoruco.
//

#import "MergeAlphaFactory.h"
@implementation MergeAlphaFactory

// + (void)processWhitPathType:(int)pathType pathString:(NSString *)pathString data:(FlutterStandardTypedData *)data alphaPercent:(double)alphaPercent result:(FlutterResult)result {
//     // 在这里实现你的方法
// }

+ (void)processWhitPathType:(int)pathType pathString:(NSString *)pathString data:(FlutterStandardTypedData *)data alphaPercent: (double) alphaPercent result: (FlutterResult) result{
    
    NSLog(@"pathType: %d", pathType);
    NSLog(@"pathString: %@", pathString);
    NSLog(@"data: %@", data);
    NSLog(@"alphaPercent: %f", alphaPercent);
    if (alphaPercent > 1.0) {
        alphaPercent = 1.0;
    }
    switch (pathType) {
        case 1:
            result(mergeS(pathString, alphaPercent));
            break;
        case 2:
            result(mergeB(data, alphaPercent));
            break;
        case 3:
            result(mergeB(data, alphaPercent));
            break;
        
        default:
            break;
    }
    
}

FlutterStandardTypedData * mergeS(NSString * pathString, double alphaPercent) {
    

    CGColorSpaceRef colorSpace;
    const char * suffix;
    int bytesInFile;
    const char * command;
    std::vector<uint8_t> fileData;
    bool puedePasar = false;
    FlutterStandardTypedData* resultado;
    
    
    command = [pathString cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* file = fopen(command, "rb");
    fseek(file, 0, SEEK_END);
    bytesInFile = (int) ftell(file);
    fseek(file, 0, SEEK_SET);
    std::vector<uint8_t> file_data(bytesInFile);
    fread(file_data.data(), 1, bytesInFile, file);
    fclose(file);
    
    fileData = file_data;
    
    NSData *imgOriginal = [NSData dataWithBytes: file_data.data()
                                   length: bytesInFile];
    
    
    suffix = strrchr(command, '.');
    if (!suffix || suffix == command) {
        suffix = "";
    }
    
    if (strcasecmp(suffix, ".png") == 0 || strcasecmp(suffix, ".jpg") == 0 || strcasecmp(suffix, ".jpeg") == 0) {
        puedePasar = true;
    }
 
    
    if (puedePasar) {
        NSData * respuesta;
        if(alphaPercent != 1.0){
            
            
            CFDataRef file_data_ref = CFDataCreateWithBytesNoCopy(NULL, fileData.data(),
                                                                  bytesInFile,
                                                                  kCFAllocatorNull);
            
            CGDataProviderRef image_provider = CGDataProviderCreateWithCFData(file_data_ref);
            
            CGImageRef image = nullptr;
            if (strcasecmp(suffix, ".png") == 0) {
                image = CGImageCreateWithPNGDataProvider(image_provider, NULL, true,
                                                         kCGRenderingIntentDefault);
            } else if ((strcasecmp(suffix, ".jpg") == 0) ||
                       (strcasecmp(suffix, ".jpeg") == 0)) {
                image = CGImageCreateWithJPEGDataProvider(image_provider, NULL, true,
                                                          kCGRenderingIntentDefault);
            }
            
            colorSpace = CGImageGetColorSpace(image);
            CGFloat cols = CGImageGetWidth(image);
            CGFloat rows = CGImageGetHeight(image);
            
            cv::Mat src(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
            
            CGContextRef contextRef = CGBitmapContextCreate(src.data,                 // Pointer to  data
                                                             cols,                       // Width of bitmap
                                                             rows,                       // Height of bitmap
                                                             8,                          // Bits per component
                                                             src.step[0],              // Bytes per row
                                                             colorSpace,                 // Colorspace
                                                             kCGImageAlphaNoneSkipLast |
                                                             kCGBitmapByteOrderDefault); // Bitmap info flags
            CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
            CGContextRelease(contextRef);
            CFRelease(image);
            CFRelease(image_provider);
            CFRelease(file_data_ref);
            
            
            cv::Mat dst;
            if (src.channels() != 4) {
                cv::cvtColor(src, src, cv::COLOR_BGR2BGRA);
            } else {
                dst = src.clone();
            }
            cv::Mat img_rgba[4];
            cv::split(src, img_rgba);
            // 改变 alpha 通道的值
            img_rgba[3] = img_rgba[3] * alphaPercent;
            cv::merge(img_rgba, 4, dst);
            
            NSData *data = [NSData dataWithBytes:dst.data length:dst.elemSize()*dst.total()];
            
            if (dst.channels() == 1) {
                  colorSpace = CGColorSpaceCreateDeviceGray();
              } else {
                  colorSpace = CGColorSpaceCreateDeviceRGB();
              }

            CGContextRef contextRef2 = CGBitmapContextCreate(dst.data, dst.cols, dst.rows, 8, dst.step[0], colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
            CGImageRef imageRef = CGBitmapContextCreateImage(contextRef2);
              // Getting UIImage from CGImage
            UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            CGContextRelease(contextRef2);
            CGColorSpaceRelease(colorSpace);
            
            NSData* imgConvert;
            imgConvert = UIImagePNGRepresentation(finalImage);
            // if (strcasecmp(suffix, ".png") == 0) {
            //     imgConvert = UIImagePNGRepresentation(finalImage);
            // } else if ((strcasecmp(suffix, ".jpg") == 0) ||
            //            (strcasecmp(suffix, ".jpeg") == 0)) {
            //     imgConvert = UIImageJPEGRepresentation(finalImage, 1);
            // }
            
            
            respuesta = imgConvert;
        } else {
            respuesta = imgOriginal;
        }
        
        
        resultado = [FlutterStandardTypedData typedDataWithBytes: respuesta];
        
    } else {
        resultado = [FlutterStandardTypedData typedDataWithBytes: imgOriginal];
    }
    
    return resultado;
}

FlutterStandardTypedData * mergeB(FlutterStandardTypedData * data, double alphaPercent) {
    

    CGColorSpaceRef colorSpace;
    const char * suffix;
    std::vector<uint8_t> fileData;
    
    FlutterStandardTypedData* resultado;
    
    cv::Mat src;
    
    
    UInt8* valor1 = (UInt8*) data.data.bytes;
    
    int size = data.elementCount;
    

    CFDataRef file_data_ref = CFDataCreateWithBytesNoCopy(NULL, valor1,
                                                          size,
                                                          kCFAllocatorNull);
    
    CGDataProviderRef image_provider = CGDataProviderCreateWithCFData(file_data_ref);
    
    CGImageRef image = nullptr;
    
    image = CGImageCreateWithPNGDataProvider(image_provider, NULL, true,
                                                 kCGRenderingIntentDefault);
    suffix = (char*)".png";
//    NSLog(@"image198: %@", image);
    if (image == nil) {
        image = CGImageCreateWithJPEGDataProvider(image_provider, NULL, true,
                                                  kCGRenderingIntentDefault);
        suffix = (char*)".jpg";
    }
//    NSLog(@"image204: %@", image);
    if (image == nil) {
        suffix = (char*)"otro";
    }
//    NSLog(@"image208: %@", image);
    if(!(strcasecmp(suffix, "otro") == 0)){
        colorSpace = CGImageGetColorSpace(image);
        CGFloat cols = CGImageGetWidth(image);
        CGFloat rows = CGImageGetHeight(image);
        
        src = cv::Mat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
        CGContextRef contextRef = CGBitmapContextCreate(src.data,                 // Pointer to  data
                                                         cols,                       // Width of bitmap
                                                         rows,                       // Height of bitmap
                                                         8,                          // Bits per component
                                                         src.step[0],              // Bytes per row
                                                         colorSpace,                 // Colorspace
                                                         kCGImageAlphaNoneSkipLast |
                                                         kCGBitmapByteOrderDefault); // Bitmap info flags
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
        CGContextRelease(contextRef);
        CFRelease(image);
        CFRelease(image_provider);
        CFRelease(file_data_ref);
    } else {
        src = cv::Mat();
    }

//    NSLog(@"image232: pass");
    if(src.empty()){
        resultado = [FlutterStandardTypedData typedDataWithBytes: data.data];
    } else {
        NSData * respuesta;
        
        if(alphaPercent != 1.0){
//            NSLog(@"image232: channels %d", src.channels());
            cv::Mat dst;
            if (src.channels() != 4) {
                cv::cvtColor(src, src, cv::COLOR_BGR2BGRA);
            } else {
                dst = src.clone();
            }
            // cv::Mat img_rgba[4];
            std::vector<cv::Mat> img_rgba(4);
            cv::split(src, img_rgba);
            // 创建一个与 alpha 通道相同大小但所有值都是 alphaPercent 的矩阵
//            NSLog(@"image252: type %d", img_rgba[3].type());
            cv::Mat alphaFactor(img_rgba[3].size(), CV_32F, cv::Scalar(alphaPercent));
            // 临时矩阵用于存储乘法结果
            cv::Mat temp;
            img_rgba[3].convertTo(temp, CV_32F); // 转换 alpha 通道到浮点型
            cv::multiply(temp, alphaFactor, temp); // 执行乘法
            temp.convertTo(img_rgba[3], img_rgba[3].type()); // 将结果转换回原始数据类型
//            img_rgba[3] = alphaFactor;
            cv::merge(img_rgba, dst);
            NSData *data = [NSData dataWithBytes:dst.data length:dst.elemSize()*dst.total()];
            
            if (dst.channels() == 1) {
                  colorSpace = CGColorSpaceCreateDeviceGray();
            } else {
                  colorSpace = CGColorSpaceCreateDeviceRGB();
            }
            CGContextRef contextRef = CGBitmapContextCreate(dst.data, dst.cols, dst.rows, 8, dst.step[0], colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
            CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);

              // Getting UIImage from CGImage
            UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            CGContextRelease(contextRef);
            CGColorSpaceRelease(colorSpace);
            
            NSData* imgConvert;
            imgConvert = UIImagePNGRepresentation(finalImage);
            // if (strcasecmp(suffix, ".png") == 0) {
            //     NSLog(@"image271: png");
            //     imgConvert = UIImagePNGRepresentation(finalImage);
            // } else if ((strcasecmp(suffix, ".jpg") == 0) ||
            //            (strcasecmp(suffix, ".jpeg") == 0)) {
            //             NSLog(@"image275: jpg");
            //     imgConvert = UIImageJPEGRepresentation(finalImage, 1);
            // }
            
            //********
            
            respuesta = imgConvert;
            
        } else {
            
            respuesta = data.data;
        }
        
        
        resultado = [FlutterStandardTypedData typedDataWithBytes: respuesta];
    }
//    NSLog(@"image292: %@", resultado);
    return resultado;
}


@end
