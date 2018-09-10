//
//  ZPTableViewCell.m
//  聊天布局
//
//  Created by apple on 16/6/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZPTableViewCell.h"
#import "ZPMessage.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface ZPTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;  //发送消息的时间框
@property (weak, nonatomic) IBOutlet UIButton *contentButton;  //本方发出的消息（因为当用户点击此处消息框时，消息框背景会变色，所以选择用UIButton控件来做消息框）
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;  //本方的头像
@property (weak, nonatomic) IBOutlet UIButton *otherContentButton;  //对方发来的消息
@property (weak, nonatomic) IBOutlet UIImageView *otherIconImageView;  //对方的头像

@end

@implementation ZPTableViewCell
/**
 用storyboard文件创建这个自定义cell的时候，系统会先调用initWithCoder方法，然后进行IBOutlet属性的连线，最后才会调用awakeFromNib方法了。
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code

    /**
     UIButton控件内部有左右两个部分，左边是imageView，右边是titleLabel，当不设置imageView的时候，右边的titleLabel会占据整个UIButton控件，所以届时里面的内容文字会占据整个UIButton控件。在设置会话内容按钮背景图片的时候，先在Assets.xcassets中点击要进行拉伸的图片，然后再点击右侧栏中的slicing，选择里面的Horizontal and Vertical（竖直和水平方向进行拉伸），然后系统就会自动算出需要保护的尺寸，然后对这个图片进行拉伸，这样会话内容按钮的背景图片就设置好了。运行程序以后会看到背景图片不能完全覆盖文字内容的现象，这是因为titleLabel已经占据了整个UIButton控件，而且背景图片本身四周就有一块透明的区域，所以才会造成上述的现象，要想解决这个问题，就要设置UIButton控件的内边距；
     在xib文件中设置UILabel控件的时候要设置它的x,y值，而且为了当使它的内容文字多的时候会自动换行就要设置它的numberOfLines属性为0，同时也要保证当它的内容文字少（肯定是单行）的时候文字内容也能够充满整个UILabel控件，所以它的宽度不能设置成一个固定的值，而要设置一个宽度的最大值，即UILabel控件的宽度要小于等于这个值，除此之外不用再设置它的高度值了，当它的内容文字多的时候Autolayout会根据内容文字的多少来动态调整UILabel控件的高度。UILabel和UIButton有相似之处，如上所述，在xib文件中设置UIButton控件的时候也要设置它的x,y值，为了当使它的内容文字多的时候会自动换行就要设置它的titleLabel属性的numberOfLines属性为0，而且也要设置一个宽度的最大值，即UIButton控件的宽度要小于等于这个值，除此之外不用再设置它的高度值了，系统会根据它的内容文字的多少来动态调整UIButton控件的高度。
     */
    self.contentButton.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    self.otherContentButton.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    self.contentButton.titleLabel.numberOfLines = 0;
    self.otherContentButton.titleLabel.numberOfLines = 0;
}

- (void)setMessage:(ZPMessage *)message
{
    _message = message;
    
    if (message.type == messageTypeMe)  //本方，在聊天页面的右边
    {
        [self settingShowContentButton:self.contentButton showIconImageView:self.iconImageView hideContentButton:self.otherContentButton hideIconImageView:self.otherIconImageView];
    }else  //对方，在聊天页面的左边
    {
        [self settingShowContentButton:self.otherContentButton showIconImageView:self.otherIconImageView hideContentButton:self.contentButton hideIconImageView:self.iconImageView];
    }
}

