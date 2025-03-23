use std::str::FromStr;

use domain::{self};
use rust_decimal::Decimal;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(sync)]
pub fn calculate_charges(prices: Vec<String>, charges: Vec<String>) -> Vec<(String, String)> {
    let parsed_charges = charges.iter().map(|s| Decimal::from_str(s.as_str()).unwrap()).collect();
    let calculator = domain::ChargesCalculator {
        charges: parsed_charges,
    };

    let parsed_prices = prices.iter().map(|s| Decimal::from_str(s.as_str()).unwrap()).collect();
    let to_pay = calculator.add_charges_per_pax(parsed_prices);
    return to_pay.iter().map(|tp| (tp.net_price.to_string(), tp.price_to_pay.to_string())).collect();
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
