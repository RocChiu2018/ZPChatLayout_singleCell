//
//  ZPViewController.m
//  聊天布局
//
//  Created by apple on 16/6/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZPViewController.h"
#import "ZPMessage.h"
#import "ZPTableViewCell.h"

@interface ZPViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *messagesArray;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;  //聊天页面中底部的文本输入框
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;  //输入框View的底部和控制器View之间的距离约束

@end

@implementation ZPViewController

#pragma mark ————— 懒加载 —————
-(NSArray *)messagesArray
{
    if (_messagesArray == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        ZPMessage *lastMessage = nil;
        for (NSDictionary *dict in dictArray)
        {
            /**
             在不同类中封装对象：在此类中封装ZPMessage对象不同于以往，以往都是在ZPMessage类中一次性地把对象的所有属性都封装了，但是在此Demo中，在ZPMessage类中把对象的text，time和type属性进行了封装，在本类中把isHideTime属性进行了封装，在ZPTableViewCell类中把cellHeight属性进行了封装，这是因为ZPMessage类没有能力封装isHideTime和cellHeight属性，只能在其他类中封装这两个属性了。
             */
            ZPMessage *message = [ZPMessage messageWithDict:dict];
            
            /**
             封装ZPMessage对象isHideTime属性：的当前ZPMessage对象的消息发送时间和上一个ZPMessage对象的消息发送时间是否相同，如果相同则当前的ZPMessage对象的消息发送时间就隐藏掉，如果不相同则应该显示出来。
             */
            message.isHideTime = [message.time isEqualToString:lastMessage.time];
            
            [tempArray addObject:message];
            
            lastMessage = message;
        }
        
        _messagesArray = tempArray;
    }
    
    return _messagesArray;
}

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     因为UITextField控件的光标紧挨着控件的左侧边缘，所以要把光标往右侧移一些。
     */
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = [UIColor clearColor];
    leftView.frame = CGRectMake(0, 0, 10, 10);
    self.messageTextField.leftView = leftView;
    self.messageTextField.leftViewMode = UITextFieldViewModeAlways;
    
    /**
     监听键盘弹出的通知：本视图控制器应该监听键盘将要显示的通知(UIKeyboardWillShowNotification)，当键盘弹出的时候，系统会发布这个通知，届时就会调用本视图控制器的相应的方法来处理。
     */
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //监听键盘退下的通知：
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //如果不用上述的两个键盘通知的话，用下面的这个通知也可以代替上述的两个键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark ————— 键盘弹出 —————
- (void)keyboardWillShow:(NSNotification *)note
{
    /**
     从字典中获取到的值是一个对象类型的值(NSValue)，要想变成结构体类型(CGRect)就要调用CGRectValue方法来进行转换。
     */
    CGRect rect = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomSpacing.constant = rect.size.height;
    
    /**
     如果不写下面的动画代码的话，则键盘还没弹出到位而输入框已经先于键盘移动上来了，这样就显得不好看了，所以要加一个动画，使键盘和输入框一起移动到位；
     动画持续的时间和键盘弹出到位的时间应该是一致的。
     */
    double duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark ————— 键盘退下 —————
- (void)keyboardWillHide:(NSNotification *)note
{
    //键盘退下的时间
    double duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //修改约束
    self.bottomSpacing.constant = 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark ————— 键盘弹出和退下 —————
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    //取出键盘最终的frame
    CGRect rect = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //取出键盘弹出或退下所花费的时间
    double duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //修改约束
//    self.bottomSpacing.constant = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
//    [UIView animateWithDuration:duration animations:^{
//        [self.view layoutIfNeeded];
//    }];
    
    /**
     当键盘弹出或退下的时候使控制器的view上下移动有两种方法：
     1、改变约束值，如上代码所示；
     2、利用view的transform属性来进行移动，如下代码所示。
     */
    [UIView animateWithDuration:duration animations:^{
        CGFloat ty = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
        self.view.transform = CGAffineTransformMakeTranslation(0, - ty);  //view向上移动，y是负值
    }];
}

#pragma mark ————— UITableViewDataSource —————
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    
    ZPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.message = [self.messagesArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark ————— UITableViewDelegate —————
/**
 有此方法的话系统就会先调用此方法，然后调用cellForRowAtIndexPath方法，在cellForRowAtIndexPath方法中封装ZPMessage对象的cellHeight属性，然后系统会调用heightForRowAtIndexPath方法，在此方法中设置每行cell的高度。
 */
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZPMessage *message = [self.messagesArray objectAtIndex:indexPath.row];
    
    return message.cellHeight;
}

#pragma mark ————— UIScrollViewDelegate —————
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //退出键盘方法1：
    [self.view endEditing:YES];
    
    //退出键盘方法2：取消第一响应者
    [self.messageTextField resignFirstResponder];
    
    //退出键盘方法3：
    [self.messageTextField endEditing:YES];
}

/**
 在注册键盘通知的时候，通知中心会有一个指针指向本类(self)，在本类消失了以后如果通知中心接收到之前注册的通知的话，还会把指针指向已经消失了的本类，则程序就会崩溃，所以在本类被销毁之前要移除本类的所有通知；
 在本视图控制器被销毁之前会调用此方法。
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