- (void)settingShowContentButton:(UIButton *)showContentButton showIconImageView:(UIImageView *)showIconImageView hideContentButton:(UIButton *)hideContentButton hideIconImageView:(UIImageView *)hideIconImageView
{
    showContentButton.hidden = NO;
    showIconImageView.hidden = NO;
    hideContentButton.hidden = YES;
    hideIconImageView.hidden = YES;
    
    /**
     当时间框显示的时候已经在storyboard文件中约束了头像和时间框的距离，当时间框隐藏的时候只是它里面的文字不显示了而已，但时间框原来所占据的位置是依然存在的，当运行程序以后看起来消息内容框和cell顶部的距离过大，所以当时间框隐藏的时候也要约束消息内容框和cell顶部的距离。想要实现上述的目的有如下的两种方法：
     （1）如下面的代码所示，利用Masonry第三方，当时间框隐藏和显示的时候利用updateConstraints方法分别设置时间框的高度；
     （2）利用Autolayout的约束优先级在storyboard文件中先设置头像和时间框的距离为8，并且设置这个约束的优先级为1000，然后再设置头像和cell顶部的距离也为8，默认的优先级也为1000，设置完了以后，上述的两个约束是冲突的，要把头像和cell顶部距离的那个约束的优先级改为低于1000的，这个时候这个约束就由实线变为了虚线。视频中所讲的是当时间框显示的时候高优先级的约束管用，能够保证头像和时间框的距离为8，当时间框隐藏以后高优先级的那个约束就不存在了，低优先级的约束管用，从而能够保证头像和cell顶部的距离为8。但是从实际的操作情况来看这样并不能解决问题，上述两个约束的优先级相互调换的话也不能够解决问题，原因是不管时间框是否隐藏，上述的那两个约束都不会消失，并且优先执行优先级高的约束。
     上述两种方式中的第二种约束优先级的方式被证明在本Demo中不起作用，所以在此Demo中还是采用第一种方式。
     */
    if (self.message.isHideTime)  //隐藏时间框
    {
        self.timeLabel.hidden = YES;

        //隐藏时间框的时候把时间框的高度设为0
        [self.timeLabel updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(0);
        }];
    }else  //显示时间框
    {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = self.message.time;

        //显示时间框的时候把时间框的高度设为21
        [self.timeLabel updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(21);
        }];
    }
    
    //设置消息内容文字
    [showContentButton setTitle:self.message.text forState:UIControlStateNormal];
    
    /**
     此时调用layoutIfNeeded（强制更新）方法的原因是：上面代码的意思只是为UIButton控件设置了它的内容文字，实际上这些内容文字是设置在UIButton控件里面的子控件titleLabel里面的。换言之，只是在titleLabel里面设置了内容文字，如果想要计算出此时titleLabel的高度的话就需要强制更新该UIButton控件才可以；
     如果只是用showContentButton来调用layoutIfNeeded方法的话则只是showContentButton会被强制更新，而ZPTableViewCell内的其他控件则不会被强制更新，如果那样的话就会造成一些意想不到的问题，比如聊天页面中的cell和cell之间的距离会不固定等等。
     */
    [self layoutIfNeeded];
    
    /**
     当UIButton控件的内容文字多的时候，并且在xib文件中设置了此控件的x,y值，而且限制了此控件的宽度（最大宽度和最小宽度），在允许文字换行的情况下，它里面的titleLabel属性会根据文字的多少做高度的调整，但是UIButton控件的高度不能随着titleLabel属性的高度变化而变化，所以要单独设置UIButton控件的高度等于titleLabel属性的高度，以下代码的作用就是如此；
     不能调用addConstraint方法来添加约束，因为如果那样的话在程序运行的过程中setMessage方法会被反复地调用，每调用一次setMessage方法就会给该控件添加一次约束，所以这样做是不恰当的，应该要调用updateConstraints方法，这个方法的特点是先检查该控件有没有被添加这个约束，如果没有被添加这个约束的话就会先给该控件添加这个约束，如果已经添加了这个约束的话就会更新这个约束；
     要想让按钮的高度和它里面的titleLabel控件的高度一样的话需要在xib文件中把按钮的Type由System改成Custom才可以；
     UIButton控件的高度等于它里面的titleLabel子控件的高度再加上30，这个30就是UIButton控件的上下内边距之和（上下内边距各15）。
     */
    [showContentButton updateConstraints:^(MASConstraintMaker *make) {
        CGFloat buttonHeight = showContentButton.titleLabel.frame.size.height + 30;
        
        make.height.equalTo(buttonHeight);
    }];
    
    /**
     此时调用layoutIfNeeded（强制更新）方法的原因是：上面的代码只是把按钮的高度设置成它里面的titleLabel控件的高度，但是在界面上并没有显示出来，必须要调用强制更新方法才能让按钮的高度和它里面的titleLabel控件的高度在界面上显示成一样的；
     */
    [self layoutIfNeeded];
    
    /**
     计算当前cell的高度(cell的高度不是UIButton控件的最大Y值就是头像的最大Y值)；
     在这个类中封装ZPMessage对象的cellHeight属性；
     上面的代码中如果用showContentButton调用layoutIfNeeded方法的话则会造成聊天页面的最后一条聊天内容和输入框之间产生过大的距离，原因就是只强制更新了showContentButton控件，而没有强制更新ZPTableViewCell中的其他控件。在取得一个控件的frame之前要让这个控件强制更新一下，所以上面的代码中要用self调用layoutIfNeeded方法，这样的话ZPTableViewCell里面的所有控件就都更新了。
     */
    CGFloat buttonMaxY = CGRectGetMaxY(self.otherContentButton.frame);
    CGFloat iconImageViewY = CGRectGetMaxY(self.otherIconImageView.frame);
    self.message.cellHeight = MAX(buttonMaxY, iconImageViewY) + 10;
}

@end
