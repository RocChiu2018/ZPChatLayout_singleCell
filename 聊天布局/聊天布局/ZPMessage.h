//
//  ZPMessage.h
//  聊天布局
//
//  Created by apple on 16/6/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 有固定取值的就要用枚举类型；
 枚举常量要用枚举类型名称作为开头进行命名。
 */
typedef enum {
    messageTypeMe = 0,  //自己发送的消息，在聊天页面的右侧
    messageTypeOther = 1   //对方发送的消息，在聊天页面的左侧
}messageType;

@interface ZPMessage : NSObject

@property (nonatomic, strong) NSString *text;  //聊天内容
@property (nonatomic, strong) NSString *time;  //消息发送时间
@property (nonatomic, assign) messageType type;  //判断是哪方发出的消息
@property (nonatomic, assign) CGFloat cellHeight;  //每个会话cell的高度
@property (nonatomic, assign) BOOL isHideTime;  //是否隐藏消息发送时间

+ (instancetype)messageWithDict:(NSDictionary *)dict;

@end
