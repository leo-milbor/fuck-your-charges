use clap::Parser;
use rust_decimal::Decimal;
use rust_decimal_macros::dec;

use domain;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Cli {
    #[arg(short('g'), long)]
    gst: Option<Decimal>,

    #[arg(short('s'), long)]
    service: Option<Decimal>,

    prices: Vec<Decimal>,
}

fn main() {
    let cli = Cli::parse();

    let calculator = domain::ChargesCalculator {
        gst: cli.gst.unwrap_or(dec!(9)),
        service: cli.service.unwrap_or(dec!(10)),
    };

    cli_as_calculator(calculator, cli.prices)
}

fn cli_as_calculator(calculator: domain::ChargesCalculator, prices: Vec<Decimal>) {
    println!("gst: {:?}%", calculator.gst);
    println!("service charge: {:?}%", calculator.service);

    for ele in calculator.add_charges_per_pax(prices) {
        println!(
            "net price: {:?}, actually paid: {:?}",
            ele.net_price, ele.price_to_pay
        )
    }
}

#[cfg(test)]
mod tests {
    use assert_cmd::Command;

    const APP_NAME: &str = "fuck_your_charges";

    #[test]
    fn verify_cli_default() {
        let mut cmd = Command::cargo_bin(APP_NAME).unwrap();
        let _ = cmd
            .arg("10")
            .assert()
            .stdout("gst: 9%\nservice charge: 10%\nnet price: 10, actually paid: 11.90\n")
            .code(0)
            .success();
    }

    #[test]
    fn verify_cli() {
        let mut cmd = Command::cargo_bin(APP_NAME).unwrap();
        let _ = cmd
            .arg("--service")
            .arg("20")
            .arg("--gst")
            .arg("10")
            .arg("13")
            .arg("10")
            .assert()
            .stdout("gst: 10%\nservice charge: 20%\nnet price: 13, actually paid: 16.90\nnet price: 10, actually paid: 13.00\n")
            .code(0)
            .success();
    }
}
