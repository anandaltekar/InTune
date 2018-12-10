
import Foundation

class GetUserCommuniqueboxes: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "GetUserCommuniqueboxes"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var chatGroupList:[structChatMsgGroup] = Array<structChatMsgGroup>()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetUserCommuniqueboxes xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession></GetUserCommuniqueboxes></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_UserCommuniqueBoxes"]
            for var index:Int = 0; index < dictData.children.count; ++index
            {
                let item : AEXMLElement = dictData.children[index]
                let userList:AEXMLElement = item["aCommuniqueBoxUsers"]
                if userList.children.count > 0
                {
                    var chatGroup:structChatMsgGroup = structChatMsgGroup()
                    chatGroup.id = Utility.suidToInt(item["suidCommuniqueBox"].value!)
                    chatGroup.name = item["sCommuniqueBoxName"].value!
                    chatGroup.status = Const.ACTIVE
                    if (item["sDateTime"].value != nil)
                    {
                        chatGroup.date = item["sDateTime"].value!
                    }
                    chatGroup.badgeCount = Int(item["nUpdatedNoteCount"].value!)!
                    chatGroup.type = Int(item["nCommuniqueBoxType"].value!)!
                    for var t:Int = 0; t<userList.children.count; t++
                    {
                        let usrXml:AEXMLElement =  userList.children[t]
                        var user:structChatMsgUser = structChatMsgUser()
                        user.id = Utility.suidToInt(usrXml["suidUser"].value!)
                        user.name = usrXml["sUserName"].value!
                        user.status = Const.ACTIVE
//                        if usrXml["sfbUserProfilePicLink"].value != nil
//                        {
//                            user.imgPath = usrXml["sfbUserProfilePicLink"].value!
//                        }
                        if usrXml["sfbUserId"].value != nil
                        {
                            user.fbProfUrl = usrXml["sfbUserId"].value!
                        }
                        chatGroup.userList.append(user)
                    }
                    chatGroupList.append(chatGroup)
                }
            }
            DBChats.addGroups(chatGroupList)
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
}
