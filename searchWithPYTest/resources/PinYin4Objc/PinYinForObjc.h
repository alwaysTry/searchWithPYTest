//
//  PinYinForObjc.h
//  Search
//
//  Created by yanzhg on 14-9-4.
//  Copyright (c) 2014年 yanzhg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HanyuPinyinOutputFormat.h"
#import "PinyinHelper.h"

@interface PinYinForObjc : NSObject

+ (NSString*)chineseConvertToPinYin:(NSString*)chinese;//转换为拼音
+ (NSString*)chineseConvertToPinYinHead:(NSString *)chinese;//转换为拼音首字母
@end
