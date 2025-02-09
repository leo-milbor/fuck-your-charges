use domain::ChargesCalculator;

use askama::Template;
use axum::{
    extract::State,
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Error, Form, Router,
};
use rust_decimal::Decimal;
use rust_decimal_macros::dec;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tracing::{info, Level};
use tracing_subscriber;

#[tokio::main]
pub async fn main() -> Result<(), Error> {
    let calculator = domain::ChargesCalculator {
        gst: dec!(9),
        service: dec!(10),
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
    let listener = tokio::net::TcpListener::bind("0.0.0.0:5000").await.unwrap();
    info!("Server is running on http://0.0.0.0:5000");
    axum::serve(listener, app).await.unwrap();

    Ok(())
}

async fn get_fuck_your_charges_form() -> impl IntoResponse {
    HtmlTemplate(CalculateChargesForm { price: dec!(0) })
}

#[derive(Template, Debug, Serialize, Deserialize)]
#[template(path = "fuck-your-charges-form.html")]
struct CalculateChargesForm {
    price: Decimal,
}

struct HtmlTemplate<T>(T);

impl<T> IntoResponse for HtmlTemplate<T>
where
    T: Template,
{
    fn into_response(self) -> Response {
        match self.0.render() {
            Ok(html) => Html(html).into_response(),
            Err(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Failed to render template. Error: {err}"),
            )
                .into_response(),
        }
    }
}

async fn calculate_charges(
    State(calculator): State<Arc<ChargesCalculator>>,
    Form(input): Form<CalculateChargesForm>,
) -> String {
    calculator
        .add_charges_per_pax(vec![input.price])
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
