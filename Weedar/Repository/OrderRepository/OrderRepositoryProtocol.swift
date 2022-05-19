//
//  PrderRepositoryProtocol.swift
//  Weelar
//
//  Created by Ivan Zelenskyi Store on 07.09.2021.
//

import Foundation

protocol OrderRepositoryProtocol {
    func makeOrder(data: OrderRequestModel, completion: @escaping (Result<OrderResponseModel, OrderRequestError>) -> Void)
    
    func getOrders(userId: Int,
                   completion: @escaping (Result<[OrderResponseModel], OrderRequestError>) -> Void)
    
    func getOrderDetails(orderId: Int,
                         completion: @escaping (Result<[OrderDetailOLD], OrderRequestError>) -> Void)
    
    func confirmOrder(id: Int,
                      completion: @escaping (Result<Bool, OrderRequestError>) -> Void)
}
