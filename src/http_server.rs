use crate::charges_calculator::ChargesCalculator;

use axum::{extract::State, routing::post, Error, Json, Router};
use rust_decimal::Decimal;
use std::sync::Arc;
use tracing::{info, Level};
use tracing_subscriber;

pub async fn serve(calculator: ChargesCalculator) -> Result<(), Error> {
    init_tracing();

    let shared_calculator = Arc::new(calculator);

    let app = Router::new()
        .route("/calculate-charges", post(calculate_charges))
        .with_state(shared_calculator);

    // run our app with hyper, listening globally on port 5000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:5000").await.unwrap();
    info!("Server is running on http://0.0.0.0:5000");
    axum::serve(listener, app).await.unwrap();

    Ok(())
}

async fn calculate_charges(
    State(calculator): State<Arc<ChargesCalculator>>,
    Json(input): Json<Vec<Decimal>>,
) -> String {
    calculator
        .add_charges_per_pax(input)
        .iter()
        .map(|tp| {
            format!(
                "net price: {:?}, actual price: {:?}\n",
                tp.net_price, tp.price_to_pay
            )
        })
        .fold(String::new(), |a, s| format!("{}{}", a, s))
}

fn init_tracing() {
    tracing_subscriber::fmt().with_max_level(Level::INFO).init();
}
