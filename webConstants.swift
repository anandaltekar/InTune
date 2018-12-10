//
//  webConstants.swift
//  in-tune
//
//  Created by Anand Altekar on 28/07/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

public struct Const
{
//    static let serviceURL:String = "http://192.168.40.150/intune/Service.asmx"
//    static let serviceURL:String = "http://52.25.31.31/intune/service.asmx"
//    static let serviceURL:String = "http://52.25.31.31/intunedist/service.asmx"
    static let serviceURL:String = "http://52.25.31.31/intunedemo/service.asmx"
    static let OWN_MSG:Int = 0
    static let OTHER_MSG:Int = 1
    static let HOST_MSG:Int = 2
    static let USER_VERIFIED:Int = 1
    static let USER_UNVERIFIED:Int = 0
    static let CONCERT_ACTIVE:Int = 0
    static let CONCERT_NONACTIVE:Int = 1
    static let STR_JOINR:String = "$#$"
    static let HOST_USER:Int = 1
    static let GUEST_USER:Int = 0
    static let NOT_REQUESTED:Int = 0
    static let ALREADY_REQUESTED:Int = 1
    static let NOTIF_TYPE_NONE = 0
    static let NOTIF_MATCH_FOUND:Int = 1
    static let NOTIF_CHAT_MSG:Int = 2
    static let NOTIF_APP_UPDATE:Int = 3
    static let NOTIF_PLAY_NEXT_SONG:Int = 4
    static let NOTIF_USER_ACCEPTED:Int = 5
    static let NOTIF_ALREADY_MATCH:Int = 6
    static let READ:Int = 1
    static let UNREAD:Int = 0
    static let NOTIF_JOIN_LVL1:String = "#$#"
    static let NOTIF_JOIN_LVL2:String = "$#$"
    static let NOTIF_JOIN_LVL3:String = "#*#"
    static let FB_PIC_URL:String = "https://graph.facebook.com/"
    static let REQ_ACCEPT:String = "0"
    static let REQ_REJECT:String = "1"
    static let SONG_KILLED:Int = 1
    static let DBFIELD_MATCH_COUNT = "nMatchesFound"
    static let DBFIELD_REQST_COUNT = "nTotalReqFound"
    static let DBFIELD_KILLD_COUNT = "nKilledStatus"
    static let DBFIELD_CHECK_VALUE = "checkValue"
    static let DBFIELD_REQSTD_STAT = "nRequestedStatus"
    static let ACTIVE:Int = 1
    static let INACTIVE:Int = 0

}
