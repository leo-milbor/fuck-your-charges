use rust_decimal::Decimal;
use rust_decimal_macros::dec;

#[derive(Clone)]
pub struct ChargesCalculator {
    pub charges: Vec<Decimal>,
}

#[derive(Debug, PartialEq, Eq)]
pub struct ToPay {
    pub net_price: Decimal,
    pub price_to_pay: Decimal,
}

impl ChargesCalculator {
    pub fn add_charges_per_pax(&self, prices: Vec<Decimal>) -> Vec<ToPay> {
        prices
            .iter()
            .map(|p| ToPay {
                net_price: *p,
                price_to_pay: self.add_charges(p),
            })
            .collect()
    }

    fn add_charges(&self, price: &Decimal) -> Decimal {
        let coef = dec!(1) + self.charges.iter().sum::<Decimal>() / dec!(100);
        price * coef
    }
}

#[cfg(test)]
mod tests {
    use std::vec;

    use super::*;

    #[derive(Debug)]
    struct TestParam {
        input: Decimal,
        expected: Decimal,
    }

    #[test]
    fn add_gst_and_service_charge_on_simple_price() {
        // arrange
        let values = vec![
            TestParam {
                input: dec!(13.0),
                expected: dec!(15.47),
            },
            TestParam {
                input: dec!(0.0),
                expected: dec!(0.0),
            },
        ];
        let calculator = ChargesCalculator {
            charges: vec![dec!(9), dec!(10)],
        };

        for ele in values {
            // act
            let result = calculator.add_charges(&ele.input);

            // assert
            assert_eq!(result, ele.expected);
        }
    }

    #[test]
    fn add_gst_and_service_charge_for_2_pax() {
        // arrange
        let values = vec![
            TestParam {
                input: dec!(13.0),
                expected: dec!(15.47),
            },
            TestParam {
                input: dec!(0.0),
                expected: dec!(0.0),
            },
        ];
        let calculator = ChargesCalculator {
            charges: vec![dec!(9), dec!(10)],
        };

        // act
        let result = calculator.add_charges_per_pax(values.iter().map(|v| v.input).collect());

        // assert
        assert_eq!(
            result,
            values
                .iter()
                .map(|v| ToPay {
                    net_price: v.input,
                    price_to_pay: v.expected
                })
                .collect::<Vec<_>>()
        );
    }
}
