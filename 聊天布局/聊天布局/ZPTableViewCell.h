//
//  ZPTableViewCell.h
//  聊天布局
//
//  Created by apple on 16/6/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZPMessage;

@interface ZPTableViewCell : UITableViewCell

@property (nonatomic, strong) ZPMessage *message;

@end
