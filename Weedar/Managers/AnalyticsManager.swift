//
//  AnalyticsManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.06.2022.
//

import SwiftUI
import Amplitude
 

class AnalyticsManager {
    static let instance = AnalyticsManager()
    func event(key: AMEventKeys, properties: [AMPropertieKey : Any] = [:]){
        
        if UserDefaults.standard.bool(forKey: "EnableTracking"){
            print("AnalyticsManager: event: \(key.eventKey)  properties: \(properties)")
            Amplitude.instance().logEvent(key.eventKey, withEventProperties: properties)
        }
    }
}

enum AMPropertieKey: String{
    case source = "source"
    case error_type = "error_type"
    case resend_code_qty = "resend_code_qty"
    case adress_fail_qty = "adress_fail_qty"
    case address_validation = "address_validation"
    case method_id = "method_id"
    case method_recommendation = "method_recommendation"
    case item_catalog = "item_catalog"
    case tab_select_catalog = "tab_select_catalog"
    case movement = "movement"
    case category = "category"
    case product_qty = "product_qty"
    case camera_access = "camera_access"
    case method_tutorial = "method_tutorial"
    case method_carousel = "method_carousel"
    case cart_size = "cart_size"
    case minimize_method = "minimize_method"
    case profile_category = "profile_category"
    case order_id = "order_id"
    case method_recommend = "method_recommend"
    case notifications_allowance = "notifications_allowance"
    case current_status = "current_status"
    case price_range = "price_range"
    case brand_name = "brand_name"
    case effects = "effects"
    case product_id = "product_id"
    case product_price = "product_price"
    case order_creation_fail = "order_creation_fail"
    case order_status = "order_status"
    case order_number = "order_number"
    case status_id = "status_id"
}

enum AMEventKeys{
    //ADMIN
    
        case app_start
        case app_close
    
    //Splash
        case view_age_screen
        case true21
        case false21
        case cancel_age_alert
        case site_age_alert
        case back_app_age
        case view_resident_screen
        case resident_true
        case resident_false
        case cancel_resident_alert
        case site_resident_alert
        case back_app_resident
    
    //Login
        case view_login_view
        case login_success
        case login_fail
        case logout_success
        case reset_password
        case reset_password_view
        case reset_password_success
        case reset_password_fail
        case reset_password_return
    
    //Sign Up
        case view_signup_screen
        case email_pass_success
        case email_pass_fail
        case view_provide_phone_screen
        case number_success
        case number_fail
        case view_confirm_phone_screen
        case number_confirm_success
        case number_confirm_fail
        case resend_code
        case resend_code_return
        case view_delivery_signup_screen
        case name_signup
        case address_signup_success
        case address_fail
        case address_signup_next
        case deliver_signup_return
        case view_verify_id_screen
        case id_upload
        case recommend_upload
        case delete_id_upload
        case delete_recommens_upload
        case verify_id_success
        case verify_id_return
    
    
    //Catalog
        case view_catalog_screen
        case select_catalog
        case select_bar_menu
        case view_category_screen
        case category_scroll
        case select_product
        case click_search
        case search_product_success
        case search_product_fail
        case search_cancel
        case click_filters
        case filters_apply
        case filter_fail
        case filter_close
        case add_cart_catalog
        case view_product_card
        case product_card_return
        case product_card_ar
        case product_card_qty
        case add_cart_prod_card
    
    
    //AR Catalog
    
        case ar_catalog_view
        case camera_allowance
        case tutorial
        case carousel_swipe
        case product_select_3D
        case add_cart_ar
        case ar_remapping
        case ar_catalog_return
    
    
    //Cart
        case empty_cart_view
        case go_catalog
        case min_order_view
        case cart_view
        case qty_cart
        case delete_product
        case clear_cart
        case cart_bar_select
        case proceed_checkout
    
