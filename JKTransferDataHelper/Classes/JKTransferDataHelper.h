//
//  JKTransferDataHelper.h
//  JKTransferDataHelper
//
//  Created by JackLee on 2018/12/17.
//

#import <Foundation/Foundation.h>
//网络传输是大端字节顺序 蓝牙传输是小端字节顺序
typedef NS_ENUM(NSInteger,JKTransferByteSortType){
    JKTransferByteSortBig,            ///< 大端字节顺序  byte sort big model
    JKTransferByteSortSmall           ///< 小端字节顺序  byte sort smallModel
};
@interface JKTransferDataConfig : NSObject

@property (nonatomic,assign) NSUInteger mtuSize;       ///< 最大传输单元大小 单位是位
@property (nonatomic,assign) NSUInteger packetHeadSize;///< 数据包头的size 单位是位
@property (nonatomic,assign) JKTransferByteSortType byteSortType;///< 字节顺序

+ (instancetype)configMTUSize:(NSUInteger)mtuSize packetHeadSize:(NSUInteger)packetHeadSize byteSortType:(JKTransferByteSortType)byteSortType;

@end

@interface JKTransferDataHelper : NSObject

+ (NSMutableData *)formatData:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig;
+ (NSMutableData *)unFormatData:(NSMutableData *)data dataConfig:(JKTransferDataConfig *)dataConfig;

@end

