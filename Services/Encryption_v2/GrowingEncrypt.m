//
//  GrowingEncrypt.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/12/7.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Services/Encryption_v2/GrowingEncrypt.h"
#import "Services/Encryption_v2/GrowingAESEncryptor.h"
#import "Services/Encryption_v2/GrowingRSAEncryptor.h"

GrowingService(GrowingEncryptionService, GrowingEncrypt)

@implementation GrowingEncrypt

- (NSData *_Nonnull)encryptData:(NSData *_Nonnull)data {
    NSString *aesKey = @"1234567890123456";
    NSString *aesIv = @"0987654321654321";
    NSData *encodeData = [GrowingAESEncryptor encryptData:data key:aesKey iv:aesIv];
    
    NSString *pubKey = @"-----BEGIN PUBLIC KEY-----"
    @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs5g6gRnNwmjJeImf1x05"
    @"ufya6JTYnMXRhqegoGWJZrUsiK9pTZVYJAtQNAQgVXD38WGwg+K56Z9V0Xvoi9Na"
    @"+RyruWmwboBhY9XI67yQq50UfudLth0nk9a2k2sBLCApNlSe2bSmZPH1XjlNGrZU"
    @"Gce+qSTgDML+1GsQXPgUoaGxE1A7XehcnkXdjiqmVbUrRix5hO2l9l7p7NVJzrhh"
    @"7LjX1j4WTcIjzCLX3l4j7wfKiGLWYQKT59UrMNUId8uSx+4e4OiJBuWg6c6OML3i"
    @"BloFBsCR8gUDRoz6YwNtPrjUT7wyTJe0v9va+a/4IOdYVFE/Hnv4y1rr3T8ukUhn"
    @"ZwIDAQAB"
    @"-----END PUBLIC KEY-----";
    
    NSString *priKey = @"-----BEGIN PRIVATE KEY-----"
    @"MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzmDqBGc3CaMl4"
    @"iZ/XHTm5/JrolNicxdGGp6CgZYlmtSyIr2lNlVgkC1A0BCBVcPfxYbCD4rnpn1XR"
    @"e+iL01r5HKu5abBugGFj1cjrvJCrnRR+50u2HSeT1raTawEsICk2VJ7ZtKZk8fVe"
    @"OU0atlQZx76pJOAMwv7UaxBc+BShobETUDtd6FyeRd2OKqZVtStGLHmE7aX2Xuns"
    @"1UnOuGHsuNfWPhZNwiPMItfeXiPvB8qIYtZhApPn1Ssw1Qh3y5LH7h7g6IkG5aDp"
    @"zo4wveIGWgUGwJHyBQNGjPpjA20+uNRPvDJMl7S/29r5r/gg51hUUT8ee/jLWuvd"
    @"Py6RSGdnAgMBAAECggEAROaXM2Zp6Tb4bHUoTIga2H7QE4DfZa4DB40R89dgknXZ"
    @"gwsA9FHigdmRSJN4sC7qAMJAzShTuQx3CSpnehV5Jm9YdobUuGAqfPnM3pv2SNC3"
    @"x0QHaPPgdjh+zSnVRk+EYCKw2scSu1GUmDSVnzTqKQXX4N6T0nGRAH+exHwstiFE"
    @"wzHesRdyk5/p8JbcsyceDSoG2eTDq4Bu6kefd4omm0Jv6kNYWG59iqJNcI8WaGn9"
    @"1/ImTArh2QJaGFfi4PFK7bbvdsq+ih/cDRxenTMF3d6nQ3Tndw1GsTB8ac3UC3gF"
    @"ijKT6gpMUizCABR+slv2W4kXkXu9HwbGgMokTGkEcQKBgQDeSy8BdZlRHYYYoi2J"
    @"iEU5qcYzDdwI2e8VeImxwsgUzvOEQjhl0GQzUENiBrIrJ4GpsCe4orPC2Sk+pn2y"
    @"oIxZ2OiubEiIiWDLgPNpv+TSPwlHldF0kfNheIi1f3os0IrFqHS31hqeWW8DXuxP"
    @"0Yc4eQO2GuB1UToWlkDQWTTpXwKBgQDO05aICuzizkICMMdZkSxdiOP1cIFnWUL5"
    @"marD8uAE5JRUf2QuHVL2tr7TuD7YEgpI8OldRo7xRgSBFc+kBz32D08aPTvupJze"
    @"+HcpBukOd1pMoEmm2Y9uKHrUXgKUPl2dvEhxyrhcrhLK/bIGYX4H+bDbcy+uveOQ"
    @"ZvKWO8TW+QJ/dhd64UuYJ3+HvY5qoqXCIOAQaw7x1cHxQXbHr6fKo0NOGvUTAQO0"
    @"N45sPadQ/5v9RihO8cd9uAWl46KPJFYmOZUCB6d+4QoaYgIfTg6jgQ374Au3OjZP"
    @"FXjzJ3iRbz1ae6cCWqdjfLwGPcQvxjeJnnarghLFK437TgSEair58QKBgQC0Y8c/"
    @"EIhbqRnZX0H/1KalTefFAkNbKHdJy8Us8oCAw/y7VgDCV8EsfWcisefd/J4L0FM5"
    @"j3jM5wy2qZdYsRhRrDiJ4i6LjfdkYcFMf0J145NWkdarN8XphlTbNMN7GIn+MWHe"
    @"Hbl+3DR3552GAzIxMo4WWPiVp/j60U9zyN19wQKBgQCjyOQxy/qDEz2Lj+OrQ8dF"
    @"5/ALGWb04OC+utxDPuSBQ5XQ0qbsxzTdkHYJLTLbASvNCY1ntTf8PSej8mQhqsBs"
    @"0zbn/z1VGkjZJEay/sjBmt17BkU3oNFMbYGlC3xgQh5MGgjzJSta6m7g3tIs3E23"
    @"RIxo6xTCSGF1yPImQWpweQ=="
    @"-----END PRIVATE KEY-----";
    
    /*
    -----BEGIN PRIVATE KEY-----
    MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzmDqBGc3CaMl4
    iZ/XHTm5/JrolNicxdGGp6CgZYlmtSyIr2lNlVgkC1A0BCBVcPfxYbCD4rnpn1XR
    e+iL01r5HKu5abBugGFj1cjrvJCrnRR+50u2HSeT1raTawEsICk2VJ7ZtKZk8fVe
    OU0atlQZx76pJOAMwv7UaxBc+BShobETUDtd6FyeRd2OKqZVtStGLHmE7aX2Xuns
    1UnOuGHsuNfWPhZNwiPMItfeXiPvB8qIYtZhApPn1Ssw1Qh3y5LH7h7g6IkG5aDp
    zo4wveIGWgUGwJHyBQNGjPpjA20+uNRPvDJMl7S/29r5r/gg51hUUT8ee/jLWuvd
    Py6RSGdnAgMBAAECggEAROaXM2Zp6Tb4bHUoTIga2H7QE4DfZa4DB40R89dgknXZ
    gwsA9FHigdmRSJN4sC7qAMJAzShTuQx3CSpnehV5Jm9YdobUuGAqfPnM3pv2SNC3
    x0QHaPPgdjh+zSnVRk+EYCKw2scSu1GUmDSVnzTqKQXX4N6T0nGRAH+exHwstiFE
    wzHesRdyk5/p8JbcsyceDSoG2eTDq4Bu6kefd4omm0Jv6kNYWG59iqJNcI8WaGn9
    1/ImTArh2QJaGFfi4PFK7bbvdsq+ih/cDRxenTMF3d6nQ3Tndw1GsTB8ac3UC3gF
    ijKT6gpMUizCABR+slv2W4kXkXu9HwbGgMokTGkEcQKBgQDeSy8BdZlRHYYYoi2J
    iEU5qcYzDdwI2e8VeImxwsgUzvOEQjhl0GQzUENiBrIrJ4GpsCe4orPC2Sk+pn2y
    oIxZ2OiubEiIiWDLgPNpv+TSPwlHldF0kfNheIi1f3os0IrFqHS31hqeWW8DXuxP
    0Yc4eQO2GuB1UToWlkDQWTTpXwKBgQDO05aICuzizkICMMdZkSxdiOP1cIFnWUL5
    marD8uAE5JRUf2QuHVL2tr7TuD7YEgpI8OldRo7xRgSBFc+kBz32D08aPTvupJze
    +HcpBukOd1pMoEmm2Y9uKHrUXgKUPl2dvEhxyrhcrhLK/bIGYX4H+bDbcy+uveOQ
    ZvKWO8TW+QJ/dhd64UuYJ3+HvY5qoqXCIOAQaw7x1cHxQXbHr6fKo0NOGvUTAQO0
    N45sPadQ/5v9RihO8cd9uAWl46KPJFYmOZUCB6d+4QoaYgIfTg6jgQ374Au3OjZP
    FXjzJ3iRbz1ae6cCWqdjfLwGPcQvxjeJnnarghLFK437TgSEair58QKBgQC0Y8c/
    EIhbqRnZX0H/1KalTefFAkNbKHdJy8Us8oCAw/y7VgDCV8EsfWcisefd/J4L0FM5
    j3jM5wy2qZdYsRhRrDiJ4i6LjfdkYcFMf0J145NWkdarN8XphlTbNMN7GIn+MWHe
    Hbl+3DR3552GAzIxMo4WWPiVp/j60U9zyN19wQKBgQCjyOQxy/qDEz2Lj+OrQ8dF
    5/ALGWb04OC+utxDPuSBQ5XQ0qbsxzTdkHYJLTLbASvNCY1ntTf8PSej8mQhqsBs
    0zbn/z1VGkjZJEay/sjBmt17BkU3oNFMbYGlC3xgQh5MGgjzJSta6m7g3tIs3E23
    RIxo6xTCSGF1yPImQWpweQ==
    -----END PRIVATE KEY-----
     */
    
    NSString *encodeAESKey = [GrowingRSAEncryptor encryptString:aesKey publicKey:pubKey];
    
    return encodeData;
}

@end
