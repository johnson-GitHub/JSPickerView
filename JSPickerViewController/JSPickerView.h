//
//  JSPickerView.h
//  JSPickerViewController
//
//  Created by 张尊强 on 2019/3/26.
//  Copyright © 2019 Johnson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSPickerViewDelegate, JSPickerViewDataSource;

@interface JSPickerView : UIView

/**
 *  构建方法，viewSize为控件的内容部分的宽高，如不传或使用- (instancetype)init方法，则为默认为 屏幕宽*260，在有刘海屏的设备上将为 屏幕宽*260+屏幕底部安全区域的高，
 */
- (instancetype)initWithViewSize:(CGSize)viewSize;
- (instancetype)init;

@property (nonatomic, weak) id<JSPickerViewDelegate> delegate;
@property (nonatomic, weak) id<JSPickerViewDataSource> dataSource;

/**
 *  显示控件（未创建控件时无效）
 */
- (void)show;
/**
 *  隐藏控件（未创建控件时无效）
 */
- (void)hide;

// 从代理和数据源中获取并缓存的数据
/**
 列数
 */
@property(nonatomic,readonly) NSInteger numberOfComponents;

/**
 某一列的行数

 @param component 列号
 @return component列的行数
 */
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

/**
 某一列的所有行的宽高

 @param component 列数
 @return component列的行的宽高
 */
- (CGSize)rowSizeForComponent:(NSInteger)component;

/**
 通过委托方法（pickerView:viewForRow:forComponent:reusingView:）获取到的某一个单元格的控件

 @param row 行
 @param component 列
 @return 控件view
 */
- (nullable UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;

// 刷新
/**
 刷新所有列的数据
 */
- (void)reloadAllComponents;
/**
 刷新一列的数据

 @param component 列
 */
- (void)reloadComponent:(NSInteger)component;

/**
 选中某一行，在本控件中，则是将某一行滚动到视图中央

 @param row 行
 @param component 列
 @param animated 是否有动画效果
 */
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

/**
 查找当前选中的行的坐标

 @param component 列
 @return 返回当前component列被选中的行的行数
 */
- (NSInteger)selectedRowInComponent:(NSInteger)component;

/**
 *  选择区域的背景颜色,默认为白色
 */
@property (nonatomic, strong) UIColor* pickerBackgroundColor;
/**
 *  标题区域的背景颜色,默认跟选择区域的背景颜色相同
 */
@property (nonatomic, strong) UIColor* toolBarBackgroundColor;
/**
 *  标题文字颜色，默认为 #333333
 */
@property (nonatomic, strong) UIColor* titleColor;
/**
 *  取消按钮文字颜色，默认为 #666666
 */
@property (nonatomic, strong) UIColor* cancelButtonColor;
/**
 *  确认按钮文字颜色，默认为 #666666
 */
@property (nonatomic, strong) UIColor* confirmButtonColor;
/**
 *  标题的字号，默认为 17号字
 */
@property (nonatomic, strong) UIFont* titleFont;
/**
 *  取消按钮的字号，默认为 17号字
 */
@property (nonatomic, strong) UIFont* cancelButtonFont;
/**
 *  确认按钮的字号，默认为 17号字
 */
@property (nonatomic, strong) UIFont* confirmButtonFont;
/**
 *  标题的文字，默认为 @"请选择"
 */
@property (nonatomic, copy) NSString* title;
/**
 *  取消按钮的文字，默认为 @"取消"
 */
@property (nonatomic, copy) NSString* cancelButtonTitle;
/**
 *  确认按钮的文字，默认为 @"确定"
 */
@property (nonatomic, copy) NSString* confirmButtonTitle;

/**
 是否显示分割线，默认为YES；
 */
@property (nonatomic, assign, getter=isShowLineView) BOOL showLineView;
/**
 分割线颜色 默认为#dddddd
 */
@property (nonatomic, strong) UIColor* lineColor;

/**
 *  是否显示选择控件上的分割线 默认为NO
 */
@property (nonatomic, assign, getter=isShowSeparatorLine) BOOL showSeparatorLine;
/**
 *  选择控件上分割线的颜色，默认为 #dddddd
 */
@property (nonatomic, strong) UIColor* separatorLineColor;

@end

@protocol JSPickerViewDelegate <NSObject>

@optional;

/**
 确认按钮的点击事件，可不实现（点击确认按钮时控件将自动移除）
 
 @param pickerView 选择控件view
 */
- (void)confirmButtonActionWithPickerView:(JSPickerView*)pickerView;


/**
 取消按钮的点击事件，可不实现（点击确认按钮时控件将自动移除）
 
 @param pickerView 选择控件view
 */
- (void)cancelButtonActionWithPickerView:(JSPickerView*)pickerView;

// 这些方法返回一个普通的NSString、一个NSAttributedString。
// 如果你返回一个不同的对象，旧的对象将被释放。
/**
 每一行显示的文字(默认为@"")
 
 @param pickerView 选择控件view
 @param row 行
 @param component 列
 @return 显示的文字
 */
- (nullable NSString *)pickerView:(JSPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
/**
 每一行显示的文字（富文本模式）(默认为@"")
 
 @param pickerView 选择控件view
 @param row 行
 @param component 列
 @return 显示的富文本
 */
- (nullable NSAttributedString *)pickerView:(JSPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED;

/**
 选择事件代理，当选择控件滑动到某一行并且停住的时候将调用此方法

 @param pickerView 选择控件view
 @param row 行
 @param component 列
 */
- (void)pickerView:(JSPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;

@end

@protocol JSPickerViewDataSource <NSObject>
@required
/**
 *  显示几列，必须实现
 */
- (NSInteger)numberOfComponentsInPickerView:(JSPickerView *)pickerView;

/**
 *  每一列显示几行，必须实现
 */
- (NSInteger)pickerView:(JSPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

NS_ASSUME_NONNULL_END
