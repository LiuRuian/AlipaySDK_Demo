//
//  ViewController.m
//  AlipaySDK_Demo
//
//  Created by Ryan on 15/9/26.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "ViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088411090464081"

//收款支付宝账号
#define SellerID  @"pay@mfashion.com.cn"

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMJ583gj7KdxJ8D/fJRX4taYdRpFDjBw5csEzTyXkB8Ijw/8Urz3Hwzv1UT4GXwIq2H6r+2J7WTcXdMwjY2LZPosz9Ix8ie9dQpRQ3yX6/QTcTOO9e+SGkUTMfnjJrRqYkcnv54oK8mZ2LSkEnTJ3ShRSH/rPzq5PxeX2LOz9/IVAgMBAAECgYAbJiUsB2/ZLD3Nfp0opGBBbwUiBrPlZU1fGyt/ovT2sB4wsBvoz2LhTnXqa+w62Yb7ZaC7u36Njwn2GpgYQ3Z0DAaszdkO6UsXbgVT02m66+jbxd293LtfXmyESFdtpA8CSck/Xa6vtaIe3OvAqhzNdxVZWrhRvlBG6c+jlfsIIQJBAOgX0r1oJ4LwNQhMAuO0nhPCeR1SV9yTBuWX3mCXh6zRZhJeY/WEiSHlR9V1ErzAp7OVIaJGM/QiGRbqs6j4opkCQQDWgjHc21lWwHgFQk0qSADcrygqd+vrVF7ILF+Xm/Zxfq6G9+4I9bpm1MWP8pjtFnhkik7A6MjNSH+iaGD7ALTdAkAVLXdRSRux2vE73JO261gxPWGHx2e0/MV4Va846Rq8Li8+JdbBJGLO8PjpBVG8X2ft/wGeqQE8mY/og2n5VRahAkBlCykfxvd7ZOhkWcnti8NUMPHzp0+rJ7AKDNTunpnk9m6Rx0IKWG34uGtjljwxGi+V9IyKVF0aTfdJcm+UbM3FAkEAm/kKOMKSHa3gUvXH9FCq+oUFl1j0N8ICOHUzVf1EQG7fRbeaFrh934ioPLN68KqXQN8fmtw5b5uRffJierH0MQ=="

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 生产订单对象
    Order *order = [[Order alloc] init];
    
    order.partner = PartnerID;   //  合作身份者id，以2088开头的16位纯数字
    order.seller = SellerID;     //  支付宝收款账号,手机号码或邮箱格式。
    order.tradeNO = @"订单ID";            //  订单ID（由商家自行制定）
    order.productName = @"商品名称";       //  商品标题 / 商品名称
    order.productDescription = @"商品描述"; // 商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",1.68]; // 小数点后保留两位 @"%.2f"
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    order.service = @"mobile.securitypay.pay"; //接口名称
    order.paymentType = @"1";            //支付类型。默认为:1(商品购买)
    order.inputCharset = @"utf-8";       //参数编码字符集
    order.itBPay = @"30m";               // 超时时间
    order.showUrl = @"m.alipay.com"; //展示地址,即在支付宝页面时商品名称旁边的“详情”的链接地址
    
    //应用注册scheme,在 应用.plist 定义URL types, App回调时用到的标识
    NSString *appScheme = @"alipaySDKdemo";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
    }
    
    // 发送订单请求
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        NSLog(@"reslut = %@",resultDic);
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
