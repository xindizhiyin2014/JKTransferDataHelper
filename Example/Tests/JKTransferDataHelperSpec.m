//
//  JKTransferDataHelperSpec.m
//  JKTransferDataHelper
//
//  Created by JackLee on 2018/12/18.
//  Copyright 2018年 xindizhiyin2014. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <JKTransferDataHelper/JKTransferDataHelper.h>

NSString * createStringWithCount(NSInteger count){
    NSMutableString * str = [NSMutableString new];
    for (NSInteger i = 0; i< count; i++) {
        NSString *tempStr = [NSString stringWithFormat:@"%@",@(i%10)];
        [str appendString:tempStr];
    }
    return str;
}

SPEC_BEGIN(JKTransferDataHelperSpec)
static JKTransferDataConfig *dataConfig =nil;
describe(@"JKTransferDataHelper", ^{
    context(@"test JKTransferDataConfig", ^{
        it(@"configMTUSize:", ^{
            JKTransferDataConfig *dataConfig = [JKTransferDataConfig configMTUSize:20 packetHeadSize:4 byteSortType:JKTransferByteSortSmall];
            [[theValue(dataConfig.mtuSize) should] equal:theValue(20)];
            [[theValue(dataConfig.packetHeadSize) should] equal:theValue(4)];
            [[theValue(dataConfig.byteSortType) should] equal:theValue(JKTransferByteSortSmall)];
        });
    });
    context(@"test JKTransferDataHelper", ^{
        beforeEach(^{
          dataConfig = [JKTransferDataConfig configMTUSize:20 packetHeadSize:4 byteSortType:JKTransferByteSortSmall];
        });
        it(@"formatData:", ^{
            NSString *str1 = createStringWithCount(5);
            [[theValue(str1.length) should] equal:theValue(5)];
            NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
           NSData *formatData1 = [JKTransferDataHelper formatData:data1 dataConfig:dataConfig];
            [[theValue(formatData1.length) should] equal:theValue(4 + 4 +5)];

            NSString *str2 = createStringWithCount(20);
            NSData *data2 = [str2 dataUsingEncoding:NSUTF8StringEncoding];
            NSData *formatData2 = [JKTransferDataHelper formatData:data2 dataConfig:dataConfig];
            [[theValue(formatData2.length) should] equal:theValue(4 + 20 +4+4)];
            NSString *str3 = createStringWithCount(20+16);
            NSData *data3 = [str3 dataUsingEncoding:NSUTF8StringEncoding];
            NSData *formatData3 = [JKTransferDataHelper formatData:data3 dataConfig:dataConfig];
            [[theValue(formatData3.length) should] equal:theValue(4 + 20 + 20 +4+4)];
            
        });
        it(@"unFormatData:", ^{
            NSString *str1 = createStringWithCount(5);
            [[theValue(str1.length) should] equal:theValue(5)];
            NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableData *formatData1 = [JKTransferDataHelper formatData:data1 dataConfig:dataConfig];
            [[theValue(formatData1.length) should] equal:theValue(4 + 4 +5)];
            NSMutableData *unFormatData1 = [JKTransferDataHelper unFormatData:formatData1 dataConfig:dataConfig];
            [[theValue(unFormatData1.length) should] equal:theValue(5)];
            NSString *result1 = [[NSString alloc] initWithData:unFormatData1 encoding:NSUTF8StringEncoding];
            [[result1 should] equal:str1];

            NSString *str2 = createStringWithCount(20);
            NSData *data2 = [str2 dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableData *formatData2 = [JKTransferDataHelper formatData:data2 dataConfig:dataConfig];
            [[theValue(formatData2.length) should] equal:theValue(4 + 20 +4+4)];
            NSMutableData *unFormatData2 = [JKTransferDataHelper unFormatData:formatData2 dataConfig:dataConfig];
            [[theValue(unFormatData2.length) should] equal:theValue(20)];
            NSString *result2 = [[NSString alloc] initWithData:unFormatData2 encoding:NSUTF8StringEncoding];
            [[result2 should] equal:str2];

            NSString *str3 = createStringWithCount(20+16);
            NSData *data3 = [str3 dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableData *formatData3 = [JKTransferDataHelper formatData:data3 dataConfig:dataConfig];
            [[theValue(formatData3.length) should] equal:theValue(4 + 20 + 20 +4+4)];

            NSMutableData *unFormatData3 = [JKTransferDataHelper unFormatData:formatData3 dataConfig:dataConfig];
            [[theValue(unFormatData3.length) should] equal:theValue(20 + 16)];
            NSString *result3 = [[NSString alloc] initWithData:unFormatData3 encoding:NSUTF8StringEncoding];
            [[result3 should] equal:str3];
        });
        
        
    });
    
});



SPEC_END
