//
//  ViewController.m
//  GPSDemo
//
//  Created by ShuKe on 2019/9/12.
//  Copyright © 2019 Da魔王_舒克. All rights reserved.
//

#import "ViewController.h"
#import "CoreLocation/CoreLocation.h" // GPS

#define ScreenWidth [UIScreen mainScreen].bounds.size.width // 屏幕宽度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height // 屏幕高度

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) UIButton *gpsBtn;
@property (nonatomic, strong) CLLocationManager *gpsManager; // GPS
@property (nonatomic, assign) BOOL isLocationed; // GPS

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self customDataSource];
    [self createUI];
}


- (void)customDataSource
{
    
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.gpsBtn];
}


#pragma mark - Click
- (void)getGPSClick
{
    _isLocationed = NO;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if ([self.gpsManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.gpsManager requestWhenInUseAuthorization];
        }
        [self.gpsManager startUpdatingLocation];
    }else {
        NSLog(@"定位服务未开启....");
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"定位服务已关闭" message:@"您需要打开定位权限，才可以登录。请到设置->隐私->定位服务中开启【沃受理】定位服务。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *yesAct = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIDevice currentDevice].systemVersion floatValue] < 10) {
                [[UIApplication sharedApplication] openURL:url];
            }else {
                [[UIApplication sharedApplication] openURL:url
                                                   options:[NSDictionary dictionary]
                                         completionHandler:nil];
            }
        }];
        [alertCon addAction:noAct];
        [alertCon addAction:yesAct];
        [self presentViewController:alertCon animated:alertCon completion:nil];
    }
}



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (!_isLocationed) {
        CLLocation * location1 = [locations lastObject];
        CLLocationCoordinate2D coordinate = location1.coordinate;
        
        NSString *j = [NSString stringWithFormat:@"%f", coordinate.longitude]; // 经度
        NSString *w = [NSString stringWithFormat:@"%f", coordinate.latitude]; // 纬度
        NSLog(@"\n\n ==== 经度：%@ \n ==== 纬度：%@ \n", j, w);
        
        CLGeocoder * geocoder = [[CLGeocoder alloc]init];
        CLLocation * location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (placemarks.count > 0) {
                CLPlacemark * placemark = [placemarks objectAtIndex:0];
                NSString * city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                NSLog(@"city = %@", city);
            }else if (error == nil && placemarks.count == 0){
                NSLog(@"No results were returned.");
            }else if (error != nil){
                NSLog(@"An error occurred = %@", error);
            }
        }];
        self.isLocationed = YES;
    }
    [self.gpsManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (error.code == kCLErrorDenied) {
        NSLog(@"Error : %@",error);
    }
}


#pragma mark - Getter And Setter
- (UIButton *)gpsBtn
{
    if (_gpsBtn) return _gpsBtn;
    _gpsBtn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth-200)/2.0, 200, 200, 100)];
    [_gpsBtn setTitle:@"获取GPS" forState:UIControlStateNormal];
    _gpsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _gpsBtn.backgroundColor = [UIColor redColor];
    [_gpsBtn addTarget:self action:@selector(getGPSClick) forControlEvents:UIControlEventTouchUpInside];
    return _gpsBtn;
}

- (CLLocationManager *)gpsManager {
    if (_gpsManager) return _gpsManager;
    _gpsManager = [[CLLocationManager alloc]init];
    _gpsManager.delegate = self;
    _gpsManager.desiredAccuracy = kCLLocationAccuracyBest;
    return _gpsManager;
}


@end
