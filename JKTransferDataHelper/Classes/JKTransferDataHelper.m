//
//  JKTransferDataHelper.m
//  JKTransferDataHelper
//
//  Created by JackLee on 2018/12/17.
//

#import "JKTransferDataHelper.h"

@implementation JKTransferDataConfig

+ (instancetype)configMTUSize:(NSUInteger)mtuSize packetHeadSize:(NSUInteger)packetHeadSize byteSortType:(JKTransferByteSortType)byteSortType{
    JKTransferDataConfig *dataConfig = [[JKTransferDataConfig alloc] init];
    dataConfig.mtuSize = mtuSize;
    dataConfig.packetHeadSize = packetHeadSize;
    dataConfig.byteSortType = byteSortType;
    return dataConfig;
}

@end

@implementation JKTransferDataHelper

+ (NSMutableData *)formatData:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig{

    NSMutableData *packetBodyData = [self configPacketBody:data dataConfig:dataConfig];
    NSData *packetHeadData = [self configPacketHead:packetBodyData.length dataConfig:dataConfig];

    NSMutableData *mutableData = [NSMutableData new];
    [mutableData appendData:packetHeadData];
    [mutableData appendData:packetBodyData];
    return mutableData;
}

+ (NSMutableData *)unFormatData:(NSMutableData *)data dataConfig:(JKTransferDataConfig *)dataConfig{
    NSUInteger dataLength = [self getOriginDataLength:data dataConfig:dataConfig];
    
    if (data.length >= (dataLength + dataConfig.packetHeadSize)) {
        NSData *packetData = [data subdataWithRange:NSMakeRange(dataConfig.packetHeadSize-1, dataLength)];
        NSMutableData *realData = [self getDataWithNoSortNum:packetData dataConfig:dataConfig];
        return realData;
    }
    
    return nil;
}

+ (NSData *)configPacketHead:(NSUInteger)originDataLength dataConfig:(JKTransferDataConfig *)dataConfig{
    NSUInteger coverted;
    if (dataConfig.byteSortType == JKTransferByteSortSmall) {//small model
        if (dataConfig.packetHeadSize ==4) {
            coverted = NTOHL(originDataLength);
        }else if (dataConfig.packetHeadSize == 2){
            coverted = NTOHS(originDataLength);
        }else if (dataConfig.packetHeadSize == 8){
            coverted = NTOHLL(originDataLength);
        }else{
            NSAssert(NO, @"now do not support");
        }
        NSData *packetHeadData = [NSData dataWithBytes:&coverted length:dataConfig.packetHeadSize];
        return packetHeadData;
    }
    //big model
    if (dataConfig.packetHeadSize ==4) {
        coverted = HTONL(originDataLength);
    }else if (dataConfig.packetHeadSize == 2){
        coverted = HTONS(originDataLength);
    }else if (dataConfig.packetHeadSize == 8){
        coverted = HTONLL(originDataLength);
    }else{
      NSAssert(NO, @"now do not support");
    }
    NSData *packetHeadData = [NSData dataWithBytes:&coverted length:dataConfig.packetHeadSize];
    return packetHeadData;
}

+ (NSMutableData *)configPacketBody:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig{
    NSUInteger packetNum = ceil(data.length *1.0/(dataConfig.mtuSize - dataConfig.packetHeadSize));
    NSUInteger tailDataLength = data.length%(dataConfig.mtuSize - dataConfig.packetHeadSize);
    NSMutableData *mutableData = [NSMutableData new];
    for (NSUInteger i = 0; i< packetNum-1; i++) {
        NSUInteger location = i*dataConfig.mtuSize;
        NSRange range = NSMakeRange(location, (dataConfig.mtuSize- dataConfig.packetHeadSize));
        NSData *unitPacketData = [data subdataWithRange:range];
        NSData *unitPacketHeadData = [self configPacketHead:i dataConfig:dataConfig];
        [mutableData appendData:unitPacketHeadData];
        [mutableData appendData:unitPacketData];
    }
    if(tailDataLength >0){
        NSUInteger location = (packetNum -1) *(dataConfig.mtuSize- dataConfig.packetHeadSize);
        NSRange range = NSMakeRange(location, tailDataLength);
        NSData *unitPacketBodyData = [data subdataWithRange:range];
        NSData *unitPacketHeadData = [self configPacketHead:packetNum -1 dataConfig:dataConfig];
        [mutableData appendData:unitPacketHeadData];
        [mutableData appendData:unitPacketBodyData];
    }
    return mutableData;
}

+ (NSUInteger)getOriginDataLength:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig{
    if (data.length > dataConfig.packetHeadSize) {
        NSData *packetHeadData = [data subdataWithRange:NSMakeRange(0, dataConfig.packetHeadSize)];
        NSUInteger dataLength =0;
        [packetHeadData getBytes:&dataLength length:dataConfig.packetHeadSize];
        NSUInteger coverted = 0;
        if (dataConfig.byteSortType == JKTransferByteSortSmall) {//small model
            if (dataConfig.packetHeadSize ==4) {
                coverted = HTONL(dataLength);
            }else if (dataConfig.packetHeadSize == 2){
                coverted = HTONS(dataLength);
            }
            else if (dataConfig.packetHeadSize == 8){
                coverted = HTONLL(dataLength);
            }else{
                NSAssert(NO, @"now do not support");
            }
            return coverted;
        }
        //big model
        if (dataConfig.packetHeadSize ==4) {
            coverted = NTOHL(dataLength);
        }else if (dataConfig.packetHeadSize == 2){
            coverted = NTOHS(dataLength);
        }else if (dataConfig.packetHeadSize == 8){
            coverted = NTOHLL(dataLength);
        }else{
            NSAssert(NO, @"now do not support");
        }
        return coverted;
    }
    return 0;
}

+ (NSMutableData *)getDataWithNoSortNum:(NSData *)data dataConfig:(JKTransferDataConfig *)dataConfig{
    NSUInteger packetNum = ceil(data.length *1.0/(dataConfig.mtuSize));
    NSUInteger tailDataLength = data.length%(dataConfig.mtuSize);
    NSMutableData *mutableData = [NSMutableData new];
    for (NSUInteger i = 0; i< packetNum-1; i++) {
        NSUInteger location = i*dataConfig.mtuSize;
        NSRange range = NSMakeRange(location, dataConfig.mtuSize);
        NSData *unitPacketData = [data subdataWithRange:range];
        NSData *packetBodyData = [unitPacketData subdataWithRange:NSMakeRange(dataConfig.packetHeadSize-1, (dataConfig.mtuSize - dataConfig.packetHeadSize))];
        [mutableData appendData:packetBodyData];
    }
    if(tailDataLength >dataConfig.packetHeadSize){
        NSUInteger location = (packetNum -1) *dataConfig.mtuSize;
        NSRange range = NSMakeRange(location, tailDataLength);
        NSData *unitPacketData = [data subdataWithRange:range];
        NSData *packetBodyData = [unitPacketData subdataWithRange:NSMakeRange(dataConfig.packetHeadSize-1, (tailDataLength - dataConfig.packetHeadSize))];
       
        [mutableData appendData:packetBodyData];
    }
    return mutableData;
}

@end
