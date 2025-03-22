mod html_template;

use domain::ChargesCalculator;

use axum::{
    extract::State,
    response::IntoResponse,
    routing::{get, post},
    Error, Form, Router,
};
use html_template::{CalculateChargesForm, CalculateChargesResponse, HtmlTemplate, ToPay};
use rust_decimal::Decimal;
use rust_decimal_macros::dec;
use std::sync::Arc;
use tokio::net::TcpListener;
use tracing::{info, Level};
use tracing_subscriber;

#[tokio::main]
pub async fn main() -> Result<(), Error> {
    let calculator = domain::ChargesCalculator {
        charges: vec![dec!(19)],
    };

    serve(calculator).await
}

async fn serve(calculator: ChargesCalculator) -> Result<(), Error> {
    init_tracing();

    let shared_calculator = Arc::new(calculator);

    let app = Router::new()
        .route("/", get(get_fuck_your_charges_form))
        .route("/calculate-charges", post(calculate_charges))
        .with_state(shared_calculator);

    // run our app with hyper, listening globally on port 5000
    let listener = TcpListener::bind("0.0.0.0:5000").await.unwrap();
    info!("Server is running on http://0.0.0.0:5000");
    axum::serve(listener, app).await.unwrap();

    Ok(())
}

async fn get_fuck_your_charges_form() -> impl IntoResponse {
    HtmlTemplate(CalculateChargesForm { prices: "".to_owned() })
}

async fn calculate_charges(
    State(calculator): State<Arc<ChargesCalculator>>,
    Form(input): Form<CalculateChargesForm>,
) -> impl IntoResponse {
    let parsed_input = input.prices.split(' ').map(|s| s.parse::<Decimal>().unwrap()).collect::<Vec<_>>();
    let result = calculator.add_charges_per_pax(parsed_input);
    let to_pay = result.iter().map(|x| ToPay {
        original_price: x.net_price,
        price_to_pay: x.price_to_pay,
    });

    HtmlTemplate(CalculateChargesResponse {
        prices: Vec::from_iter(to_pay),
    })
}

fn init_tracing() {
    tracing_subscriber::fmt().with_max_level(Level::INFO).init();
}
