use askama::Template;
use axum::{
    http::StatusCode,
    response::{Html, IntoResponse, Response},
};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

#[derive(Template, Debug, Serialize, Deserialize)]
#[template(path = "fuck-your-charges-form.html")]
pub struct CalculateChargesForm {
    pub price: Decimal,
}

#[derive(Template, Debug, Serialize, Deserialize)]
#[template(path = "fuck-your-charges-response.html")]
pub struct CalculateChargesResponse {
    pub prices: Vec<ToPay>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ToPay {
    pub original_price: Decimal,
    pub price_to_pay: Decimal,
}

pub struct HtmlTemplate<T>(pub T);

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
