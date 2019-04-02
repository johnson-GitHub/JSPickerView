//
//  ViewController.m
//  JSPickerViewController
//
//  Created by 张尊强 on 2019/3/25.
//  Copyright © 2019 Johnson. All rights reserved.
//

#import "ViewController.h"
#import "JSPickerView.h"

@interface ViewController ()<JSPickerViewDelegate,JSPickerViewDataSource>

@property (nonatomic, strong) JSPickerView* pickerView;

@end

@implementation ViewController

- (JSPickerView*)pickerView
{
    if (!_pickerView) {
        _pickerView = [[JSPickerView alloc] init];
        _pickerView.title = @"选择";
        _pickerView.titleColor = [UIColor redColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showSeparatorLine = YES;
        _pickerView.separatorLineColor = [UIColor redColor];
    }
    return _pickerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showPicker:(UIButton *)sender {
    
    [self.pickerView show];
}

- (NSInteger)numberOfComponentsInPickerView:(JSPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(JSPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (NSString*)pickerView:(JSPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"第%ld行", row];
}

@end