    //Checkout
        case delivery_checkout_view
        case name_change
        case address_change_success
        case address_change_fail
        case delivery_checkout_return
        case review_order_success
        case order_creation_fail
        case order_review_view
        case expand_total
        case order_review_return
        case make_order
        case thank_order_view
        case back_to_store
    
    
    //Order tracking
        case order_trackbar_view
        case switch_order
        case cancel_order
        case minimize_trackbar
        case changeOrderStatus
    
    
    //Profile
        case profile_view
        case select_profile_category
        case my_order_view
        case select_order
        case docs_center_view
        case change_id
        case remove_id
        case recommend_id
        case remove_recommend
        case save_docs
        case docs_center_return
        case change_pass_view
        case change_pass_success
        case change_pass_fail
        case change_pass_return
        case contact_us_view
        case send_message
        case contact_us_return
        case legal_view
        case legal_return
        case notification_toogle
    
    
    
    var eventKey: String {
        get {
            switch self {
            case .app_start:
                return "app_start"
            case .app_close:
                return "app_close"
            //Splash
            case .view_age_screen:
                return "view_age_screen"
            case .true21:
                return "true21"
            case .false21:
                return "false21"
            case .cancel_age_alert:
                return "cancel_age_alert"
            case .site_age_alert:
                return "site_age_alert"
            case .back_app_age:
                return "back_app_age"
            case .view_resident_screen:
                return "view_resident_screen"
            case .resident_true:
                return "resident_true"
            case .resident_false:
                return "resident_false"
            case .cancel_resident_alert:
                return "cancel_resident_alert"
            case .site_resident_alert:
                return "site_resident_alert"
            case .back_app_resident:
                return "back_app_resident"
                
            //Login
            case .view_login_view:
                return "view_login_view"
            case .login_success:
                return "login_success"
            case .login_fail:
                return "login_fail"
            case .logout_success:
                return "logout_success"
            case .reset_password:
                return "reset_password"
            case .reset_password_view:
                return "reset_password_view"
            case .reset_password_success:
                return "reset_password_success"
            case .reset_password_fail:
                return "reset_password_fail"
            case .reset_password_return:
                return "reset_password_return"
                
            //Sign Up
            case .view_signup_screen:
                return "view_signup_screen"
            case .email_pass_success:
                return "email_pass_success"
            case .email_pass_fail:
                return "email_pass_fail"
            case .view_provide_phone_screen:
                return "view_provide_phone_screen"
            case .number_success:
                return "number_success"
            case .number_fail:
                return "number_fail"
            case .view_confirm_phone_screen:
                return "view_confirm_phone_screen"
            case .number_confirm_success:
                return "number_confirm_success"
            case .number_confirm_fail:
                return "number_confirm_fail"
            case .resend_code:
                return "resend_code"
            case .resend_code_return:
                return "resend_code_return"
            case .view_delivery_signup_screen:
                return "view_delivery_signup_screen"
            case .name_signup:
                return "name_signup"
            case .address_signup_success:
                return "address_signup_success"
            case .address_fail:
                return "address_fail"
            case .address_signup_next:
                return "address_signup_next"
            case .deliver_signup_return:
                return "deliver_signup_return"
            case .view_verify_id_screen:
                return "view_verify_id_screen"
            case .id_upload:
                return "id_upload"
            case .recommend_upload:
                return "recommend_upload"
            case .delete_id_upload:
                return "delete_id_upload"
            case .delete_recommens_upload:
                return "delete_recommens_upload"
            case .verify_id_success:
                return "verify_id_success"
            case .verify_id_return:
                return "verify_id_return"
                
            //Catalog
            case .view_catalog_screen:
                return "view_catalog_screen"
            case .select_catalog:
                return "select_catalog"
            case .select_bar_menu:
                return "select_bar_menu"
            case .view_category_screen:
                return "view_category_screen"
            case .category_scroll:
                return "category_scroll"
            case .select_product:
                return "select_product"
            case .click_search:
                return "click_search"
            case .search_product_success:
                return "search_product_success"
            case .search_product_fail:
                return "search_product_fail"
            case .search_cancel:
                return "search_cancel"
            case .click_filters:
                return "click_filters"
            case .filters_apply:
                return "filters_apply"
            case .filter_fail:
                return "filter_fail"
            case .filter_close:
                return "filter_close"
            case .add_cart_catalog:
                return "add_cart_catalog"
            case .view_product_card:
                return "view_product_card"
            case .product_card_return:
                return "product_card_return"
            case .product_card_ar:
                return "product_card_ar"
            case .product_card_qty:
                return "product_card_qty"
            case .add_cart_prod_card:
                return "add_cart_prod_card"
                
            //AR Catalog
            case .ar_catalog_view:
                return "ar_catalog_view"
            case .camera_allowance:
                return "camera_allowance"
            case .tutorial:
                return "tutorial"
            case .carousel_swipe:
                return "carousel_swipe"
            case .product_select_3D:
                return "product_select_3D"
            case .add_cart_ar:
                return "add_cart_ar"
            case .ar_remapping:
                return "ar_remapping"
            case .ar_catalog_return:
                return "ar_catalog_return"
                
            //Cart
            case .empty_cart_view:
                return "empty_cart_view"
            case .go_catalog:
                return "go_catalog"
            case .min_order_view:
                return "min_order_view"
            case .cart_view:
                return "cart_view"
            case .qty_cart:
                return "qty_cart"
            case .delete_product:
                return "delete_product"
            case .clear_cart:
                return "clear_cart"
            case .cart_bar_select:
                return "cart_bar_select"
            case .proceed_checkout:
                return "proceed_checkout"
                
            //Checkout
            case .delivery_checkout_view:
                return "delivery_checkout_view"
            case .name_change:
                return "name_change"
            case .address_change_success:
                return "address_change_success"
            case .address_change_fail:
                return "address_change_fail"
            case .delivery_checkout_return:
                return "delivery_checkout_return"
            case .review_order_success:
                return "review_order_success"
            case .order_creation_fail:
                return "order_creation_fail"
            case .order_review_view:
                return "order_review_view"
            case .expand_total:
                return "expand_total"
            case .order_review_return:
                return "order_review_return"
            case .make_order:
                return "make_order"
            case .thank_order_view:
                return "thank_order_view"
            case .back_to_store:
                return "back_to_store"
                
                
            //Order tracking
            case .order_trackbar_view:
                return "order_trackbar_view"
            case .switch_order:
                return "switch_order"
            case .cancel_order:
                return "cancel_order"
            case .minimize_trackbar:
                return "minimize_trackbar"
            case .changeOrderStatus:
                return "changeOrderStatus"
                
            //Profile
            case .profile_view:
                return "profile_view"
            case .select_profile_category:
                return "select_profile_category"
            case .my_order_view:
                return "my_order_view"
            case .select_order:
                return "select_order"
            case .docs_center_view:
                return "docs_center_view"
            case .change_id:
                return "change_id"
            case .remove_id:
                return "remove_id"
            case .recommend_id:
                return "recommend_id"
            case .remove_recommend:
                return "remove_recommend"
            case .save_docs:
                return "save_docs"
            case .docs_center_return:
                return "docs_center_return"
            case .change_pass_view:
                return "change_pass_view"
            case .change_pass_success:
                return "change_pass_success"
            case .change_pass_fail:
                return "change_pass_fail"
            case .change_pass_return:
                return "change_pass_return"
            case .contact_us_view:
                return "contact_us_view"
            case .send_message:
                return "send_message"
            case .contact_us_return:
                return "contact_us_return"
            case .legal_view:
                return "legal_view"
            case .legal_return:
                return "legal_return"
            case .notification_toogle:
                return "notification_toogle"
                
   
            }
        }
    }
}
