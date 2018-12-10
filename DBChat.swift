
import Foundation
import UIKit
//var publicSrotMsg:Int = 0

class DBChat {
    let songsTblName:String = "SongList"
    let groupTblName:String = "ChatGroups"
    let msegsTblName:String = "ChatMessages"
    let usersTblName:String = "ChatGroupUsers"
    let notifTblName:String = "UserNotifications"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func createChatTables(){
        if let err = SD.executeChange("CREATE TABLE \(songsTblName) (ID INTEGER PRIMARY KEY, name TEXT, artist TEXT, checkValue INTEGER, nMatchesFound INTEGER, nTotalReqFound INTEGER, nKilledStatus INTEGER, nRequestedStatus INTEGER, concertID INTEGER)")
        {
            print("DBQsMedia - Error creating Table\(err.description)")
        }
        
        // Date : 18/09/2015 - Added ,sortBy' column to get records order by updated, can't sort by date as there are different datetime formats comming from server (unpredictable) response. Due to time constraints applying some other alternative.
        if let err = SD.executeChange("CREATE TABLE \(groupTblName) (ID INTEGER PRIMARY KEY, name TEXT, userCount INTEGER, songId INTEGER, msgId INTEGER, lastMessage TEXT, imagePath TEXT, lastUpdatedDate TEXT, unreadCount INTEGER, activeStatus INTEGER, sortBy INTEGER)")
        {
            print("DBQsMedia - Error creating Table\(err.description)")
        }
        
        if let err = SD.executeChange("CREATE TABLE \(msegsTblName) (ID INTEGER PRIMARY KEY, msgText TEXT, groupID INTEGER, userId INTEGER, date TEXT, userName TEXT, imagePath TEXT, isOwn INTEGER, readUnread INTEGER)")
        {
            print("DBQsMedia - Error creating Table\(err.description)")
        }
        
        if let err = SD.executeChange("CREATE TABLE \(usersTblName) (ID INTEGER, name TEXT, groupID INTEGER, imagePath TEXT, fbUrl TEXT, status INTEGER)")
        {
            print("DBQsMedia - Error creating Table\(err.description)")
        }
        
        if let err = SD.executeChange("CREATE TABLE \(notifTblName) (ID INTEGER PRIMARY KEY, message TEXT, type INTEGER, idUser INTEGER, other TEXT, date TEXT, groupID INTEGER, messageID INTEGER, status INTEGER)")
        {
            print("DBQsMedia - Error creating Table\(err.description)")
        }
    }
    
    func updateGroupSequence(groupID:Int){
        let query:String = "UPDATE \(groupTblName) SET sortBy = (SELECT min(sortBy) FROM \(groupTblName)) - 1 WHERE ID = \(groupID)"
        if let err =  SD.executeChange(query){
            print(err.value)
        }
    }
    
    func addSongs(songList:[structSongDetails]){
        if songList.count>0{
            var valQuery:String = ""
            for item in songList {
                if valQuery != "" {
                    valQuery = "\(valQuery), (\(item.id), '\(item.sSongsName)', '\(item.sSongArtist)', \(item.checkValue), \(item.nMatchesFound), \(item.nTotalReqFound), \(item.nKilledStatus), \(item.nRequestedStatus), \(item.nConsertID))"
                }
                else{
                    valQuery = "(\(item.id), '\(item.sSongsName)', '\(item.sSongArtist)', \(item.checkValue), \(item.nMatchesFound), \(item.nTotalReqFound), \(item.nKilledStatus), \(item.nRequestedStatus), \(item.nConsertID))"
                }
            }
            let queryString:String = "INSERT OR REPLACE INTO \(songsTblName) (ID, name, artist, checkValue, nMatchesFound, nTotalReqFound, nKilledStatus, nRequestedStatus, concertID) VALUES \(valQuery)"
            if let errs = SD.executeChange(queryString) {
                print("Error while inserting row Error-code:\(errs)")
            }
        }
    }
    
