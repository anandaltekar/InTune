
import Foundation

class GetCommuniqueBoxNotes: NSObject, NSXMLParserDelegate, _IFaceAPI{
    var methodName: String = "GetCommuniqueBoxNotes"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var chatList:[structChatMsg] = Array<structChatMsg>()
    var groupID:Int = 0
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetCommuniqueBoxNotes xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidComminiqueBox>\(params[1])</suidComminiqueBox><nStart>0</nStart><nCount>0</nCount></GetCommuniqueBoxNotes></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            
                let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_aNote"]
                for var index:Int = 0; index < dictData.children.count; ++index {
                    let item : AEXMLElement = dictData.children[index]
                    var msg:structChatMsg = structChatMsg()
                    msg.id = Utility.suidToInt(item["suidNote"].value!)
                    msg.user.id = Utility.suidToInt(item["suidUser"].value!)
                    msg.user.name = item["sUsername"].value!
                    msg.groupID = self.groupID
                    let isGuestMsg:Int = Int(item["nMsgType"].value!)!
                    if isGuestMsg == 0 {
                        if msg.user.id == Utility.suidToInt(publicSuidUser) {
                            msg.type = Const.OWN_MSG
                        }
                    }
                    else {
                        msg.type = Const.HOST_MSG
                    }
                    msg.text = item["sContent"].value!
                    msg.date = item["dtDate"].value!
                    chatList.append(msg)
                }
            DBChats.addMessages(chatList)
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
}
