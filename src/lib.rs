mod crypto_key_path;
mod crypto_ec_key;
mod traits;
mod registry_types;
mod crypto_hd_key;
mod crypto_coin_info;
mod types;
mod solana;
mod cbor_value;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