    func addGroups(groupsList:[structChatMsgGroup]){
        print("$$@@##@@$$-DBChats-addGroups-opt-1")
        if groupsList.count>0{
            var valQuery:String = ""
            var sortCount:Int = 0
            for item in groupsList {
                
                if valQuery != "" {
                    valQuery = "\(valQuery), (\(item.id), '\(item.name)', \(item.userCount), \(item.lastMsgID), '\(item.lastMsg)', '\(item.imgPath)', '\(item.date)', (SELECT unreadCount FROM \(groupTblName) WHERE ID = \(item.id)), \(item.status), \(sortCount))"
                }
                else{
                    valQuery = "(\(item.id), '\(item.name)', \(item.userCount), \(item.lastMsgID), '\(item.lastMsg)', '\(item.imgPath)', '\(item.date)', (SELECT unreadCount FROM \(groupTblName) WHERE ID = \(item.id)), \(item.status), \(sortCount))"
                }
                addUsers(item.userList, groupID: item.id)
                sortCount++
            }
            let queryString:String = "INSERT OR REPLACE INTO \(groupTblName) (ID, name, userCount, msgId, lastMessage, imagePath, lastUpdatedDate, unreadCount, activeStatus, sortBy) VALUES \(valQuery)"
            if let errs = SD.executeChange(queryString) {
                print("Error while inserting row Error-code:\(errs)")
            }
        }
    }
    func addGroups(groupsList:[structChatMsgGroup], count:Int){
        print("$$@@##@@$$-DBChats-addGroups-opt-2")
        if groupsList.count>0{
            var valQuery:String = ""
            for item in groupsList {
                if valQuery != "" {
                    valQuery = "\(valQuery), (\(item.id), '\(item.name)', \(item.userCount), \(item.lastMsgID), '\(item.lastMsg)', '\(item.imgPath)', '\(item.date)', \(item.badgeCount), \(item.status), (SELECT min(sortBy) FROM \(groupTblName)) - 1)"
                }
                else{
                    valQuery = "(\(item.id), '\(item.name)', \(item.userCount), \(item.lastMsgID), '\(item.lastMsg)', '\(item.imgPath)', '\(item.date)', \(item.badgeCount), \(item.status), (SELECT min(sortBy) FROM \(groupTblName)) - 1)"
                }
                addUsers(item.userList, groupID: item.id)
            }
            let queryString:String = "INSERT OR REPLACE INTO \(groupTblName) (ID, name, userCount, msgId, lastMessage, imagePath, lastUpdatedDate, unreadCount, activeStatus, sortBy) VALUES \(valQuery)"
            print(queryString)
            if let errs = SD.executeChange(queryString) {
                print("Error while inserting row Error-code:\(errs)")
            }
            if appDelegate.mainTabBar != nil {
                appDelegate.mainTabBar.addBadge()
            }
        }
    }
    func addMessages(msgList:[structChatMsg]){ //, updateGroup:Bool
        if msgList.count>0
        {
            var valQuery:String = ""
            for item in msgList
            {
                let strMsg:String = item.text.stringByReplacingOccurrencesOfString("'", withString: "''", options: NSStringCompareOptions.LiteralSearch, range: nil)
                if valQuery != ""
                {
                    valQuery = "\(valQuery), (\(item.id), '\(strMsg)', \(item.groupID), \(item.user.id), '\(item.date)', '\(item.user.name)', '\(item.user.fbProfUrl)', \(item.type), \(item.readUnread))"
                }
                else{
                    valQuery = "(\(item.id), '\(strMsg)', \(item.groupID), \(item.user.id), '\(item.date)', '\(item.user.name)', '\(item.user.fbProfUrl)', \(item.type), \(item.readUnread))"
                }
                if appDelegate.chatRoom == nil || appDelegate.chatRoom.idGroup != item.groupID {
                    updateGroupNotifCount(item.groupID, count: 1)
                }
                else {
                    if item.type != Const.OWN_MSG{
                        appDelegate.chatRoom.addMessageInRoom(item)
                    }
                }
                if appDelegate.mainTabBar != nil {
                    appDelegate.mainTabBar.addBadge()
                }
            }
            let queryString:String = "INSERT OR REPLACE INTO \(msegsTblName) (ID, msgText, groupID, userId, date, userName, imagePath, isOwn, readUnread) VALUES \(valQuery)"
            
            if let errs = SD.executeChange(queryString) {
                print("Error while inserting row Error-code:\(errs)")
            }
        }
    }
    func addUsers(userList:[structChatMsgUser], groupID:Int){
        
        if userList.count>0{
            SD.executeChange("DELETE FROM \(usersTblName) WHERE groupID=\(groupID)")
            var valQuery:String = ""
            for item in userList {
                if valQuery != "" {
                    valQuery = "\(valQuery), (\(item.id), '\(item.name)', \(groupID), '\(item.imgPath)', '\(item.fbProfUrl)')"
                }
                else{
                    valQuery = "(\(item.id), '\(item.name)', \(groupID), '\(item.imgPath)', '\(item.fbProfUrl)')"
                }
            }
            let queryString:String = "INSERT OR REPLACE INTO \(usersTblName) (ID, name, groupID, imagePath, fbUrl) VALUES \(valQuery)"
            SD.executeChange(queryString)
        }
    }
    func addNotifications(notifications:[structNotification]){
        if notifications.count>0{
            var valQuery:String = ""
            var chatMsgs:[structChatMsg] = Array<structChatMsg>()
            for item in notifications {
                if valQuery != "" {
                    valQuery = "\(valQuery), (\(item.id), '\(item.message)', \(item.type), \(item.idUser), '\(item.other)', '\(item.date)', \(item.groupId), \(item.messageId), \(item.status))"
                }
                else{
                    valQuery = "(\(item.id), '\(item.message)', \(item.type), \(item.idUser), '\(item.other)', '\(item.date)', \(item.groupId), \(item.messageId), \(item.status))"
                }
                //add chat message if notification is of type Chat
                if item.type == Const.NOTIF_CHAT_MSG || item.type == Const.NOTIF_ALREADY_MATCH {
                    var chatMsg:structChatMsg = structChatMsg()
                    chatMsg.id = item.messageId
                    chatMsg.text = item.message
                    chatMsg.user.id = item.idUser
                    chatMsg.user.name = item.other
                    chatMsg.groupID = item.groupId
                    chatMsg.type = item.messageType
                    chatMsg.date = item.date
                    chatMsgs.append(chatMsg)
                    updateGroupSequence(item.groupId)
                }
                else if item.type == Const.NOTIF_USER_ACCEPTED {
                    var group:structChatMsgGroup = getGroup(item.groupId)
                    if group.id != 0 {
                        group.status = Const.ACTIVE
                        group.badgeCount = 1
                        var userStrct:structChatMsgUser = structChatMsgUser()
                        let userInfoArr:[String] = item.other.componentsSeparatedByString(Const.NOTIF_JOIN_LVL2)
                        for usr in userInfoArr {
                            var userDetailsArr:[String] = usr.componentsSeparatedByString(Const.NOTIF_JOIN_LVL3)
                            if Utility.suidToInt(publicSuidUser) != Int(userDetailsArr[0])! {
                                userStrct.id = Int(userDetailsArr[0])!
                                userStrct.name = userDetailsArr[1]
                                userStrct.fbProfUrl = userDetailsArr[2]
                                userStrct.status = Const.ACTIVE
                            }
                        }
                        for var i=0; i<group.userList.count; i++ {
                            if group.userList[i].id == userStrct.id
                            {
                                group.userList[i].status = Const.ACTIVE
                            }
                        }
                        addGroups([group], count: group.badgeCount)
                    }
                }
            }
            addMessages(chatMsgs)
            let queryString:String = "INSERT OR IGNORE INTO \(notifTblName) (ID, message, type, idUser, other, date, groupID, messageID, status) VALUES \(valQuery)"
            SD.executeChange(queryString)
        }
        
    }
    func getSongList(consertID:Int)->[structSongDetails]{
        var songsList:[structSongDetails] = Array<structSongDetails>()
        let (result, err) = SD.executeQuery("SELECT * FROM \(songsTblName) WHERE nKilledStatus!=\(Const.SONG_KILLED) AND concertID = \(consertID)")
        if err == nil {
            for row in result {
                var song:structSongDetails = structSongDetails()
                song.id = row["ID"]?.value as! Int
                song.sSongsName = row["name"]?.value as! String
                song.sSongArtist = row["artist"]?.value as! String
                song.checkValue = row["checkValue"]?.value as! Int
                song.nMatchesFound = row["nMatchesFound"]?.value as! Int
                song.nTotalReqFound = row["nTotalReqFound"]?.value as! Int
                song.nKilledStatus = row["nKilledStatus"]?.value as! Int
                song.nRequestedStatus = row["nRequestedStatus"]?.value as! Int
                song.nConsertID = row["concertID"]?.value as! Int
                songsList.append(song)
            }
        }
        return songsList
    }
    func getGroups()->[structChatMsgGroup]{
        var messageGroupList:[structChatMsgGroup] = Array<structChatMsgGroup>()
        let (result, err) = SD.executeQuery("SELECT * FROM \(groupTblName) WHERE activeStatus=\(Const.ACTIVE) ORDER BY sortBy ASC")
        //var firstGroup:Bool = true
        if err == nil {
            for row in result {
                var stChatGroup:structChatMsgGroup = structChatMsgGroup()
                stChatGroup.id = row["ID"]?.value as! Int
                stChatGroup.name = row["name"]?.value as! String
                stChatGroup.lastMsg = row["lastMessage"]?.value as! String
                stChatGroup.date = row["lastUpdatedDate"]?.value as! String
                stChatGroup.userCount = row["userCount"]?.value as! Int
                if row["unreadCount"]?.value != nil {
                    stChatGroup.newMsgFlag = row["unreadCount"]?.value as! Int
                }
                stChatGroup.userList = getGroupUsers(row["ID"]?.value as! Int)
                messageGroupList.append(stChatGroup)
            }
        }
        return messageGroupList
    }
    func getGroup(groupID:Int)->structChatMsgGroup{
        var stChatGroup:structChatMsgGroup = structChatMsgGroup()
        let (result, err) = SD.executeQuery("SELECT * FROM \(groupTblName) WHERE ID=\(groupID)")
        if err == nil {
            for row in result {
                stChatGroup.id = row["ID"]?.value as! Int
                stChatGroup.name = row["name"]?.value as! String
                stChatGroup.lastMsg = row["lastMessage"]?.value as! String
                stChatGroup.date = row["lastUpdatedDate"]?.value as! String
                stChatGroup.userCount = row["userCount"]?.value as! Int
                if row["unreadCount"]?.value != nil {
                    stChatGroup.badgeCount = row["unreadCount"]?.value as! Int
                }
                stChatGroup.userList = getGroupUsers(row["ID"]?.value as! Int)
            }
        }
        return stChatGroup
    }
    func getMessages(groupID:Int)->[structChatMsg]{
        var messageList:[structChatMsg] = Array<structChatMsg>()
        let (result, err) = SD.executeQuery("SELECT * FROM \(msegsTblName) WHERE groupID=\(groupID) ORDER BY ID DESC")
        updateGroupNotifCount(groupID, count: -1)
        if err == nil
        {
            for row in result
            {
                var stChatMsg:structChatMsg = structChatMsg()
                stChatMsg.id = row["ID"]?.value as! Int
                stChatMsg.text = row["msgText"]?.value as! String
                stChatMsg.type = row["isOwn"]?.value as! Int
                stChatMsg.date = row["date"]?.value as! String
                stChatMsg.user.name = row["userName"]?.value as! String
                stChatMsg.user.id = row["userId"]?.value as! Int
                stChatMsg.user.fbProfUrl = row["imagePath"]?.value as! String
                messageList.append(stChatMsg)
            }
        }
        return messageList
    }
    func getGroupUsers(groupID:Int)->[structChatMsgUser]{
        var userList:[structChatMsgUser] = Array<structChatMsgUser>()
        let (result, err) = SD.executeQuery("SELECT * FROM \(usersTblName) WHERE groupID=\(groupID)")
        if err == nil {
            for row in result {
                var stUser:structChatMsgUser = structChatMsgUser()
                stUser.id = row["ID"]?.value as! Int
                stUser.name = row["name"]?.value as! String
                stUser.fbProfUrl = row["fbUrl"]?.value as! String
                userList.append(stUser)
            }
        }
        return userList
    }
    func getUnreadNotifs(type:Int)->[structNotification]{
        var notifs:[structNotification] = Array<structNotification>()
        var typeQry:String = ""
        if type != Const.NOTIF_TYPE_NONE {
            typeQry = "AND type = \(type)"
        }
        let (result, err) = SD.executeQuery("SELECT * FROM \(notifTblName) WHERE status=\(Const.UNREAD) \(typeQry)")
        if err == nil {
            for row in result {
                var notif:structNotification = structNotification()
                notif.id = row["ID"]?.value as! Int
                notif.message = row["message"]?.value as! String
                notif.type = row["type"]?.value as! Int
                notif.idUser = row["idUser"]?.value as! Int
                notif.other = row["other"]?.value as! String
                notif.date = row["date"]?.value as! String
                notif.groupId = row["groupID"]?.value as! Int
                notif.messageId = row["messageID"]?.value as! Int
                notifs.append(notif)
            }
        }
        return notifs
    }
    func getUnreadGroups()->[[Int:Int]]{
        let (result, err) = SD.executeQuery("SELECT ID, unreadCount FROM \(groupTblName) WHERE unreadCount > 0")
        var groupCount:[[Int:Int]] = []
        if err == nil {
            for row in result {
                groupCount.append([row["ID"]?.value as! Int:row["unreadCount"]?.value as! Int])
            }
        }
        return groupCount
    }
    func updateGroupNotifCount(groupId:Int, count:Int){
        let strGroup:structChatMsgGroup = self.getGroup(groupId)
        if strGroup.id > 0 {
            let badgeCount:Int = strGroup.badgeCount + count
            var query:String = "UPDATE \(groupTblName) SET unreadCount = \(badgeCount) WHERE ID = \(groupId)"
            if count == -1 {
                query = "UPDATE \(groupTblName) SET unreadCount = \(0) WHERE ID=\(groupId)"
            }
            if let err =  SD.executeChange(query){
                print(err.value)
            }
        }
    }
    func updateSong(id:Int, updateField:String, value:Int){
        let query:String = "UPDATE \(songsTblName) SET \(updateField) = \(value) WHERE ID = \(id)"
        if let err =  SD.executeChange(query){
            print(err.value)
        }
    }
    func updateUserStatus(id:Int, groupId:Int, value:Int){
        let query:String = "UPDATE \(usersTblName) SET status = \(value) WHERE ID = \(id) AND groupID = \(groupId)"
        if let err =  SD.executeChange(query){
            print(err.value)
        }
    }
    func updateNotificationState(id:Int, state:Int){
        let query:String = "UPDATE \(notifTblName) SET status = \(state) WHERE ID = \(id)"
        if let err =  SD.executeChange(query){
            print(err.value)
        }
    }
    func updateGroupStatus(groupId:Int, value:Int){
        let query:String = "UPDATE \(groupTblName) SET activeStatus = \(value) WHERE ID = \(groupId)"
        if let err =  SD.executeChange(query){
            print(err.value)
        }
    }
    func truncateChatData(){
        SD.executeChange("DELETE FROM \(songsTblName)")
        SD.executeChange("DELETE FROM \(groupTblName)")
        SD.executeChange("DELETE FROM \(msegsTblName)")
        SD.executeChange("DELETE FROM \(usersTblName)")
        SD.executeChange("DELETE FROM \(notifTblName)")
    }
}
var DBChats:DBChat = DBChat()