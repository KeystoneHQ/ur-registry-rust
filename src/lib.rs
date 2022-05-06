pub mod crypto_key_path;
pub mod crypto_ec_key;
pub mod traits;
pub mod registry_types;
pub mod crypto_hd_key;
pub mod crypto_coin_info;
mod types;
pub mod solana;
mod cbor_value;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
