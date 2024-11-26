#[starknet::interface]
pub trait iprice_feed<TContractState> {
    fn get_price(self: @TContractState, _priceId: u256) -> u256;
}