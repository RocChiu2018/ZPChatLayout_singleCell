//
//  ZPMessage.m
//  聊天布局
//
//  Created by apple on 16/6/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZPMessage.h"

@implementation ZPMessage

+ (instancetype)messageWithDict:(NSDictionary *)dict
{
    ZPMessage *message = [[self alloc] init];
    [message setValuesForKeysWithDictionary:dict];
    
    return message;
}

@end
