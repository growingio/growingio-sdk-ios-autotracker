//
//  GrowingAttributesConst.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 16/3/11.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>

#define GrowingAttrMacro(M)   \
    M(ReturnYES)                            /*默认的返回值      YES*/            \
    M(IgnorePage)                           /*圈选默认忽略page  BOOL*/           \
    M(IsOneRow)                             /*列表中一行        BOOL*/              \
    M(IsButton)                             /*是个按钮          BOOL*/                     \
    M(IsLabel)                              /*是个文本     */                      \
    M(IsImageView)                          /*是个图片*/                           \
    M(IsTabbarInTabbarController)           /*是个tabbar*/                       \
    M(FontSize)                             /*字体大小          NSNumber(float)*/          \
    M(IsHorizontalTable)                    /*横向表格          BOOL*/                     \
    M(IsWithinRowOfTable)                   /*横向表格          BOOL*/                     \
























#define GrowingAttrDefine(NAME) \
    extern NSString *GrowingAttribute ## NAME ## Key;

GrowingAttrMacro(GrowingAttrDefine)
