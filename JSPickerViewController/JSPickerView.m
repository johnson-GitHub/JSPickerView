//
//  JSPickerView.m
//  JSPickerViewController
//
//  Created by 张尊强 on 2019/3/26.
//  Copyright © 2019 Johnson. All rights reserved.
//

#import "JSPickerView.h"
#import <Masonry.h>

/** 设备是否为刘海屏幕 */
#define iPhone_X_x (([UIApplication sharedApplication].statusBarFrame.size.height) == 20 ? NO:YES)

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define kTabBarSecurityH (iPhone_X_x?34.f:0.f)
#define kPickerHeight 216.f
#define kToolBarHeight 44.f
#define kButtonWidth 50.f
#define kPadding 15.f
#define kAnimateTime .2f

#define COLOR_FROM_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface JSPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic) CGSize viewSize;

@property (nonatomic, strong) UIView* maskView;// 遮罩层
@property (nonatomic, strong) UIView* bgView;// 背景层
@property (nonatomic, strong) UIView* toolBar;// 工具栏
@property (nonatomic, strong) UIPickerView* pickerView;// 选择控件
@property (nonatomic, strong) UILabel* titleLabel;// 标题
@property (nonatomic, strong) UIButton* cancelButton;// 取消按钮
@property (nonatomic, strong) UIButton* confirmButton;// 确认按钮
@property (nonatomic, strong) UIView* lineView;// 分割线

@end

@implementation JSPickerView

- (instancetype)initWithViewSize:(CGSize)viewSize
{
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]) {
        if (viewSize.width != 0 && viewSize.height != 0) {
            self.viewSize = viewSize;
        }else{
            self.viewSize = CGSizeMake(kScreenWidth, kPickerHeight+kToolBarHeight);
        }
        [self configSubviews];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]) {
        self.viewSize = CGSizeMake(kScreenWidth, kPickerHeight+kToolBarHeight);
        [self configSubviews];
    }
    return self;
}

- (void)configSubviews
{
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.f;
    
    UIView* tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.viewSize.height)];
    [self addSubview:tapView];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [tapView addGestureRecognizer:tapGestureRecognizer];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, self.viewSize.height+kTabBarSecurityH);
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kToolBarHeight)];
    [self.bgView addSubview:self.toolBar];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"请选择";
    self.titleLabel.textColor = COLOR_FROM_RGB(0x333333);
    self.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [self.toolBar addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.toolBar);
        make.top.equalTo(self.toolBar);
        make.height.equalTo(self.toolBar);
    }];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:COLOR_FROM_RGB(0x666666) forState:UIControlStateNormal];
    [self.toolBar addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolBar);
        make.left.equalTo(self.toolBar).offset(15);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:COLOR_FROM_RGB(0x666666) forState:UIControlStateNormal];
    [self.toolBar addSubview:self.confirmButton];
    [self.confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolBar);
        make.right.equalTo(self.toolBar).offset(-15);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = COLOR_FROM_RGB(0xdddddd);
    [self.toolBar addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView);
        make.right.equalTo(self.bgView);
        make.height.mas_equalTo(.5f);
        make.top.mas_equalTo(kToolBarHeight);
    }];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.bgView addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView);
        make.right.equalTo(self.bgView);
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView.mas_top).offset(kToolBarHeight+((self.viewSize.height-kToolBarHeight)/2.f));
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.toolBar);
        make.top.equalTo(self.toolBar);
        make.height.equalTo(self.toolBar);
    }];
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolBar);
        make.left.equalTo(self.toolBar).offset(15);
        make.centerY.equalTo(self.titleLabel);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolBar);
        make.right.equalTo(self.toolBar).offset(-15);
        make.centerY.equalTo(self.titleLabel);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView);
        make.right.equalTo(self.bgView);
        make.height.mas_equalTo(.5f);
        make.top.mas_equalTo(kToolBarHeight);
    }];
    [self.pickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView);
        make.right.equalTo(self.bgView);
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView.mas_top).offset(kToolBarHeight+((self.viewSize.height-kToolBarHeight)/2.f));
    }];
}

- (void)show
{
    [[UIApplication sharedApplication].delegate.window addSubview:self.maskView];
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    [UIView animateWithDuration:.2f animations:^{
        self.maskView.alpha = 0.5;
        self.bgView.frame = CGRectMake(0, kScreenHeight-self.viewSize.height-kTabBarSecurityH, kScreenWidth, self.viewSize.height+kTabBarSecurityH);
    }];
}

