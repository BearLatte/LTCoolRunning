//
//  LTCRSportViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/30.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRSportViewController.h"
#import "BMapKit.h"
//#import "BMKAnnotationView.h"
//#import "BMKAnnotation.h"



/** 是TrailStart就在地图上画轨迹线，否则不画 */
typedef enum {
    TrailStart = 1,
    TrailEnd
}Trail;
#define BMKSPAN 0.002
@interface LTCRSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
@property (nonatomic, strong) BMKMapView *mapView;
///百度地图位置服务
@property (nonatomic, strong) BMKLocationService *bmkLocationService;
///用户标记是否画轨迹线
@property (nonatomic, assign, getter=isTrail) Trail trail;
/** 起点大头针 和 终点大头针*/
@property (nonatomic, strong) BMKPointAnnotation *startPoint;
@end

@implementation LTCRSportViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.mapView atIndex:0];
    [self initBMLocationService];
    [self setMapViewProperty];
    self.trail = TrailEnd;
    self.bmkLocationService.delegate = self;
    self.mapView.delegate = self;
    [self.bmkLocationService startUserLocationService];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
/** 初始化百度位置服务 */
- (void)initBMLocationService {
    self.bmkLocationService = [[BMKLocationService alloc] init];
    [BMKLocationService setLocationDistanceFilter:5];
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}
/** 设置百度的mapView的一些属性 */
- (void)setMapViewProperty {
    //显示定位图层
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = NO;
    self.mapView.showMapScaleBar = YES;
    //比例尺的位置
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    //定位图层 自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isAccuracyCircleShow = YES;
    displayParam.isRotateAngleValid = NO;
    displayParam.locationViewOffsetX = 0;
    displayParam.locationViewOffsetY = 0;
    [self.mapView updateLocationViewWithParam:displayParam];
}
//点击开始运动
- (IBAction)startSport:(id)sender {
    self.trail = TrailStart;
    self.startPoint = [self createPointWithLocation:self.bmkLocationService.userLocation.location title:@"起点"];
}
#pragma mark - BMKMapViewDelegate  And BMKLocationServiceDelegate
///用户位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    MYLog(@"用户当前位置:%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
#warning TUDO:真机测试的时候把定位方式设置成为前台模式
    [self.mapView updateLocationData:userLocation];
    //以用户目前位置为中心点 并设置一个显示的扇区范围
    if (self.trail == TrailEnd) {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN))];
        [self.mapView setRegion:adjustRegion];
    }
}

/** 显示大头针 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        //如果有起点 设置终点的图片，否则设置起点图片
        if (self.startPoint) {
            annotationView.image = [UIImage imageNamed:@"定位-终"];
        }else {
            annotationView.image = [UIImage imageNamed:@"定位-起"];
        }
        //从天而降的效果
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}
/** 添加大头针的方法 */
- (BMKPointAnnotation *)createPointWithLocation:(CLLocation *)location title:(NSString *)title {
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    //添加大头针到地图上
    [self.mapView addAnnotation:point];
    return point;
}








































@end