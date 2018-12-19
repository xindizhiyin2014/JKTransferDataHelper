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

@property (nonatomic,assign) NSUInteger mtuSize;       ///< the transportlation unit  the size is byte
@property (nonatomic,assign) NSUInteger packetHeadSize;///<  the data head,the unit is byte
@property (nonatomic,assign) JKTransferByteSortType byteSortType;///<

+ (instancetype)configMTUSize:(NSUInteger)mtuSize packetHeadSize:(NSUInteger)packetHeadSize byteSortType:(JKTransferByteSortType)byteSortType;

@end

@interface JKTransferDataHelper : NSObject

/**
 handle the data with packet sort Num

 @param data binary data
 @param dataConfig dataConfig
 @return data with sort Num
 */
+ (NSMutableData *)formatData:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig;

/**
 remove the sort Num in binary data

 @param data binary data
 @param dataConfig dataConfig
 @return binary without sorNum
 */
+ (NSMutableData *)unFormatData:(NSMutableData *)data dataConfig:(JKTransferDataConfig *)dataConfig;

/**
 append unitPacketData

 @param unitPacketData unitPacketData
 @param originData the origin data
 @param dataLength the target data length
 @param dataConfig dataConfig
 @return <#return value description#>
 */
+ (NSMutableData *)appendUnitPacketData:(NSData *)unitPacketData originData:(NSMutableData *)originData dataLength:(NSUInteger)dataLength dataConfig:(JKTransferDataConfig *)dataConfig;

/**
 config the binary data head

 @param originDataLength the data length
 @param dataConfig dataConfig
 @return the binary data of data head
 */
+ (NSData *)configPacketHead:(NSUInteger)originDataLength dataConfig:(JKTransferDataConfig *)dataConfig;

/**
 get the origin data length

 @param data  binary data
 @param dataConfig dataConfig
 @return the origin length of the data
 */
+ (NSUInteger)getOriginDataLength:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig;

@end