- (void)hide
{
    [UIView animateWithDuration:.2f animations:^{
        self.maskView.alpha = 0.0;
        self.bgView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, self.viewSize.height+kTabBarSecurityH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
    }];
}

#pragma mark - ================ button action ===============
- (void)cancelAction:(UIButton*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonActionWithPickerView:)]) {
        [self.delegate cancelButtonActionWithPickerView:self];
    }
    [self hide];
}

- (void)confirmAction:(UIButton*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmButtonActionWithPickerView:)]) {
        [self.delegate confirmButtonActionWithPickerView:self];
    }
    [self hide];
}

#pragma mark - ================ setter and getter ===============

- (NSInteger)numberOfComponents
{
    return self.pickerView.numberOfComponents;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerView numberOfRowsInComponent:component];
}

- (CGSize)rowSizeForComponent:(NSInteger)component
{
    return [self.pickerView rowSizeForComponent:component];
}

- (UIView*)viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerView viewForRow:row forComponent:component];
}

- (void)reloadAllComponents
{
    [self.pickerView reloadAllComponents];
}

- (void)reloadComponent:(NSInteger)component
{
    [self.pickerView reloadComponent:component];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    [self.pickerView selectRow:row inComponent:component animated:animated];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return [self.pickerView selectedRowInComponent:component];
}

- (void)setPickerBackgroundColor:(UIColor *)pickerBackgroundColor
{
    _pickerBackgroundColor = pickerBackgroundColor;
    self.bgView.backgroundColor = pickerBackgroundColor;
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor
{
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.toolBar.backgroundColor = toolBarBackgroundColor;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor
{
    _cancelButtonColor = cancelButtonColor;
    [self.cancelButton setTitleColor:cancelButtonColor forState:UIControlStateNormal];
}

- (void)setConfirmButtonColor:(UIColor *)confirmButtonColor
{
    _confirmButtonColor = confirmButtonColor;
    [self.confirmButton setTitleColor:confirmButtonColor forState:UIControlStateNormal];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
    [self layoutIfNeeded];
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont
{
    _cancelButtonFont = cancelButtonFont;
    self.cancelButton.titleLabel.font = cancelButtonFont;
}

- (void)setConfirmButtonFont:(UIFont *)confirmButtonFont
{
    _confirmButtonFont = confirmButtonFont;
    self.confirmButton.titleLabel.font = confirmButtonFont;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
{
    _cancelButtonTitle = cancelButtonTitle;
    [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

- (void)setConfirmButtonTitle:(NSString *)confirmButtonTitle
{
    _confirmButtonTitle = confirmButtonTitle;
    [self.confirmButton setTitle:confirmButtonTitle forState:UIControlStateNormal];
}

- (void)setShowLineView:(BOOL)showLineView
{
    _showLineView = showLineView;
    self.lineView.hidden = !showLineView;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    self.lineView.backgroundColor = lineColor;
}

- (void)setShowSeparatorLine:(BOOL)showSeparatorLine
{
    _showSeparatorLine = showSeparatorLine;
    [self.pickerView reloadAllComponents];
}

- (void)setSeparatorLineColor:(UIColor *)separatorLineColor
{
    _separatorLineColor = separatorLineColor;
    [self.pickerView reloadAllComponents];
}

#pragma mark - ================ UIPickerView delegate and dataSource ===============

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.dataSource numberOfComponentsInPickerView:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dataSource pickerView:self numberOfRowsInComponent:component];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.showSeparatorLine) {
        ((UILabel *)[pickerView.subviews objectAtIndex:1]).backgroundColor = self.separatorLineColor?:COLOR_FROM_RGB(0xdddddd);//显示分隔线
        ((UILabel *)[pickerView.subviews objectAtIndex:2]).backgroundColor = self.separatorLineColor?:COLOR_FROM_RGB(0xdddddd);//显示分隔线
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        return [self.delegate pickerView:self titleForRow:row forComponent:component];
    }
    return @"123";
}

- (NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
        return [self.delegate pickerView:self attributedTitleForRow:row forComponent:component];
    }
    return [[NSAttributedString alloc] initWithString:@"123"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
