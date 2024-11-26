#[starknet::interface]
pub trait isupply_schedule<TContractState> {
    fn start_schedule(ref self: TContractState);
    fn set_decay_rate(ref self: TContractState, _decayRate: u256);
    fn record_mint_event(ref self: TContractState);
    fn mintable_supply(self: @TContractState) -> u256;
    fn is_mintable(self: @TContractState) -> bool;
    fn is_started(self: @TContractState) -> bool;
}