//
//  _IFaceAPI.swift
//  in-tune
//
//  Created by Anand Altekar on 28/07/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

protocol _IFaceAPI
{
    var methodName: String {get}
    var pageTarget: _IFaceCallTarget? {get set}
    var soapEnv: String {get set}
    var respCode: Int {get set}
    func request(params:[String])
    func response(response responseData: NSMutableData)

}