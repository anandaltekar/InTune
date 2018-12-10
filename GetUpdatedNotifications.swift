
import Foundation

class GetUpdatedNotifications: NSObject, NSXMLParserDelegate, _IFaceAPI{
    var methodName: String = "GetUpdatedNotifications"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var notifications:[structNotification] = Array<structNotification>()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetUpdatedNotifications xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession></GetUpdatedNotifications></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_NotificationDetails"]
            for var index:Int = 0; index < dictData.children.count; ++index {
                let item : AEXMLElement = dictData.children[index]
                let notifType:Int = Int(item["eventType"].value!)!
                if notifType == Const.NOTIF_MATCH_FOUND || notifType == Const.NOTIF_CHAT_MSG || notifType == Const.NOTIF_USER_ACCEPTED || notifType == Const.NOTIF_ALREADY_MATCH
                {
                    var notif:structNotification = structNotification()
                    notif.id = Utility.suidToInt(item["suidNotification"].value!)
                    notif.idUser = Utility.suidToInt(item["suidOrganiser"].value!)
                    notif.type = notifType
                    let strInfo:String = item["sNotifInfo"].value!
                    var strArr:[String] = strInfo.componentsSeparatedByString(Const.NOTIF_JOIN_LVL1)
                    notif.groupId = Int(strArr[0])!
                    notif.message = strArr[1]
                    if notifType == Const.NOTIF_CHAT_MSG || notifType == Const.NOTIF_ALREADY_MATCH
                    {
                        notif.messageId = Int(strArr[3])! // removed suidtoint due to id is coming in int format -- Krishnat - 14/oct - 15
                        notif.other = strArr[1]
                        notif.message = strArr[2]
                    }
                    else
                    {
                        notif.other = strArr[2]
                    }
                    notifications.append(notif)
                }
            }
            DBChats.addNotifications(notifications)
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
}
